require 'phoney/test_helper'

class PhoneNumberTest < MiniTest::Unit::TestCase  
  def setup
    @pn = PhoneNumber.new("+55 12 34 5678-9012")
  end
  
  def test_correct_prefix_and_area_codes
    assert_equal @pn.prefix_code, "12"
    assert_equal @pn.area_code, "34"
    assert_equal @pn.number, "56789012"
  end
  
  def test_correct_canonical_output_format
    assert_equal @pn.to_s, "+55 (12 34) 5678-9012"
  end
  
  def test_ignore_non_number_characters
    assert_equal PhoneNumber::Parser.parse("!!+ 1 7--12@ 34 5.6"), "+1 (712) 345-6"
  end
end