require 'yaml'

class PhoneNumber
  
  class Region
    @@regions = []
    
    attr_reader :country_code, :country_abbr
    attr_reader :national_prefix, :dialout_prefixes
    attr_reader :rule_sets
    
    class << self
      def load
        data_file = File.join(File.dirname(__FILE__), '..', 'data', 'regions.yml')
    
        @@regions = []
        YAML.load(File.read(data_file)).each_pair do |key, region_hash|
          new_region = Region.new(region_hash)
          @@regions.push(new_region)
        end
        @@regions
      end
  
      def all
        return @@regions unless @@regions.empty?
    
        load
      end
  
      def find(param)
        return nil unless param
        
        param = param.to_sym
    
        all.detect do |region|
          region.country_code == param || region.country_abbr == param
        end
      end
  
      def [](param)
        find(param)
      end
    end
    
    def initialize(hash)
      @country_abbr = hash[:country_abbr]
      @country_code = hash[:country_code]
    
      @national_prefix  = hash[:national_prefix]
      @dialout_prefixes = hash[:dialout_prefixes]
    
      @rule_sets = hash[:rule_sets]
      
      if(@rule_sets)
        for rule_set in @rule_sets do
          if(rule_set[:rules])
            rule_set[:rules].each_with_index do |rule,index|
              rule.merge!(:index => index)
            end
          end
        end
      end
    end
    
    def to_s
      "#{@country_abbr.to_s} [+#{@country_code.to_s}]"
    end
  end
  
end