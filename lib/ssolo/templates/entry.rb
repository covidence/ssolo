# frozen_string_literal: true

module SSOlo
  module Templates
    # Returns HTML for a form that contains an in-progress SAML request, with
    # a field to specify a custom Name ID/email address.
    class Entry
      def self.call(request)
        <<~HTML
          <!DOCTYPE html>
          <html>
            <head>
              <meta charset="utf-8">
              <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
            </head>
            <body>
              <form method="get" action="#{request.base_url}/saml">
                <input type="hidden" name="SAMLRequest" value="#{request.params['SAMLRequest']}">
                <input type="hidden" name="RelayState" value="#{request.params['RelayState']}">

                <label for="name_id">Email / Name ID</label>
                <input type="text" name="name_id" id="name_id">

                <input type="submit" value="Submit">
              </form>
            </body>
          </html>
        HTML
      end
    end
  end
end
