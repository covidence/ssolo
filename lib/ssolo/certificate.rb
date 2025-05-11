# frozen_string_literal: true

require "openssl"

module SSOlo
  # Generates an X509 certificate with the given private key. These certificates
  # are not meant for production use.
  class Certificate
    def self.call(...)
      new(...).call
    end

    def initialize(private_key)
      @private_key = private_key
    end

    # rubocop:disable Metrics/AbcSize
    def call
      OpenSSL::X509::Certificate.new.tap do |certificate|
        certificate.version = 2
        certificate.serial = 0
        certificate.not_before = not_before
        certificate.not_after = not_after
        certificate.public_key = public_key
        certificate.subject = name
        certificate.issuer = name
        certificate.sign(private_key, digest)
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    attr_reader :private_key

    def digest
      OpenSSL::Digest.new("SHA256")
    end

    def name
      @name ||= OpenSSL::X509::Name.parse "/CN=nobody/DC=example"
    end

    # ~10 years
    def not_after
      Time.now + (10 * 365 * 24 * 60 * 60)
    end

    def not_before
      Time.now
    end

    def public_key
      private_key.public_key
    end
  end
end
