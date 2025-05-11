# frozen_string_literal: true

module SSOlo
  module Templates
    # Renders the XML details of the Identity Provider
    class Metadata
      def self.call(request, certificate)
        <<~XML
          <?xml version="1.0" encoding="utf-8"?>
          <EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata" entityID="#{request.base_url}/saml">
            <IDPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
              <KeyDescriptor>
                <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
                  <ds:X509Data>
                    <ds:X509Certificate>
                      #{certificate.to_pem.lines.grep_v(/BEGIN|END/).join.strip}
                    </ds:X509Certificate>
                  </ds:X509Data>
                </ds:KeyInfo>
              </KeyDescriptor>
              <SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="#{request.base_url}/saml" />
            </IDPSSODescriptor>
          </EntityDescriptor>
        XML
      end
    end
  end
end
