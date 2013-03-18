require 'set'

module PhoneNumber
  class Region
    REGION_FILE = File.join(File.dirname(__FILE__), '..', 'data', 'regions.bin')
    
    attr_reader :country_code, :country_abbr
    attr_reader :trunk_prefixes, :dialout_prefixes
    attr_reader :rule_sets
    
    class << self
      def load
        @@regions = []
        Marshal.load(File.read(REGION_FILE)).each_pair do |key, region_hash|
          new_region = Region.new region_hash
          @@regions.push new_region
        end
        @@regions
      end
  
      def all
        @@regions.empty? ? load : @@regions
      end
  
      def find(param)    
        all.detect do |region|
          region.country_code.to_s == param.to_s || region.country_abbr.to_s == param.to_s
        end
      end
  
      def [](param)
        find(param)
      end
    end
    
    def initialize(options={})
      @country_abbr = options[:country_abbr]
      @country_code = options[:country_code]
    
      @trunk_prefixes   = options[:trunk_prefixes]
      @dialout_prefixes = options[:dialout_prefixes]
    
      @rule_sets = SortedSet.new
      
      (options[:rule_sets]||[]).each do |rule_group|
        @rule_sets.add RuleGroup.new(rule_group[:significant_digits], rule_group[:rules])
      end
    end
    
    def to_s
      country_abbr
    end
  end
end