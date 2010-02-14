class PhoneNumber
  
  module Utils
    
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
    def format(string, pattern, fixchar='X')
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
    def normalize(string_with_number)
      string_with_number.gsub(/[^0-9+*#]/,'') unless string_with_number.nil?
    end
    
  end
  
end