require 'phoney/test_helper'

class FRRegionTest < MiniTest::Unit::TestCase
  def setup
    Phoney.region = "fr"
  end
  
  def test_pattern_precedence
    assert_equal "8123", Phoney::Parser.parse("8123")
    assert_equal "812 34", Phoney::Parser.parse("81234")
    
    assert_equal "0812", Phoney::Parser.parse("0812")
    assert_equal "0812 3", Phoney::Parser.parse("08123")
    
    assert_equal "01 23 45", Phoney::Parser.parse("012345")
  end
end