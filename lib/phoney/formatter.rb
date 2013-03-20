module PhoneNumber
  module Formatter
    # Returns the string formatted according to a pattern.
    #
    # Examples:
    # format('123456789', 'XXX-XX-XXXX')
    #    => "123-45-6789"
    # format('12345', 'XXX-XX-XXXX')
    #    => "123-45"
    #
    # Parameters:
    # string  -- The string to be formatted.
    # pattern -- The format string, see above examples.
    # fill    -- A string for padding. If the empty string, then the pattern is
    #            filled as much as possible, and the rest of the pattern is
    #            truncated. If nil, and the string is too long for the pattern,
    #            the string is returned unchanged.  Otherwise, the string is
    #            padded to fill the pattern, which is not truncated.
    def format(input, pattern, options={})
      fill         = options[:fill]
      intl_prefix  = options[:intl_prefix]||''
      trunk_prefix = options[:trunk_prefix]||''
      slots        = pattern.count(PLACEHOLDER_CHAR)
      
      # Return original input if it is too long
      return input if (fill.nil? && input.length > slots)
      
      # Pad and clone the string if necessary.
      source = (fill.nil? || fill.empty?) ? input : input.ljust(slots, fill)
      
      result   = ''
      slot     = 0
      has_open = had_c = had_n = false
      
      pattern.split('').each_with_index do |chr, index|
        case chr
        when 'c'
          had_c = true
          result << intl_prefix
        when 'n'
          had_n = true
          result << trunk_prefix
        when '#'
          if slot < source.length
            result << source[slot]
            slot += 1
          else
            result << ' ' if has_open
          end
        when '('
          if slot < source.length
            has_open = true
            result << chr
          end
        when ')'
          if (slot < source.length || has_open)
            has_open = false
            result << chr
          end
        else
          # Don't show space after n if no trunk prefix or after c if no intl prefix
          next if (chr == ' ' && pattern[index-1] == 'n' && trunk_prefix.empty?)
          next if (chr == ' ' && pattern[index-1] == 'c' && intl_prefix.empty?)
          
          result << chr if (slot < source.length)
        end
      end

      # Not all format strings have a 'c' or 'n' in them.
      # If we have an international prefix or a trunk prefix but the format string
      # doesn't explictly say where to put it then simply add it to the beginning.
      result.prepend trunk_prefix if (!had_n && !trunk_prefix.empty?)
      result.prepend "#{intl_prefix} " if (!had_c && !intl_prefix.empty?)
      
      result.strip
    end
    
    # Strips all non-numberpad characters from a string
    # => For example: "+45 (123) 023 1.1.1" -> "+45123023111"
    def normalize(str)
      str.gsub(/[^0-9+*#]/,'') unless str.nil?
    end
    
    def international_call_prefix_for(input, options={})
      options[:region] ||= PhoneNumber.region
      
      return nil if input.length == 0
      
      options[:region].dialout_prefixes.each do |prefix|
        stripped_prefix = Regexp.escape prefix.delete(' ').split('->').first[0, input.length]
        regexp = Regexp.new "^#{stripped_prefix.gsub('\\#', '[0-9]')}"
          
        return format(input, prefix.gsub(/[\\+0-9]/, '#'), fill: '') if input =~ regexp
        
        if (input.start_with?('+') && (stripped_prefix.start_with?(input[1..-1]) || input[1..-1] =~ regexp))
          return format(input, '#'+prefix.gsub(/[\\+0-9]/, '#'), fill: '')
        end
      end
      
      input.start_with?('+') ? '+' : nil
    end
    
    # TODO: handle case where international call prefix implicitly specifies country (e.g. tz: "005->254")
    def extract_country_code(input, options={})
      options[:region] ||= PhoneNumber.region
      intl_prefix = international_call_prefix_for(input, region: options[:region])
      
      # only try to extract a country code if we're dialing internationally
      if intl_prefix
        rest   = input[intl_prefix.count(NUMPAD_CHARS)..-1]
        region = PhoneNumber::Region.all.find { |r| rest.start_with? r.country_code.to_s }
        
        region.country_code.to_s if region
      end
    end
    
    def extract_trunk_prefix(input, options={})
      options[:region] ||= PhoneNumber.region
      
      intl_prefix  = international_call_prefix_for input
      country_code = extract_country_code(input, region: options[:region])
      region_scope = country_code.nil? ? options[:region] : PhoneNumber::Region[country_code]
      
      if intl_prefix
        # Strip international prefix from number
        input = input[intl_prefix.count(NUMPAD_CHARS)..-1]
      end
      
      if country_code
        # Strip country code from number
        input = input[country_code.count(DIGITS)..-1]
      end
      
      region_scope.trunk_prefixes.each do |prefix|
        stripped_prefix = Regexp.escape prefix.delete(' ')
        regexp = Regexp.new "^#{stripped_prefix.gsub('\\#', '[0-9]')}"
      
        return format(input, prefix.gsub(/[0-9]/, '#'), fill: '') if input =~ regexp
      end
      
      return nil
    end
  end
end