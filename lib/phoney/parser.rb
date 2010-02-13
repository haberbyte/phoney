require 'strscan'
require 'pp'

class PhoneNumber

  module Parser
    class << self
      include Utils
      
      def parse(phone_number, region_code=nil)
        parse_to_parts(phone_number, region_code)[:formatted_number]
      end
      
      def parse_to_parts(phone_number, region_code=nil)
        phone_number = normalize(phone_number.to_s)

        # we don't really need to do anything unless we get more input
        return phone_number unless phone_number.length > 1

        region          = Region.find(region_code) || PhoneNumber.region
        country_code    = region.country_code.to_s
        area_code       = nil

        dialout_prefix  = get_dialout_prefix(phone_number, region.dialout_prefixes)
        national_prefix = get_national_prefix(phone_number, region.national_prefix)
        dialout_region  = get_dialout_region(phone_number, dialout_prefix)
        dialout_country = ''
        rule_sets       = get_rule_sets_for_region(phone_number, dialout_region || region)
        
        # build our total prefix
        if dialout_region
          prefix       = dialout_prefix + dialout_region.country_code.to_s
          country_code = dialout_region.country_code.to_s
          dialout_country = country_code
        else
          prefix  = national_prefix
          prefix += dialout_prefix unless(dialout_prefix.empty?)
        end
        
        # strip the total prefix from the beginning of the number
        phone_number = phone_number[prefix.length..-1]
        number       = phone_number
        
        # if we're dialing out or using the national prefix
        if(dialout_region || !national_prefix.empty?)
          # we need to sort the rules slightly different
          
          rule_sets.each do |rule_set|
            # [rule type DESC, total_digits ASC]
            rule_set[:rules] = rule_set[:rules].sort_by { |rule| [ -rule[:type], rule[:total_digits] ] }
          end
        end

        # find our matching rule
        matching_rule = find_matching_rule(phone_number, rule_sets)
        
        if(matching_rule)
          area_code     = phone_number[matching_rule[:areacode_offset], matching_rule[:areacode_length]]
          number        = phone_number[matching_rule[:areacode_offset]+matching_rule[:areacode_length]..-1]
          phone_number  = format(phone_number, matching_rule[:format].to_s)
          
          # replace 'n' with our national_prefix
          phone_number.gsub!(/n{1}/, national_prefix)
          
          # strip possible whitespace from the left
          phone_number.lstrip!
          
          # format the rest
          if(dialout_prefix == '+')
            phone_number.gsub!(/c{1}/, "+#{dialout_country}")
          else
            phone_number.gsub!(/c{1}/, dialout_country)
            phone_number = "#{dialout_prefix} #{phone_number}" unless dialout_prefix.empty?
          end
        else
          # no match: falling back to default formatting
          if(dialout_prefix == '+')
            if(dialout_country.empty?)
              phone_number = "+#{phone_number}"
            else
              phone_number = "+#{dialout_country} #{phone_number}"
            end
          else
            phone_number = "#{dialout_country} #{phone_number}" unless dialout_country.empty?
            phone_number = "#{dialout_prefix} #{phone_number}" unless dialout_prefix.empty?
            phone_number = national_prefix + phone_number unless national_prefix.empty?
          end
        end
        
        # strip possible whitespace from the right
        phone_number.rstrip!
        
        # Finally...we can output our parts as a hash
        { :formatted_number => phone_number, :area_code => area_code, :country_code => country_code, :number => number }
      end
      
      private
      def get_rule_sets_for_region(string, region)
        rule_sets = []
        
        if(region && region.rule_sets)
          rule_sets = region.rule_sets.select do |rule_set|
            rule_set[:digits] <= string.length
          end
        end
        
        rule_sets
      end
      
      def find_matching_rule(string, rule_sets)
        match = nil
        
        # go through all our given rules
        for rule_set in rule_sets do
          digits = rule_set[:digits]
          prefix = string[0,digits].to_i
          rules  = rule_set[:rules].select { |rule| rule[:total_digits] >= string.length }

          rules.each do |rule|
            if(prefix >= rule[:min] && prefix <= rule[:max])
              match = rule
              break
            end
          end
          
          break if match
        end
        
        match
      end
      
      def dialing_out?(string, region_code=nil)
        region = Region.find(region_code) || PhoneNumber.region
        !get_dialout_prefix(string, region.dialout_prefixes).empty?
      end
            
      def get_dialout_prefix(string, prefixes=nil)
        dialout_prefix = ''
        
        if(prefixes.nil?)
          prefixes = PhoneNumber.region.dialout_prefixes
        end
        
        # check if we're dialing outside our region
        if string[0].chr == '+'
          dialout_prefix = '+'
        else
          for prefix in prefixes do
            if(string =~ Regexp.new("^#{prefix}"))
              dialout_prefix = prefix
              break
            end
          end
        end
        
        dialout_prefix
      end
      
      def get_national_prefix(string, prefix=nil)
        national_prefix = ''
        
        if(prefix.nil?)
          prefix = PhoneNumber.region.national_prefix
        end

        # in case we're not dialing out and the number starts with the national_prefix
        if(!dialing_out?(string) && string =~ Regexp.new("^#{prefix}"))
          national_prefix = prefix
        end

        national_prefix
      end
      
      def get_dialout_region(string, dialout_prefix)
        dialout_region = nil
        
        unless dialout_prefix.empty?
          # region codes are 1 to 3 digits
          range_end = [string.length-dialout_prefix.length, 3].min

          (1..range_end).each do |i|
            dialout_region = Region.find(string[dialout_prefix.length, i])
            break if dialout_region
          end
        end
        
        dialout_region
      end
    end
  end

end