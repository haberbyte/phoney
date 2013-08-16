$:.unshift File.expand_path("../lib", __FILE__)
require "phoney/version"

Gem::Specification.new do |s|
  s.name = 'phoney'
  s.version = Phoney::VERSION
  s.author = 'Jan Habermann'
  s.email = 'jan@habermann24.com'
  s.homepage = 'http://github.com/habermann24/phoney'
  s.summary = 'Ruby library that formats phone numbers.'
  s.description = 'Ruby library that parses a phone number and automatically formats it correctly, depending on the country/locale you set.'
  
  s.required_rubygems_version = '>= 1.9'
  
  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
  
  s.files = Dir["#{File.dirname(__FILE__)}/**/*"]
end

