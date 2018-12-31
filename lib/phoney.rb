require 'phoney/version'
require 'phoney/rules'
require 'phoney/region'
require 'phoney/formatter'
require 'phoney/parser'

module Phoney
  PLACEHOLDER_CHAR = '#'
  DIGITS           = '0123456789'
  NUMPAD_CHARS     = '+#*'+DIGITS

  class << self
    def format(input, options = {})
      Phoney::Parser.parse(input, options)
    end

    def region
      @region ||= Region[:us]
    end

    def region=(region)
      @region = Region[region.to_s.to_sym]
    end

    def country_code
      @country_code ||= region.country_code.to_s
    end

    def area_code
      @area_code ||= nil
    end

    def area_code=(area_code)
      @area_code = area_code
    end

    def version
      VERSION::STRING
    end
  end
end

# Load our region file when we require the library
Phoney::Region.load
