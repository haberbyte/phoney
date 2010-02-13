require File.dirname(__FILE__) + '/test_helper'
 
class ParserTest < Test::Unit::TestCase
  
  def test_parse_incomplete_number
    assert PhoneNumber::Parser.parse("5689780") == "568-9780"
  end
  
end