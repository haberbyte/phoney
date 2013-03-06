require 'yaml'

class Country
  attr_accessor :international_prefix, :code, :offset
  attr_accessor :desc_len, :desc_count, :disp_scheme_offset, :rules_sets_count
  attr_accessor :trunk_prefixes
  attr_accessor :dialout_prefixes
end

io = File.open("Default.phoneformat", "rb")
num_countries = io.read(4).unpack("V")[0]
countries = []

(1..num_countries).each do
  country = Country.new
  country.international_prefix, country.code, country.offset = io.read(12).unpack("a4/a4/V")
  
  country.international_prefix = country.international_prefix.delete("\000")
  country.code = country.code.delete("\000")
  
  countries << country
end

data = io.read

countries.each do |c|
  c.desc_len, c.desc_count, c.disp_scheme_offset, c.rules_sets_count = data[c.offset, 12].unpack("v/v/V/V")
  
  local_nat_raw = data[c.offset+12, c.desc_len-12].unpack("A*")
  
  c.trunk_prefixes = local_nat_raw.to_s.delete('"[]').split('\0\0').first.split('\0').reject(&:empty?) rescue []
  c.dialout_prefixes = local_nat_raw.to_s.delete('"[]').split('\0\0').last.split('\0').reject(&:empty?) rescue []
  
  rules_offset = c.offset+c.desc_len                 # points to the rules section
  scheme_base  = rules_offset+c.disp_scheme_offset   # points to the scheme section
  
  puts ":#{c.code}:"
  puts "  :country_code: #{c.international_prefix}"
  puts "  :country_abbr: :#{c.code}"
  puts "  :trunk_prefixes: #{c.trunk_prefixes}"
  puts "  :dialout_prefixes: #{c.dialout_prefixes}"
  puts "  :rule_sets:"
  
  (0..(c.rules_sets_count-1)).each do |rule_set_idx|
    digits, rules_count = data[rules_offset, 4].unpack("v/v")
    
    puts "  - :digits: #{digits}"
    puts "    :rules:"
    
    # iterate over individual rules
    (0..(rules_count-1)).each do |rule_idx|
      # each rule is 16 bytes
      prefix_min,prefix_max,unkn1,total_digits,areacode_offset,areacode_length,unkn2,unkn3,scheme_offset = data[rules_offset+4+rule_idx*16, 16].unpack("V/V/C/C/C/C/C/C/v")
      # now extract the rule scheme 
      scheme = data[scheme_base+scheme_offset, data[(scheme_base+scheme_offset)..-1].index(("\x00"))]
      
      puts "      - :type: #{unkn2}"
      puts "        :min: #{prefix_min}"
      puts "        :max: #{prefix_max}"
      puts "        :total_digits: #{total_digits}"
      puts "        :areacode_length: #{areacode_length}"
      puts "        :areacode_offset: #{areacode_offset}"
      puts "        :unknown1: #{unkn1}"
      puts "        :unknown2: #{unkn2}"
      puts "        :unknown3: #{unkn3}"
      puts "        :format: \"#{scheme}\""
    end
    
    rules_offset += (4 + rules_count*16) # move to next rules-set 
  end
end
