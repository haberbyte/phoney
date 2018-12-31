require 'phoney/test_helper'

class USRegionTest < MiniTest::Unit::TestCase
  def setup
    Phoney.region = :us
  end

  def test_format_phone_number
    assert_equal "568-9780", Phoney::Parser.parse("5689780")
    assert_equal "(704) 568-9780", Phoney::Parser.parse("7045689780")
    assert_equal "1 (704) 568-9780", Phoney::Parser.parse("17045689780")
  end

  def test_as_you_type_formatting
    assert_equal "+1 (7  )", Phoney::Parser.parse("+17")
    assert_equal "+1 (71 )", Phoney::Parser.parse("+171")
    assert_equal "+1 (712)", Phoney::Parser.parse("+1712")
    assert_equal "+1 (712) 34", Phoney::Parser.parse("+171234")
    assert_equal "+1 (712) 345", Phoney::Parser.parse("+1712345")
    assert_equal "+1 (712) 345-6", Phoney::Parser.parse("+17123456")
  end

  def test_international_incomplete_number_with_trunk_prefix
    assert_equal "+1 (1) (7  )", Phoney::Parser.parse("+117")
  end

  def test_asterisk_pattern
    assert_equal "*22812", Phoney::Parser.parse("*22812")
    assert_equal "*22812", Phoney::Parser.parse("*22812")

    assert_equal "*12 345", Phoney::Parser.parse("*12345")
    assert_equal "*12 345-6789", Phoney::Parser.parse("*123456789")
    assert_equal "*123 456-7891", Phoney::Parser.parse("*1234567891")
    assert_equal "*12 (345) 678-912", Phoney::Parser.parse("*12345678912")
    assert_equal "*123 (456) 789-1234", Phoney::Parser.parse("*1234567891234")
    assert_equal "*12 345678912345", Phoney::Parser.parse("*12345678912345")
  end

  def test_fallback_for_invalid_phone_number
    # the number is too long for [:us]
    assert_equal "+1 704123456789", Phoney::Parser.parse("+1704123456789")
    assert_equal "123456789012", Phoney::Parser.parse("123456789012")
  end
end
