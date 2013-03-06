require 'phoney/test_helper'

class BRRegionTest < MiniTest::Unit::TestCase
  def setup
    PhoneNumber.default_region = :br
  end
  
  def test_format_brazil_phone_number
    assert_equal PhoneNumber::Parser.parse("03001234567"), "0300 123-4567"
     
    assert_equal PhoneNumber::Parser.parse("123"), "123"
    assert_equal PhoneNumber::Parser.parse("1234"), "123-4"
    assert_equal PhoneNumber::Parser.parse("12345"), "123-45"
    assert_equal PhoneNumber::Parser.parse("123456"), "123-456"
    assert_equal PhoneNumber::Parser.parse("1234567"), "123-4567"
    assert_equal PhoneNumber::Parser.parse("12345678"), "1234-5678"
    assert_equal PhoneNumber::Parser.parse("123456789"), "(12) 3456-789"
    assert_equal PhoneNumber::Parser.parse("1234567891"), "(12) 3456-7891"
    assert_equal PhoneNumber::Parser.parse("12345678910"), "123 4567-8910"
    assert_equal PhoneNumber::Parser.parse("123456789100"), "(12 34) 5678-9100"
  end
  
  def test_guessing_current_format_correctly
    assert_equal PhoneNumber::Parser.parse("+17"), "+1 (7"
    assert_equal PhoneNumber::Parser.parse("+171"), "+1 (71"
    assert_equal PhoneNumber::Parser.parse("+1712"), "+1 (712"
    assert_equal PhoneNumber::Parser.parse("+171234"), "+1 (712) 34"
    assert_equal PhoneNumber::Parser.parse("+1712345"), "+1 (712) 345"
    assert_equal PhoneNumber::Parser.parse("+17123456"), "+1 (712) 345-6"
  end
end