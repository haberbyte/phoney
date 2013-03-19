require 'phoney/test_helper'

class TWRegionTest < MiniTest::Unit::TestCase
  def setup
    PhoneNumber.region = "tw"
  end
  
  def test_pattern_with_trunk_prefix_and_country
    assert_equal "+886 (0) 2", PhoneNumber::Parser.parse("+88602")
    assert_equal "+886 023", PhoneNumber::Parser.parse("+886023")
    assert_equal "+886 0123", PhoneNumber::Parser.parse("+8860123")
    assert_equal "+886 (0) 1234", PhoneNumber::Parser.parse("+88601234")
  end
end