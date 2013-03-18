require 'strscan'

module PhoneNumber
  module Parser
    class << self
      include Formatter
      
      def parse(input, options={})
        number       = normalize(input)
        intl_prefix  = international_call_prefix_for number
        country_code = extract_country_code number
        trunk_prefix = extract_trunk_prefix number
        region       = PhoneNumber.region
        flags        = []
        
        if intl_prefix
          # Strip international prefix from number
          number = number[intl_prefix.count(NUMPAD_CHARS)..-1]
        end
        
        if country_code
          # Strip country code from number
          number = number[country_code.count(DIGITS)..-1]
          region = PhoneNumber::Region[country_code]
          flags << :c
          
          if intl_prefix == '+'
            intl_prefix += country_code
          else
            intl_prefix = [intl_prefix, country_code].join(' ')
          end
        end
        
        if trunk_prefix
          # Strip trunk prefix from number
          number = number[trunk_prefix.count(DIGITS)..-1]
          flags << :n
        end
        
        rule = find_matching_rule_for number, region: region, flags: flags
        rule ||= find_matching_rule_for number, region: region
        
        if rule
          format number, rule.pattern, intl_prefix: intl_prefix, trunk_prefix: trunk_prefix
        else
          format number, '#'*number.length, intl_prefix: intl_prefix, trunk_prefix: trunk_prefix
        end
      end
      
      private
        def find_matching_rule_for(number, options={})
          region = options[:region] || PhoneNumber.region
          options[:flags] ||= []
          
          # Consider all rule sets that aren't too specific for the number
          region.rule_sets.select { |r| number.length >= r.significant_digits }.each do |rule_set|
            # Filter rules that don't have all the flags
            rules = rule_set.rules.reject { |r| ([options[:flags]].flatten - r.flags).size != 0 }
            
            # Find and return the first rule that matches
            matching_rule = rules.find { |rule| rule.matches? number }
            return matching_rule unless matching_rule.nil?
          end
          
          return nil
        end
    end
  end
end