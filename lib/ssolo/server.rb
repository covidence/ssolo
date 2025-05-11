# frozen_string_literal: true

require "rack"
require "saml_idp"

require_relative "certificate"

module SSOlo
  # A rack app that operates as an extremely minimal SAML Identity Provider.
  # There are two endpoints:
  #
  # - GET /metadata -- which returns the SAML IdP metadata as XML
  # - GET /saml -- which, if there's a default name ID, renders a HTML form that
  #   submits immediately. Otherwise, renders a form asking for a name ID/email
  #   address
  class Server
    attr_reader :sp_certificate

    def initialize(sp_certificate:, default_name_id: nil, persistence: false)
      @sp_certificate = certificate_from_string(sp_certificate)
      @default_name_id = default_name_id
      @persistence = persistence
    end

    def call(env)
      request = Rack::Request.new(env)
      return four_oh_four unless request.get?

      case request.path_info
      when "/metadata"
        metadata(request)
      when "/saml"
        saml(request)
      else
        [200, {}, [""]]
      end
    end

    def certificate
      @certificate ||= certificate_from_string(persisted_settings["certificate"])
    end

    def private_key
      @private_key ||= OpenSSL::PKey::RSA.new(persisted_settings["private_key"])
    end

    private

    attr_reader :default_name_id, :persistence

    def certificate_from_string(value)
      case value
      when String
        OpenSSL::X509::Certificate.new(value)
      when OpenSSL::X509::Certificate
        value
      else
        raise ArgumentError, "Invalid certificate: #{value}"
      end
    end

    def four_oh_four
      [404, {}, ["Not Found"]]
    end

    def metadata(request)
      [
        200,
        { "Content-Type" => "application/xml; charset=utf-8" },
        [SSOlo::Templates::Metadata.call(request, certificate)]
      ]
    end

    def new_settings
      key = OpenSSL::PKey::RSA.new(2048)

      {
        "certificate" => SSOlo::Certificate.call(key).to_pem,
        "private_key" => key.to_pem
      }
    end

    def persistence_path
      case persistence
      when String
        persistence
      else
        "~/.ssolo.json"
      end
    end

    def persisted_settings
      @persisted_settings ||= begin
        settings = File.exist?(persistence_path) ? JSON.parse(File.read(persistence_path)) : new_settings

        File.write(persistence_path, JSON.generate(settings)) if persistence

        settings
      end
    end

    def saml(request)
      name_id = default_name_id || request.params["name_id"]

      html = if name_id && name_id.strip.length.positive?
               SSOlo::Templates::Response.call(self, request, name_id)
             else
               SSOlo::Templates::Entry.call(request)
             end

      [200, { "Content-Type" => "text/html; charset=utf-8" }, [html]]
    end
  end
end
