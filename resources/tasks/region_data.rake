require 'yaml'
require './resources/phoneformat_converter'

namespace :phoney do
  desc 'Generate a regions YAML file from a .phoneformat binary'
  task :generate_regions_yml do
    raise 'You must provide .phoneformat FILE for the task to run' unless ENV['FILE']
    PhoneformatConverter.convert(ENV['FILE'])
  end
  
  desc 'Generate a new regions data file from a .phoneformat binary'
  task :generate_regions_bin do
    raise 'You must provide .phoneformat FILE for the task to run' unless ENV['FILE']
    
    output  = StringIO.new
    $stdout = output
    
    PhoneformatConverter.convert(ENV['FILE'])
    
    $stdout = STDOUT
    puts Marshal.dump(YAML.load(output.string))
  end
end