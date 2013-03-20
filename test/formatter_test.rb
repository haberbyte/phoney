require 'phoney/test_helper'

class FormatterTest < MiniTest::Unit::TestCase
  include PhoneNumber::Formatter
  
  def setup
    PhoneNumber.region = 'us'
  end
  
  def test_international_call_prefix_for_us_region
    assert_equal "0", international_call_prefix_for("0")
    assert_equal "01", international_call_prefix_for("01")
    assert_equal "011", international_call_prefix_for("011")
    assert_equal "011", international_call_prefix_for("011999")
    assert_equal nil, international_call_prefix_for("123")
  end
  
  def test_international_call_prefix_for_br_region
    assert_equal "+00", international_call_prefix_for("+0055123", region: PhoneNumber::Region["br"])
    assert_equal "00 55", international_call_prefix_for("0055123", region: PhoneNumber::Region["br"])
    assert_equal "00 12", international_call_prefix_for("0012456", region: PhoneNumber::Region["br"])
    assert_equal nil, international_call_prefix_for("03001234567", region: PhoneNumber::Region["br"])
  end
  
  def test_international_call_prefix_with_plus_sign
    assert_equal "+011", international_call_prefix_for("+011")
    assert_equal "+", international_call_prefix_for("+123")
    assert_equal "+", international_call_prefix_for("+")
  end
  
  def test_formatting_international_call_with_non_exiting_country
    assert_equal "+99", format("+99", "###")
    
    assert_equal "+99", PhoneNumber::Parser.parse("+99")
    assert_equal "+999999999", PhoneNumber::Parser.parse("+999999999")
    
    assert_equal "011 99", PhoneNumber::Parser.parse("01199")
    assert_equal "011 999999999", PhoneNumber::Parser.parse("011999999999")
  end
  
  def test_international_calling_prefix_for_empty_number
    assert_equal nil, international_call_prefix_for("")
  end
  
  def test_country_code_extraction
    assert_equal "49", extract_country_code("+49")
    assert_equal "49", extract_country_code("01149")
    assert_equal "49", extract_country_code("01149123456")
    assert_equal "1", extract_country_code("0111234567")
    assert_equal nil, extract_country_code("03001234567", region: PhoneNumber::Region["br"])
  end
  
  def test_nonexisting_country_code
    assert_equal nil, extract_country_code("+99")
    assert_equal nil, extract_country_code("01199")
  end
  
  def test_trunk_prefix_extraction
    assert_equal "1", extract_trunk_prefix("+117041234567")
    assert_equal "0", extract_trunk_prefix("+49040")
    assert_equal nil, extract_trunk_prefix("+1705")
    assert_equal nil, extract_trunk_prefix("+1")
    assert_equal nil, extract_trunk_prefix("+4940")
    
    assert_equal "1", extract_trunk_prefix("011117041234567")
    assert_equal nil, extract_trunk_prefix("011705")
    assert_equal "0", extract_trunk_prefix("01149040")
  end
  
  def test_format_international_number_with_trunk_prefix
    assert_equal "+1 (1) (704) 205-1234", PhoneNumber::Parser.parse("+117042051234")
    assert_equal "+49 (0) 40 1234567", PhoneNumber::Parser.parse("+490401234567")
    assert_equal "011 1 (1) (704) 205-1234", PhoneNumber::Parser.parse("011117042051234")
    assert_equal "011 49 (0) 40 1234567", PhoneNumber::Parser.parse("011490401234567")
  end
  
  def test_format_string_without_prefixes
    assert_equal "123", format("123", "n ###")
    assert_equal "123", format("123", "c ###")
    assert_equal "123", format("123", "c n ###")
  end
  
  def test_format_number_with_double_international_prefix
    assert_equal "+011 49 40", PhoneNumber::Parser.parse("+0114940")
  end
  
  def test_international_prefix_with_plus_and_trunk_prefix_start
    assert_equal "+0", international_call_prefix_for("+0", region: PhoneNumber::Region["de"])
    assert_equal "+00", international_call_prefix_for("+00", region: PhoneNumber::Region["de"])
  end
end