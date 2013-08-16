module Phoney
  # Helper module that maps vanity numbers to digit numbers.
  module Vanity
    VANITY_REGEXP = /\A\d{3}[a-zA-Z]{6,12}\Z/
    VANITY_NORMALIZING_REGEXP = /^0*|[^\d\w]/
    
    # Returns a char to number mapping string for the String#tr method.
    def self.mapping
      @@mapping ||= [
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.freeze,
        '2223334445556667777888999922233344455566677778889999'.freeze
      ]
    end
    
    # Replaces (and normalizes) vanity characters of passed number with correct digits.
    def self.replace number
      number.tr *mapping
    end
    
    # Returns true if there is a character in the number
    # after the first four numbers.
    def self.vanity? number
      !(normalized(number) =~ VANITY_REGEXP).nil?
    end
    
    # Vanity-Normalized.
    def self.normalized number
      number.gsub VANITY_NORMALIZING_REGEXP, ''
    end
  end
end