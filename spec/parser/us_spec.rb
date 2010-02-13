require File.dirname(__FILE__) + '/../spec_helper'

describe PhoneNumber::Parser do
  
  describe "with region set to [:us]" do
    before(:each) do
      PhoneNumber.region = :us
    end
    
    it "should format a [:us] (USA) phone number" do
      PhoneNumber::Parser.parse("5689780").should == "568-9780"
      PhoneNumber::Parser.parse("7045689780").should == "(704) 568-9780"
      PhoneNumber::Parser.parse("17045689780").should == "1 (704) 568-9780"
    end
    
    describe "dialing with international prefix" do
      it "should not dialout without the prefix" do
        PhoneNumber::Parser.parse("4940123456").should == "(494) 012-3456"
      end
      
      it "should dial out with an international_prefix" do
        PhoneNumber::Parser.parse("0114940123456").should == "011 49 40 123456"
      end
      
      describe "given an any phone number" do
        it "should ignore non-number pad characters" do
          PhoneNumber::Parser.parse("!!+ 1 7--12@ 34 5.6").should == "+1 (712) 345-6"
        end
        
        it "should guess the current formatting correctly" do
          PhoneNumber::Parser.parse("+17").should == "+1 (7"
          PhoneNumber::Parser.parse("+171").should == "+1 (71"
          PhoneNumber::Parser.parse("+1712").should == "+1 (712"
          PhoneNumber::Parser.parse("+171234").should == "+1 (712) 34"
          PhoneNumber::Parser.parse("+1712345").should == "+1 (712) 345"
          PhoneNumber::Parser.parse("+17123456").should == "+1 (712) 345-6"
        end
      end
      
      describe "given an invalid phone number" do
        it "should use a reasonable default format" do
          # the number is too long for [:us]
          PhoneNumber::Parser.parse("+1704123456789").should == "+1 704123456789"
        end
      end
    end
  end
  
end