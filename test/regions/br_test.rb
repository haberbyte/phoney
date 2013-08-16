require 'phoney/test_helper'

class BRRegionTest < MiniTest::Unit::TestCase
  def setup
    Phoney.region = "br"
  end
  
  def test_format_brazil_phone_number
    assert_equal "0300 123-4567", Phoney::Parser.parse("03001234567")
     
    assert_equal "123", Phoney::Parser.parse("123")
    assert_equal "123-4", Phoney::Parser.parse("1234")
    assert_equal "123-45", Phoney::Parser.parse("12345")
    assert_equal "123-456", Phoney::Parser.parse("123456")
    assert_equal "123-4567", Phoney::Parser.parse("1234567")
    assert_equal "1234-5678", Phoney::Parser.parse("12345678")
    assert_equal "12345-6789", Phoney::Parser.parse("123456789")
    assert_equal "(12) 3456-7891", Phoney::Parser.parse("1234567891")
    assert_equal "(12) 34567-8910", Phoney::Parser.parse("12345678910")
    assert_equal "(12 34) 5678-9100", Phoney::Parser.parse("123456789100")
    assert_equal "(12 34) 56789-1000", Phoney::Parser.parse("1234567891000")
    assert_equal "12345678910000", Phoney::Parser.parse("12345678910000")
  end
  
  def test_guessing_current_format_correctly
    assert_equal "+1 (7  )", Phoney::Parser.parse("+17")
    assert_equal "+1 (71 )", Phoney::Parser.parse("+171")
    assert_equal "+1 (712)", Phoney::Parser.parse("+1712")
    assert_equal "+1 (712) 34", Phoney::Parser.parse("+171234")
    assert_equal "+1 (712) 345", Phoney::Parser.parse("+1712345")
    assert_equal "+1 (712) 345-6", Phoney::Parser.parse("+17123456")
  end
end