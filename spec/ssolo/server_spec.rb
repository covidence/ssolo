# frozen_string_literal: true

require "fileutils"
require "spec_helper"

RSpec.describe SSOlo::Server do
  let(:sp_private_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:sp_certificate) { SSOlo::Certificate.call(sp_private_key) }

  it "generates different credentials for each instance by default" do
    a = SSOlo::Server.new(sp_certificate:)
    b = SSOlo::Server.new(sp_certificate:)

    expect(a.certificate.to_pem).not_to eq(b.certificate.to_pem)
    expect(a.private_key.private_to_pem).not_to eq(b.private_key.private_to_pem)
  end

  it "can persist settings to a JSON file" do
    a = SSOlo::Server.new(sp_certificate:, persistence: "./ssolo-test.json")
    b = SSOlo::Server.new(sp_certificate:, persistence: "./ssolo-test.json")

    expect(a.certificate.to_pem).to eq(b.certificate.to_pem)
    expect(a.private_key.private_to_pem).to eq(b.private_key.private_to_pem)

    FileUtils.rm("./ssolo-test.json")
  end
end
