class PhoneNumber
  attr_accessor :country_code, :prefix_code, :area_code, :number
  
  class << self
    def default_region
      @@region ||= Region[:us]
    end

    def default_region=(region)
      if region.is_a?(Region)
        @@region = region
      else
        @@region = Region[region.to_s.to_sym]
      end
    end

    def default_country_code
      @@country_code ||= default_region.country_code.to_s
    end

    def default_country_code=(country_code)
      @@country_code = country_code
    end

    def default_area_code
      @@area_code ||= nil
    end

    def default_area_code=(area_code)
      @@area_code = area_code
    end
    
    def version
      VERSION::STRING
    end
  end

  def initialize(params, region_code=nil)
    region       = Region.find(region_code)
    country_code = region.country_code.to_s if region
    
    if params.is_a?(String)
      params = Parser.parse_to_parts(params, region_code)
    end 

    self.number = params[:number].to_s
    # The rare case when some digits are in front of the area code
    self.prefix_code = params[:prefix_code].to_s
    # Can be empty, because some special numbers just don't have an area code (e.g. 911)
    self.area_code = params[:area_code].to_s || self.class.default_area_code
    self.country_code = params[:country_code].to_s || country_code || self.class.default_country_code
    
    raise "Must enter number" if(self.number.nil? || self.number.empty?)
    raise "Must enter country code or set default country code" if(self.country_code.nil? || self.country_code.empty?)
  end

  # Does this number belong to the default country code?
  def has_default_country_code?
    country_code.to_s == self.class.default_country_code.to_s
  end

  # Does this number belong to the default area code?
  def has_default_area_code?
    (!area_code.to_s.empty? && area_code.to_s == self.class.default_area_code.to_s)
  end
  
  # Formats the phone number.
  # If the method argument is a String, it is used as a format string, with the following fields being interpolated:
  #
  # * %c - country_code (385)
  # * %a - area_code (91)
  # * %n - number (5125486)
  #
  # If the method argument is a Symbol, we use one of the default formattings and let the parser do the rest.
  def format(fmt)
    if fmt.is_a?(Symbol)
      case fmt
      when :default
        Parser::parse("+#{country_code} #{prefix_code}#{area_code} #{number}", country_code)
      when :national
        Parser::parse("#{area_code} #{number}", country_code)
      when :local
        STDERR.puts "Warning: Using local format without setting a default area code!?" if PhoneNumber.default_area_code.nil?
        Parser::parse(number, country_code)
      else
        raise "The format #{fmt} doesn't exist'"
      end
    else
      format_number(fmt)
    end
  end

  # The default format is the canonical format: "+{country_code} {area_code} {number}"
  def to_s
    format(:default)
  end
  
  private
  def format_number(fmt)
    fmt.gsub("%c", country_code || "").gsub("%a", area_code || "").gsub("%n", number || "")
  end
end
