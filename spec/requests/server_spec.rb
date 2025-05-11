# frozen_string_literal: true

require "spec_helper"
require "rack/test"
require "ruby-saml"

OneLogin::RubySaml::Logging.logger.level = :info

RSpec.describe SSOlo::Server do
  include Rack::Test::Methods

  let(:sp_private_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:sp_certificate) { SSOlo::Certificate.call(sp_private_key) }

  subject(:app) do
    SSOlo::Server.new(sp_certificate:, default_name_id: "test@example.com")
  end

  describe "GET /metadata" do
    it "returns valid metadata for the IdP" do
      get "/metadata"

      expect(last_response).to be_ok

      parser = OneLogin::RubySaml::IdpMetadataParser.new
      settings = parser.parse(last_response.body)

      expect(settings.idp_entity_id).to eq("http://example.org/saml")
      expect(settings.idp_sso_service_url).to eq("http://example.org/saml")
      expect(settings.idp_cert).not_to be_nil
    end
  end

  describe "GET /saml" do
    let(:settings) do
      parser = OneLogin::RubySaml::IdpMetadataParser.new
      settings = parser.parse(get("/metadata").body)
      settings.assertion_consumer_service_url = "http://external.example.com"
      settings.sp_entity_id = "http://external.example.com"
      settings.certificate = sp_certificate.to_pem
      settings.private_key = sp_private_key.private_to_pem
      settings
    end

    context "with a default email address" do
      it "builds a form with a valid SAML response and the specific email address" do
        uri = URI(OneLogin::RubySaml::Authrequest.new.create(settings))
        get uri.to_s

        html = Nokogiri::HTML(last_response.body)
        value = html.css("[name=SAMLResponse]").first["value"]

        saml_response = OneLogin::RubySaml::Response.new(
          value, settings: settings
        )
        expect(saml_response.is_valid?).to eq(true)
        expect(saml_response.name_id).to eq("test@example.com")
      end
    end

    context "with no email address specified" do
      subject(:app) do
        SSOlo::Server.new(sp_certificate:)
      end

      it "builds a form with the request an email address field" do
        uri = URI(OneLogin::RubySaml::Authrequest.new.create(settings))
        get uri.to_s

        html = Nokogiri::HTML(last_response.body)
        name_id_input = html.css("[name=name_id]").first
        saml_request = SamlIdp::Request.from_deflated_request(
          html.css("[name=SAMLRequest]").first["value"]
        )

        expect(name_id_input).not_to be_nil
        expect(saml_request).not_to be_nil
      end
    end

    context "with an email address specified via a parameter" do
      subject(:app) do
        SSOlo::Server.new(sp_certificate:)
      end

      it "builds a form with a valid SAML response and the specific email address" do
        uri = URI(OneLogin::RubySaml::Authrequest.new.create(settings))
        get "#{uri}&name_id=specific@example.com"

        html = Nokogiri::HTML(last_response.body)
        value = html.css("[name=SAMLResponse]").first["value"]

        saml_response = OneLogin::RubySaml::Response.new(
          value, settings: settings
        )
        expect(saml_response.is_valid?).to eq(true)
        expect(saml_response.name_id).to eq("specific@example.com")
      end
    end
  end
end
