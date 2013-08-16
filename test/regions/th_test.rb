require 'phoney/test_helper'

class THRegionTest < MiniTest::Unit::TestCase
  def setup
    Phoney.region = "th"
  end
  
  def test_guessing_current_format_correctly
    assert_equal "+66", Phoney::Parser.parse("+66")
    assert_equal "+66 2", Phoney::Parser.parse("+662")
    assert_equal "+66 2-3", Phoney::Parser.parse("+6623")
    assert_equal "+66 2-34", Phoney::Parser.parse("+66234")
    assert_equal "+66 2-345", Phoney::Parser.parse("+662345")
    assert_equal "+66 2-345-6", Phoney::Parser.parse("+6623456")
    assert_equal "+66 2-345-67", Phoney::Parser.parse("+66234567")
    assert_equal "+66 2-345-678", Phoney::Parser.parse("+662345678")
    assert_equal "+66 2-345-6789", Phoney::Parser.parse("+6623456789")
  end
  
  def test_non_matching_call
    assert_equal "+66 1234567", Phoney::Parser.parse("+661234567")
    assert_equal "1234567", Phoney::Parser.parse("1234567")
    assert_equal "001 66 1234567", Phoney::Parser.parse("001661234567")
  end
  
  def test_pattern_with_dialout_prefix
    assert_equal "+668-1234-5678", Phoney::Parser.parse("+668-1234-5678")
    assert_equal "001 668-1234-5678", Phoney::Parser.parse("00166812345678")
    assert_equal "+668-0123-4567", Phoney::Parser.parse("+668-0123-4567")
    assert_equal "+66 8012345678", Phoney::Parser.parse("+66 8012345678")
  end
  
  def test_pattern_with_trunk_prefix_and_country
    assert_equal "+66 (0)8-1234-5678", Phoney::Parser.parse("+660812345678")
    assert_equal "+66 (0)9-1234-5678", Phoney::Parser.parse("+660912345678")
    assert_equal "+66 (0) 2-345-6789", Phoney::Parser.parse("+66023456789")
  end
end