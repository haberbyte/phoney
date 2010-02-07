require 'strscan'
require File.join(File.dirname(__FILE__), 'region')

class Parser

  #----------------------------------------------------------------------------
  def self.parse(phone_number, region_code)
    phone_number = normalize(phone_number.to_s)
    
    # we don't really need to do anything unless we get more input
    return phone_number unless phone_number.length > 1
    
    region            = Region.find(region_code)
    country_code      = region.country_code.to_s
    dialout_prefixes  = region.dialout_prefixes
    
    national_prefix = ''
    dialout_prefix  = ''
    dialout_country = ''
    dialout_region  = nil
    rule_sets       = []
    matching_rule   = nil
    
    # check if we're dialing outside our region
    if phone_number[0].chr == '+'
      dialout_prefix = '+'
    else
      for prefix in dialout_prefixes do
        if(phone_number =~ Regexp.new("^#{prefix}"))
          dialout_prefix = prefix
          break
        end
      end
    end
    
    # in case we're not dialing out and the number starts with the national_prefix
    if(dialout_prefix.empty? && phone_number =~ Regexp.new("^#{region.national_prefix}"))
      national_prefix = region.national_prefix
    end
    
    unless dialout_prefix.empty?
      # we're dialing outside our region
      # region codes are 1 to 3 digits
      range_end = [phone_number.length-dialout_prefix.length, 3].min
      
      (1..range_end).each do |i|
        dialout_region = Region.find(phone_number[dialout_prefix.length, i])
        break if dialout_region
      end
    end
    
    if dialout_region
      prefix          = dialout_prefix + dialout_region.country_code.to_s
      dialout_country = dialout_region.country_code.to_s
    else
      prefix  = national_prefix
      prefix += dialout_prefix unless(dialout_prefix.empty?)
    end
    
    # strip the prefixes from the beginning of the number
    phone_number = phone_number[prefix.length..-1]
    
    # set different rule sets depending on our destination region
    if(dialout_region)
      rule_sets = dialout_region.rule_sets.select do |set|
        set[:digits] <= phone_number.length
      end
    else
      rule_sets = region.rule_sets.select do |set|
        set[:digits] <= phone_number.length
      end
    end
    
    # finally, go through all our rules
    for rule_set in rule_sets do
      found  = false
      digits = rule_set[:digits]
      number = phone_number[0,digits].to_i
      rules  = rule_set[:rules].select { |rule| rule[:total_digits] >= phone_number.length }
      
      # if we're dialing out or using the national prefix
      if(dialout_region || !national_prefix.empty?)
        # we need to sort the rules slightly different
        # [rule type DESC, total_digits ASC]
        rules = rules.sort_by { |rule| [ -rule[:type], rule[:total_digits] ] }
      end

      rules.each do |rule|
        if(number >= rule[:min] && number <= rule[:max])
          found         = true
          phone_number  = format(phone_number, rule[:format].to_s)
          matching_rule = rule # remember the rule that matched
          
          break
        end
      end
      
      break if found
    end
    
    # replace 'n' with our national_prefix if it exists
    if(phone_number[/n/])
      phone_number.gsub!(/n{1}/, national_prefix)
      
      # reset the national_prefix so we don't add it twice
      national_prefix = ''
    end
    
    phone_number.lstrip!
    
    if(phone_number[/c/])
      # we have a specific country code formatting rule
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

    phone_number.rstrip
  end

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
  # fixchar -- The single-character placeholder. Default is 'X'.
  #----------------------------------------------------------------------------
  def self.format(string, pattern, fixchar='X')
    raise ArgumentError.new("First parameter 'string' must be a String") unless string.is_a?(String)
    raise ArgumentError.new("#{fixchar} too long") if fixchar.length > 1

    slots = pattern.count(fixchar)

    # Return the string if it doesn't fit and we shouldn't even try,
    return string if string.length > slots

    # Make the result.
    scanner = ::StringScanner.new(pattern)
    regexp  = Regexp.new(Regexp.escape(fixchar))
    index   = 0
    result  = ''

    while(!scanner.eos? && index < string.length)
      if scanner.scan(regexp) then
        result += string[index].chr
        index  += 1
      else
        result += scanner.getch
      end
    end

    result
  end
  
  # Strips all non-numberpad characters from a string
  # => For example: "+45 (123) 023 1.1.1" -> "+45123023111"
  #----------------------------------------------------------------------------
  def self.normalize(string_with_number)
    string_with_number.scan(/[0-9+*#]/).to_s
  end
  
end