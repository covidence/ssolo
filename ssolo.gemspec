# frozen_string_literal: true

require_relative "lib/ssolo/version"

Gem::Specification.new do |spec|
  spec.name = "ssolo"
  spec.version = SSOlo::VERSION
  spec.authors = ["Pat Allan"]
  spec.email = ["pat@freelancing-gods.com"]

  spec.summary = "A micro SAML IdP for development/test environments"
  spec.homepage = "https://github.com/pat/ssolo"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir["{exe,lib}/**/*"] +
               %w[CHANGELOG.md CODE_OF_CONDUCT.md LICENSE.txt README.md]

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "json"
  spec.add_dependency "puma"
  spec.add_dependency "rack"
  spec.add_dependency "ruby-saml"
  spec.add_dependency "saml_idp"
end
