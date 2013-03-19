require 'phoney/test_helper'

class FRRegionTest < MiniTest::Unit::TestCase
  def setup
    PhoneNumber.region = "fr"
  end
  
  def test_pattern_precedence
    assert_equal "8123", PhoneNumber::Parser.parse("8123")
    assert_equal "812 34", PhoneNumber::Parser.parse("81234")
    
    assert_equal "0812", PhoneNumber::Parser.parse("0812")
    assert_equal "0812 3", PhoneNumber::Parser.parse("08123")
    
    assert_equal "01 23 45", PhoneNumber::Parser.parse("012345")
  end
end