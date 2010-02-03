require 'rubygems'
require 'active_support'
require File.join(File.dirname(__FILE__), 'region')

# An object representing a phone number.
#
# The phone number is recorded in 3 separate parts:
# * country_code - e.g. '385', '386'
# * area_code - e.g. '91', '47'
# * number - e.g. '5125486', '451588'
#
# All parts are mandatory, but country code and area code can be set for all phone numbers using
# PhoneNumber.default_country_code
# PhoneNumber.default_area_code
#----------------------------------------------------------------------------
class PhoneNumber
  attr_accessor :country_code, :area_code, :number
  
  cattr_accessor :default_country_code
  cattr_accessor :default_area_code
  
  @@named_formats = {
    :default => "+%c%a%n",
    :europe => '+%c (0) %a %f %l',
    :us => "(%a) %f-%l"
  }
  
  #----------------------------------------------------------------------------
  def initialize(*hash_or_args)
    if hash_or_args.first.is_a?(Hash)
      hash_or_args = hash_or_args.first
      keys = {:number => :number, :area_code => :area_code, :country_code => :country_code}
    else
      keys = {:number => 0, :area_code => 1, :country_code => 2}
    end

    self.number = hash_or_args[ keys[:number] ]
    self.area_code = hash_or_args[ keys[:area_code] ] || self.default_area_code
    self.country_code = hash_or_args[ keys[:country_code] ] || self.default_country_code

    raise "Must enter number" if self.number.blank?
    raise "Must enter area code or set default area code" if self.area_code.blank?
    raise "Must enter country code or set default country code" if self.country_code.blank?
  end
  
  # Create a new phone number by parsing a string
  # The format of the string is detect automatically (from FORMATS)
  #----------------------------------------------------------------------------
  def self.parse(phone_number, locale)
    self.format(phone_number, locale)
  end
  
  # Is this string a valid phone number?
  #----------------------------------------------------------------------------
  def self.valid?(string)
    begin
      parse(string).present?
    rescue RuntimeError # if we encountered exceptions (missing country code, missing area code etc)
      return false
    end
  end
  
  private
  # Checks if an input string/char is a valid character
  # that can be typed with a phone numberpad.
  #----------------------------------------------------------------------------
  def self.is_valid_phone_pad_input?(input)
    input =~ /^[0-9*+#]+$/ ? true : false
  end
  
  # Strip all non-numberpad characters from a string
  # => For example: "+45 (123) 023 1.1.1" -> "+45123023111"
  #----------------------------------------------------------------------------
  def self.strip_invalid_characters(phone_number)
    phone_number.scan(/[0-9+*#]/).to_s
  end
  
  #----------------------------------------------------------------------------
  def self.format(phone_number, locale)
    input = strip_invalid_characters(phone_number)
    res = ""
    idx = 0
    formats = []
    
    # if the input starts with '+X', add all formats of all regions that start with '+X'
    if(input.length > 1 && input[0,1] == '+')
      formats += Region.find_formats_with(Regexp.new("^[+]#{input[1,1]}"))
    end
    
    formats += Region.find(locale.downcase).formats

    # Go through each formatting expression in the formats array
    formats.each_with_index do |fmt,index|
      idx = index
      i = 0
      p = 0
      temp = ""
      
      # Finite State Machine where the magic happens
      # The loop breaks once a 'match' is found, which is why we had to sort the formats array!
      while(temp != nil && i < input.length && p < fmt.length) do
        c = fmt[p,1]
        required = is_valid_phone_pad_input?(c)
        next_input = input[i,1]

        case c
        when '$'
          temp += next_input
          i += 1
          p -= 1
        when '#'
          temp += next_input
          i += 1
        else
          if(required)
            if(next_input != c)
              temp = nil
              break
            end
            temp += next_input
            i += 1
          else
            temp += c
            if(next_input == c)
              i += 1
            end
          end
        end

        p += 1
      end

      if(i == input.length)
        res = temp
        break
      end
    end

    if(res.length == 0)
      return input
    end
    
    # puts "formatting rule that applies: #{formats[idx]}"
    return res
  end

end
