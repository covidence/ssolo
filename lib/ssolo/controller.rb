# frozen_string_literal: true

module SSOlo
  # Manages the external process of a SSOlo server
  class Controller
    MAXIMUM_ATTEMPTS = 20

    def metadata_url
      @metadata_url ||= "http://127.0.0.1:#{port}/metadata"
    end

    def settings
      @settings ||= begin
        wait_until_booted

        OneLogin::RubySaml::IdpMetadataParser.new.parse_remote(
          metadata_url
        )
      end
    end

    def start(sp_certificate:, name_id: nil)
      @pid = Process.spawn(
        {
          "SSOLO_PORT" => port.to_s,
          "SSOLO_NAME_ID" => name_id,
          "SSOLO_SP_CERTIFICATE" => sp_certificate
        },
        "bundle exec ssolo"
      )
    end

    def stop
      Process.kill("KILL", @pid)
    end

    private

    def port
      @port ||= Addrinfo.tcp("", 0).bind { |s| s.local_address.ip_port }
    end

    def wait_until_booted
      attempts = 0

      begin
        Net::HTTP.get(URI(metadata_url))
      rescue Errno::ECONNREFUSED
        attempts += 1
        raise if attempts > MAXIMUM_ATTEMPTS

        sleep 0.1
        retry
      end
    end
  end
end
