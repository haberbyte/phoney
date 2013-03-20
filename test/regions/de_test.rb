require 'phoney/test_helper'

class DERegionTest < MiniTest::Unit::TestCase
  def setup
    PhoneNumber.region = :de
  end
  
  def test_plus_and_trunk_prefix_start
    assert_equal "+0", PhoneNumber::Parser.parse("+0")
    assert_equal "+00", PhoneNumber::Parser.parse("+00")
  end

  def test_output_the_correct_format
    # with national prefix '0'
    assert_equal "040 789554488", PhoneNumber::Parser.parse("040789554488")
    # without national prefix '0'
    assert_equal "40 789554488", PhoneNumber::Parser.parse("40789554488")
  end
  
  def test_guessing_current_format_correctly
    assert_equal "04", PhoneNumber::Parser.parse("04")
    assert_equal "040", PhoneNumber::Parser.parse("040")
    assert_equal "040 7", PhoneNumber::Parser.parse("0407")
      
    assert_equal "4", PhoneNumber::Parser.parse("4")
    assert_equal "40", PhoneNumber::Parser.parse("40")
    assert_equal "40 7", PhoneNumber::Parser.parse("407")
    
    assert_equal "+49 4", PhoneNumber::Parser.parse("+494")
    assert_equal "+49 40", PhoneNumber::Parser.parse("+4940")
    assert_equal "+49 40 7", PhoneNumber::Parser.parse("+49407")
    assert_equal "+49 40 70", PhoneNumber::Parser.parse("+494070")
    assert_equal "+49 40 705", PhoneNumber::Parser.parse("+4940705")
    assert_equal "+49 40 7055", PhoneNumber::Parser.parse("+49407055")
    assert_equal "+49 40 70558", PhoneNumber::Parser.parse("+494070558")
    
    assert_equal "00 49 4", PhoneNumber::Parser.parse("00494")
    assert_equal "00 49 40", PhoneNumber::Parser.parse("004940")
    assert_equal "00 49 40 7", PhoneNumber::Parser.parse("0049407")
    assert_equal "00 49 40 70", PhoneNumber::Parser.parse("00494070")
    assert_equal "00 49 40 705", PhoneNumber::Parser.parse("004940705")
    assert_equal "00 49 40 7055", PhoneNumber::Parser.parse("0049407055")
    assert_equal "00 49 40 70558", PhoneNumber::Parser.parse("00494070558")
  end
end