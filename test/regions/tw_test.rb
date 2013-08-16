require 'phoney/test_helper'

class TWRegionTest < MiniTest::Unit::TestCase
  def setup
    Phoney.region = "tw"
  end
  
  def test_pattern_with_trunk_prefix_but_without_flags
    assert_equal "+886 (0) 2", Phoney::Parser.parse("+88602")
    assert_equal "+886 023", Phoney::Parser.parse("+886023")
    assert_equal "+886 0123", Phoney::Parser.parse("+8860123")
    assert_equal "+886 (0) 1234", Phoney::Parser.parse("+88601234")
    
    assert_equal "+886 (0) 201-23456", Phoney::Parser.parse("+886020123456")
  end
  
  def test_different_dialout_prefixes
    assert_equal "000 1 (704)", Phoney::Parser.parse("0001704")
    assert_equal "001 1 (704)", Phoney::Parser.parse("0011704")
    assert_equal "002 1 (704)", Phoney::Parser.parse("0021704")
    assert_equal "003 1 (704)", Phoney::Parser.parse("0031704")
    
    assert_equal "010 1 (704)", Phoney::Parser.parse("0101704")
    assert_equal "011 1 (704)", Phoney::Parser.parse("0111704")
    assert_equal "012 1 (704)", Phoney::Parser.parse("0121704")
    assert_equal "013 1 (704)", Phoney::Parser.parse("0131704")
  end
end