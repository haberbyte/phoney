require 'phoney/test_helper'

class UARegionTest < MiniTest::Unit::TestCase
  def setup
    PhoneNumber.region = "ua"
  end
  
  def test_guessing_current_format_correctly
    assert_equal "+380 0222", PhoneNumber::Parser.parse("+3800222")
    assert_equal "+380 0 22 22", PhoneNumber::Parser.parse("+38002222")
    assert_equal "+380 02 22 22", PhoneNumber::Parser.parse("+380022222")
    assert_equal "+380 022 22 22", PhoneNumber::Parser.parse("+3800222222")
    assert_equal "+380 (0) 222 22 22", PhoneNumber::Parser.parse("+38002222222")
    assert_equal "+380 (0222) 2 22 22", PhoneNumber::Parser.parse("+380022222222")
    
    assert_equal "+380 (222) 2 22 22", PhoneNumber::Parser.parse("+38022222222")
  end
end