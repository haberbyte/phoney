require 'phoney/test_helper'

class USRegionTest < MiniTest::Unit::TestCase
  def setup
    PhoneNumber.default_region = :us
  end
  
  def test_format_phone_number
    assert_equal PhoneNumber::Parser.parse("5689780"), "568-9780"
    assert_equal PhoneNumber::Parser.parse("7045689780"), "(704) 568-9780"
    assert_equal PhoneNumber::Parser.parse("17045689780"), "1 (704) 568-9780"
  end
  
  def test_as_you_type_formatting
    assert_equal PhoneNumber::Parser.parse("+17"), "+1 (7"
    assert_equal PhoneNumber::Parser.parse("+171"), "+1 (71"
    assert_equal PhoneNumber::Parser.parse("+1712"), "+1 (712"
    assert_equal PhoneNumber::Parser.parse("+171234"), "+1 (712) 34"
    assert_equal PhoneNumber::Parser.parse("+1712345"), "+1 (712) 345"
    assert_equal PhoneNumber::Parser.parse("+17123456"), "+1 (712) 345-6"
  end
  
  def test_fallback_for_invalid_phone_number
    # the number is too long for [:us]
    assert_equal PhoneNumber::Parser.parse("+1704123456789"), "+1 704123456789"
  end
end