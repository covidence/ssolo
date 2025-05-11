# frozen_string_literal: true

module SSOlo
  module Templates
    # Returns the HTML output of an auto-submitting form, to post the SAML
    # response through to the service provider.
    class Response
      def self.call(...)
        new(...).call
      end

      def initialize(server, request, name_id)
        @server = server
        @request = request
        @name_id = name_id
      end

      # rubocop:disable Metrics/MethodLength
      def call
        configure_idp

        <<~HTML
          <!DOCTYPE html>
          <html>
            <head>
              <meta charset="utf-8">
              <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
            </head>
            <body onload="document.forms[0].submit();" style="visibility:hidden;">
              <form method="post" action="#{saml_request.acs_url}">
                <input type="hidden" name="SAMLResponse" value="#{saml_response}" />
                <input type="hidden" name="RelayState" value="#{request.params['RelayState']}" />
                <input type="submit" value="Submit" />
              </form>
            </body>
          </html>
        HTML
      end
      # rubocop:enable Metrics/MethodLength

      private

      attr_reader :server, :request, :name_id

      def configure_idp
        SamlIdp.configure do |config|
          config.base_saml_location = "#{request.base_url}/saml"
          config.x509_certificate = server.certificate
          config.secret_key = server.private_key
          config.algorithm = :sha256
          config.name_id.formats = {
            email_address: ->(principal) { principal }
          }
        end
      end

      def saml_request
        @saml_request ||= SamlIdp::Request.from_deflated_request(
          request.params["SAMLRequest"]
        )
      end

      # rubocop:disable Metrics/MethodLength
      def saml_response
        SamlIdp::SamlResponse.new(
          SecureRandom.uuid, # reference_id
          SecureRandom.uuid, # response_id
          "#{request.base_url}/saml", # issuer_uri
          name_id, # principal / name ID
          saml_request.issuer,
          saml_request.request_id,
          saml_request.acs_url,
          OpenSSL::Digest::SHA256,
          Saml::XML::Namespaces::AuthnContext::ClassRef::PASSWORD,
          60 * 60, # expiry
          {
            # This is the service provider's certificate, so we can encrypt the
            # response in a manner that only the service provider can decrypt.
            cert: server.sp_certificate,
            block_encryption: "aes256-cbc",
            key_transport: "rsa-oaep-mgf1p"
          }
        ).build
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
