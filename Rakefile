require 'lib/phoney'
require 'rake/clean'
 
#### TESTING ####
require 'rake/testtask'
task :default => :test
 
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end
 
#### COVERAGE ####
begin
  require 'rcov/rcovtask'
 
  Rcov::RcovTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/*_test.rb']
    t.verbose = true
    t.rcov_opts << '--exclude "gems/*"'
  end
rescue LoadError
end
 
#### DOCUMENTATION ####
require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.template = ENV['template'] if ENV['template']
  rdoc.title = "PhoneNumber Documentation"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.options << '--charset' << 'utf-8'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

#### GEMSPEC #####
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