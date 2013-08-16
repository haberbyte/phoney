module Phoney
  class RuleGroup
    attr_reader :significant_digits, :rules
    
    def initialize(significant_digits, rules=[])
      @significant_digits = significant_digits
      @rules = []
      
      rules.each do |rule|
        add_rule Rule.new(rule)
      end
    end
    
    def add_rule(rule)
      @rules.push rule
    end
    
    def delete_rule(rule)
      @rules.delete rule
    end
    
    def <=>(other)
      other.significant_digits <=> significant_digits
    end
  end
  
  class Rule
    attr_reader :max_digits, :min_value, :max_value, :areacode_length, :areacode_offset, :pattern
    
    def initialize(options={})
      @max_digits = options[:max_digits]
      
      @min_value = options[:min_value]
      @max_value = options[:max_value]
      
      @areacode_length = options[:areacode_length]
      @areacode_offset = options[:areacode_offset]
      
      @pattern = options[:pattern]
      @flags   = options[:flags]
    end
    
    def <=>(other)
      max_digits <=> other.max_digits
    end
    
    def matches?(number)
      value = number.to_s[0, max_value.to_s.length].to_i
      (min_value..max_value).member?(value) && number.length <= max_digits
    end
    
    def flags
      @flags || []
    end
  end
end