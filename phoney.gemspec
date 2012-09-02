# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "phoney/version"

Gem::Specification.new do |s|
  s.name = %q{phoney}
  s.version = PhoneNumber::VERSION::STRING

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jan Habermann"]
  s.date = %q{2011-12-01}
  s.description = %q{Ruby library that parses a phone number and automatically formats it correctly, depending on the country/locale you set.}
  s.email = %q{jan@habermann24.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENCE",
    "README.rdoc",
    "Rakefile",
    "lib/data/regions.yml",
    "lib/phoney.rb",
    "lib/phoney/base.rb",
    "lib/phoney/parser.rb",
    "lib/phoney/region.rb",
    "lib/phoney/utils.rb",
    "lib/phoney/version.rb",
    "phoney.gemspec",
    "spec/parser/br_spec.rb",
    "spec/parser/de_spec.rb",
    "spec/parser/us_spec.rb",
    "spec/phone_number_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/habermann24/phoney}
  s.require_paths = ["lib"]
  s.summary = %q{Ruby library that formats phone numbers.}

  s.add_runtime_dependency(%q<phoney>, [">= 0"])
  s.add_development_dependency(%q<rake>, [">= 0"])
  s.add_development_dependency(%q<rspec>, ["= 2.11.0"])
end

