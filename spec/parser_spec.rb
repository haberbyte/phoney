require File.dirname(__FILE__) + '/spec_helper'

describe PhoneNumber::Parser do
  
  describe "without specifying a region" do
    
    it "should return a [:us] phone number" do
      PhoneNumber::Parser.parse("5689780") == "568-9780"
    end
    
  end
  
end