require 'rubygems'
require 'spec/rake/spectask'

require File.join(File.dirname(__FILE__), 'lib', 'phoney')

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "phoney"
    gem.summary = %Q{Ruby library that formats phone numbers.}
    gem.description = %Q{Ruby library that parses a phone number and automatically formats it correctly, depending on the country/locale you set.}
    gem.email = "jan@habermann24.com"
    gem.homepage = "http://github.com/habermann24/phoney"
    gem.authors = ["Jan Habermann"]
    gem.version = PhoneNumber.version
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
 
require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end
 
require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.template = ENV['template'] if ENV['template']
  rdoc.title = "Phoney Documentation"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.options << '--charset' << 'utf-8'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
