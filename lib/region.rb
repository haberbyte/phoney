class Region
  attr_reader :region_code, :name, :country_code, :char_2_code, :char_3_code, :area_code, :formats
  
  @@all_regions = nil
  
  #----------------------------------------------------------------------------
  def self.all
    return @@all_regions unless @@all_regions.nil?
    
    data_file = File.join(File.dirname(__FILE__), '..', 'data', 'regions.yml')

    @@all_regions = []
    YAML.load(File.read(data_file)).each_pair do |key, r|
      new_region = Region.new(key, r[:name], r[:country_code], r[:char_2_code], r[:char_3_code], r[:area_code], r[:formats])
      @@all_regions.push(new_region)
    end
    @@all_regions
  end
  
  #----------------------------------------------------------------------------
  def self.find(param)
    param = param.to_s
    
    all.detect do |region|
      region.region_code.downcase == param || region.country_code == param
    end
  end
  
  #----------------------------------------------------------------------------
  def self.[](param)
    find(param)
  end
  
  #----------------------------------------------------------------------------
  def initialize(region_code, name, country_code, char_2_code, char_3_code, area_code, formats)
    @region_code = region_code
    @name = name
    @country_code = country_code
    @char_2_code = char_2_code
    @char_3_code = char_3_code
    @area_code = area_code
    @formats = formats
    @formats_sorted = nil
  end
  
  def formats
    @formats_sorted = sort_formats(@formats) unless @formats_sorted
    @formats_sorted
  end
    
  #----------------------------------------------------------------------------
  def to_s
    "#{@char_3_code} - #{@name} (+#{@country_code})"
  end
  
  #----------------------------------------------------------------------------
  def self.find_formats_with(regex)
    formats = []
    
    for record in self.all do
      record.formats.each do |format|
        formats.push(format) if format =~ regex
      end
    end
    
    formats
  end
    
  def self.get_region_formats(code)
    region_formats = {}
    
    for format in find(code).formats do
      region_formats.merge!({:region => code, :format => format})
    end
  end
  
  #----------------------------------------------------------------------------
  def country_code_regexp
    Regexp.new("^[+]#{country_code}")    
  end
  
  private
  # Sorts the formats array accordingly.
  #
  # For example, let's assume the following formats array:
  # => ["### ###", "00 $", "+1 ###-###", "+1 432 ### ### ###"]
  #
  # This should be sorted in a way that phone pad characters (0-9,+,*) are
  # all treated lexicographically as the same value.
  # More specific formatting expressions should be first (e.g. "1##" before "###")
  #
  # => Our example should turn out as:
  # => ["00 $", "+1 432 ### ### ###", "+1 ###-###", "### ###"]
  #----------------------------------------------------------------------------
  def sort_formats(formats)
    formats.sort do |x,y|
      # x = x.gsub(/[0-9*+]/, '0') # Treat all phone pad characters as 0
      # y = y.gsub(/[0-9*+]/, '0')
      
      # Use ljust so that '###' is before '#####'
      x = strip_invalid_characters(x).ljust(256, '*')
      y = strip_invalid_characters(y).ljust(256, '*')
      
      y <=> x
    end
  end
  
  # Checks if an input string/char is a valid character
  # that can be typed with a phone numberpad.
  #----------------------------------------------------------------------------
  def is_valid_phone_pad_input?(input)
    input =~ /^[0-9*+#]+$/ ? true : false
  end
  
  # Strip all non-numberpad characters from a string
  # => For example: "+45 (123) 023 1.1.1" -> "+45123023111"
  #----------------------------------------------------------------------------
  def strip_invalid_characters(phone_number)
    phone_number.scan(/[0-9+*#]/).to_s
  end
  
end
