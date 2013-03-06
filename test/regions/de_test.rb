require 'phoney/test_helper'

class DERegionTest < MiniTest::Unit::TestCase
  def setup
    PhoneNumber.default_region = :de
  end

  def test_output_the_correct_format
    # with national prefix '0'
    assert_equal PhoneNumber::Parser.parse("040789554488"), "040 789554488"
    # without national prefix '0'
    assert_equal PhoneNumber::Parser.parse("40789554488"), "40 789554488"
  end
  
  def test_guessing_current_format_correctly
    assert_equal PhoneNumber::Parser.parse("04"), "04"
    assert_equal PhoneNumber::Parser.parse("040"), "040"
    assert_equal PhoneNumber::Parser.parse("0407"), "040 7"
      
    assert_equal PhoneNumber::Parser.parse("4"), "4"
    assert_equal PhoneNumber::Parser.parse("40"), "40"
    assert_equal PhoneNumber::Parser.parse("407"), "40 7"
    
    assert_equal PhoneNumber::Parser.parse("+494"), "+49 4"
    assert_equal PhoneNumber::Parser.parse("+4940"), "+49 40"
    assert_equal PhoneNumber::Parser.parse("+49407"), "+49 40 7"
    assert_equal PhoneNumber::Parser.parse("+494070"), "+49 40 70"
    assert_equal PhoneNumber::Parser.parse("+4940705"), "+49 40 705"
    assert_equal PhoneNumber::Parser.parse("+49407055"), "+49 40 7055"
    assert_equal PhoneNumber::Parser.parse("+494070558"), "+49 40 70558"
    
    assert_equal PhoneNumber::Parser.parse("00494"), "00 49 4"
    assert_equal PhoneNumber::Parser.parse("004940"), "00 49 40"
    assert_equal PhoneNumber::Parser.parse("0049407"), "00 49 40 7"
    assert_equal PhoneNumber::Parser.parse("00494070"), "00 49 40 70"
    assert_equal PhoneNumber::Parser.parse("004940705"), "00 49 40 705"
    assert_equal PhoneNumber::Parser.parse("0049407055"), "00 49 40 7055"
    assert_equal PhoneNumber::Parser.parse("00494070558"), "00 49 40 70558"
  end
end