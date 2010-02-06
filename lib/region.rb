require 'yaml'

class Region
  attr_reader :country_code, :country_abbr, :national_prefix, :dialout_prefixes, :rule_sets
  
  @@all_regions = nil
  
  #----------------------------------------------------------------------------
  def initialize(country_abbr, country_code, national_prefix, dialout_prefixes, rule_sets)
    @country_abbr = country_abbr
    @country_code = country_code
    
    @national_prefix  = national_prefix
    @dialout_prefixes = dialout_prefixes
    
    @rule_sets = rule_sets
  end
  
  #----------------------------------------------------------------------------
  def self.all
    return @@all_regions unless @@all_regions.nil?
    
    data_file = File.join(File.dirname(__FILE__), '..', 'data', 'regions.yml')

    @@all_regions = []
    YAML.load(File.read(data_file)).each_pair do |key, r|
      new_region = Region.new(r[:country_abbr], r[:country_code], r[:national_prefix], r[:dialout_prefixes], r[:rule_sets])
      @@all_regions.push(new_region)
    end
    @@all_regions
  end
  
  #----------------------------------------------------------------------------
  def self.find(param)
    param = param.to_sym
    
    all.detect do |region|
      region.country_code == param || region.country_abbr == param
    end
  end
  
  #----------------------------------------------------------------------------
  def self.[](param)
    find(param)
  end
    
  #----------------------------------------------------------------------------
  def to_s
    "#{@country_abbr.to_s} [+#{@country_code.to_s}]"
  end
  
end