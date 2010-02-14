require File.dirname(__FILE__) + '/spec_helper'

describe PhoneNumber do
  
  describe "with region set to [:us]" do
    before(:each) do
      PhoneNumber.default_region = :us
    end
    
    it "should format a valid number according to [:us] formatting" do
      pn = PhoneNumber.new '7041234567'
      pn.to_s.should == "+1 (704) 123-4567"
    end
    
    it "should extract the country, area, and number correctly" do
      pn = PhoneNumber.new '7041234567'
      
      pn.country_code.should == "1"
      pn.area_code.should == "704"
      pn.number.should == "1234567"
    end
  end
  
  describe "using a number that has a prefix_code before the area code" do
    before(:each) do
      @pn = PhoneNumber.new("+55 12 34 5678-9012")
    end
    
    it "should have the correct prefix/area code assigned" do
      @pn.prefix_code.should == "12"
      @pn.area_code.should == "34"
      @pn.number == "56789012"
    end
    
    it "should output the correct canonical format" do
      @pn.to_s.should == "+55 (12 34) 5678-9012"
    end
  end
  
end