# SSOlo

SSOlo is a small SAML identity provider (IdP), for use in test and development environments in applications which operate as service providers - particularly for use with feature tests.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add ssolo
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install ssolo
```

## Usage

### Test Environments

Using SSOlo within a test suite can be done via an instance of `SSOlo::Controller`, where you can start the server with an immediately-returned Name ID/email address:

```ruby
controller = SSOlo::Controller.new
controller.start(
  sp_certificate: <<~CERT,
    -----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----
  CERT
  name_id: "test@example.com"
)

# connect up the appropriate SAML settings via an
# OneLogin::RubySaml::Settings instance:
controller.settings #=> OneLogin::RubySaml::Settings
controller.settings.idp_entity_id
controller.settings.idp_sso_service_url
controller.settings.idp_cert

# These details are also available via a URL:
controller.metadata_url

# initiate a SAML request, and the following
# SAML response will be returned immediately with
# the specified name_id in the above `start` call.

# And then when you're done:
controller.stop
```

The SSOlo server will use ephemeral certificates and private keys, and the port will also change on every boot (following the behaviour of a standard Capybara server).

### Development Environments

To run SSOlo for a development environment, use the provided executable and manage settings via environment variables:

```sh
bundle exec ssolo \
  SSOLO_PERSISTENCE=~/.ssolo.json \
  SSOLO_SP_CERTIFICATE="-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----" \
  SSOLO_HOST=127.0.0.1 \
  SSOLO_PORT=9292 \
  SSOLO_SILENT=true
```

`SSOLO_PERSISTENCE` can either be a file path, or "true" or "false". `SSOLO_SP_CERTIFICATE` must be specified with the certificate in PEM format. The other variables are optional (and the above values are the defaults).

You can also specify `SSOLO_NAME_ID` to keep the supplied name ID as a fixed value. But otherwise, you will be prompted for a value when you're going through the SAML flow.

The IdP server has two endpoints:

* `GET /metadata` which returns the XML metadata
* `GET /saml` which is the URL to initiate SAML requests

So, if you're running the server with the default environment variables, you should be able to see the metadata via [http://127.0.0.1:9292/metadata](http://127.0.0.1:9292/metadata).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pat/ssolo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/pat/ssolo/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SSOlo project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pat/ssolo/blob/main/CODE_OF_CONDUCT.md).
