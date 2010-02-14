require 'strscan'

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
        unless phone_number.length > 1
          return { :formatted_number => phone_number, :number => normalize(phone_number) }
        end

        region          = Region.find(region_code) || PhoneNumber.default_region
        country_code    = region.country_code.to_s
        area_code       = nil

        dialout_prefix  = get_dialout_prefix(phone_number, region)
        national_prefix = get_national_prefix(phone_number, region)
        dialout_region  = get_dialout_region(phone_number, region)
        dialout_country = ''
        
        # No dialout prefix without a dialout region, and no dialout region without a prefix
        if((dialout_region && dialout_prefix.empty?) || (!dialout_region && !dialout_prefix.empty?))
          rule_sets = []
        else
          rule_sets = get_rule_sets_for_region(phone_number, dialout_region || region)
        end
        
        # build our total prefix
        if dialout_region
          prefix          = dialout_prefix.delete(' ') + dialout_region.country_code.to_s
          country_code    = dialout_region.country_code.to_s
          dialout_country = country_code
        else
          prefix  = national_prefix
          prefix += dialout_prefix.delete(' ') unless(dialout_prefix.empty?)
        end
        
        # strip the total prefix from the beginning of the number
        phone_number = phone_number[prefix.length..-1]
        number       = phone_number

        prefered_type = 0 # for sorting the priority
        
        # if we're dialing out or using the national prefix
        if(dialout_region || !national_prefix.empty?)
          # we need to sort the rules slightly different
          prefered_type = dialout_region.nil? ? 1 : 2
        end
        
        # sorting for rule priorities
        rule_sets.each do |rule_set|
          rule_set[:rules] = rule_set[:rules].sort_by do |rule|
            # [ prefered rule type ASC, total_digits ASC ]
            [ (rule[:type]==prefered_type) ? -1 : rule[:type], rule[:total_digits], rule[:index] ]
          end
        end
        
        # finally...find our matching rule
        matching_rule = find_matching_rule(phone_number, rule_sets)
        
        # now that know how to format the number, do the formatting work...
        if(matching_rule)
          area_code     = phone_number[matching_rule[:areacode_offset], matching_rule[:areacode_length]]
          number        = phone_number[matching_rule[:areacode_offset]+matching_rule[:areacode_length]..-1]
          phone_number  = format(phone_number, matching_rule[:format].to_s)
        
          # replace 'n' with our national_prefix if it exists
          if(phone_number[/n/])
            phone_number.gsub!(/n{1}/, national_prefix)

            # reset the national_prefix so we don't add it twice
            national_prefix = ''
          end
        end
          
        # strip possible whitespace from the left
        phone_number.lstrip!
        
        if(matching_rule && phone_number[/c/])  
          # format the country code
          if(dialout_prefix == '+')
            phone_number.gsub!(/c{1}/, "+#{dialout_country}")
          else
            phone_number.gsub!(/c{1}/, dialout_country)
            phone_number = "#{dialout_prefix} #{phone_number}" unless dialout_prefix.empty?
          end
        else
          # default formatting
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
        
        # strip possible whitespace
        phone_number.rstrip!
        phone_number.lstrip!
        # remove possible non-numeric characters from the (invalid) number
        number.gsub!(/[^0-9]/,'') if number
        
        # Finally...we can output our parts as a hash
        { :formatted_number => phone_number, :area_code => area_code, :country_code => country_code, :number => number }
      end
      
      private
      # Returns the rule sets that we need to check for a given number and region.
      # The rule_sets are filtered by the length of the number!
      def get_rule_sets_for_region(string, region)
        rule_sets = []
        
        if(region && region.rule_sets)
          rule_sets = region.rule_sets.select do |rule_set|
            rule_set[:digits] <= string.length
          end
        end
        
        rule_sets
      end
      
      # Given any number, find the rule in rule_sets that applies.
      # Returns nil if no matching rule was found!
      def find_matching_rule(number, rule_sets)
        return nil if !number.match(/\A[0-9]+\Z/)
        match = nil
        
        # go through all our given rules
        for rule_set in rule_sets do
          digits = rule_set[:digits]
          prefix = number[0,digits].to_i
          rules  = rule_set[:rules].select { |rule| rule[:total_digits] >= number.length }

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
      
      # According to the region, is this number input trying to dial out?
      def dialing_out?(string, region=nil)
        region ||= PhoneNumber.default_region
        !get_dialout_prefix(string, region).empty?
      end
      
      # Get the dialout prefix from the given string.
      # Returns an empty string if no dialout prefix was found.
      def get_dialout_prefix(string, region=nil)
        region ||= PhoneNumber.default_region
        prefixes = region.dialout_prefixes
        dialout_prefix = ''
        
        # check if we're dialing outside our region
        if string[0].chr == '+'
          dialout_prefix = '+'
        end

        for prefix in prefixes do
          regexp = Regexp.escape(prefix)
          match_str = string
          
          # we have matching wild cards
          if(prefix[/X/] && string =~ Regexp.new("^#{Regexp.escape(prefix.delete('X '))}"))
            regexp.gsub!(/X/, "[0-9]{0,1}")
            match_str = format(string[prefix.scan(/[0-9]/).size, prefix.count('X')], prefix)
            prefix    = match_str
          end
          
          if(match_str =~ Regexp.new("^#{regexp}"))
            dialout_prefix = prefix
            break
          end
        end
        
        dialout_prefix
      end
      
      # Get the national prefix from the given string.
      # Returns an empty string if no national prefix was found.
      def get_national_prefix(string, region=nil)
        region ||= PhoneNumber.default_region
        prefix = region.national_prefix
        national_prefix = ''

        # in case we're not dialing out and the number starts with the national_prefix
        if(!dialing_out?(string, region) && string =~ Regexp.new("^#{Regexp.escape(prefix)}"))
          national_prefix = prefix
        end

        national_prefix
      end
      
      # Get the dialout region by looking at the string.
      # Returns a Region object if we're dialing outside a region that is supported.
      # Otherwise returns nil.
      def get_dialout_region(string, region)
        region ||= PhoneNumber.default_region
        dialout_prefix = get_dialout_prefix(string, region)
        dialout_region = nil
        
        unless dialout_prefix.empty?
          # region codes are 1 to 3 digits
          range_end = [string.length-dialout_prefix.delete(' ').length, 3].min

          (1..range_end).each do |i|
            dialout_region = Region.find(string[dialout_prefix.delete(' ').length, i])
            break if dialout_region
          end
        end
        
        dialout_region
      end
    end
  end

end