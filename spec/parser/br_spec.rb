require File.dirname(__FILE__) + '/../spec_helper'

describe PhoneNumber::Parser do
  
  describe "with region set to [:br]" do
    before(:each) do
      PhoneNumber.default_region = :br
    end
    
    it "should format a [:br] (Brazil) phone number" do
      PhoneNumber::Parser.parse("123").should == "123"
      PhoneNumber::Parser.parse("1234").should == "123-4"
      PhoneNumber::Parser.parse("12345").should == "123-45"
      PhoneNumber::Parser.parse("123456").should == "123-456"
      PhoneNumber::Parser.parse("1234567").should == "123-4567"
      PhoneNumber::Parser.parse("12345678").should == "1234-5678"
      PhoneNumber::Parser.parse("123456789").should == "(12) 3456-789"
      PhoneNumber::Parser.parse("1234567891").should == "(12) 3456-7891"
      PhoneNumber::Parser.parse("12345678910").should == "123 4567-8910"
      PhoneNumber::Parser.parse("123456789100").should == "(12 34) 5678-9100"
    end
    
    describe "dialing with international prefix" do      
      it "should dial out with an international_prefix" do
        PhoneNumber::Parser.parse("+4940123456").should == "+49 40 123456"
        PhoneNumber::Parser.parse("+004940123456").should == "+00 49 40 123456"
        PhoneNumber::Parser.parse("00004940123456").should == "00 00 49 40 123456"
        PhoneNumber::Parser.parse("00014940123456").should == "00 01 49 40 123456"
        PhoneNumber::Parser.parse("00024940123456").should == "00 02 49 40 123456"
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
          # the number is too long for [:br]
          PhoneNumber::Parser.parse("1234567891001").should == "1234567891001"
          
          PhoneNumber::Parser.parse("+++494070123").should == "+++494070123"
          PhoneNumber::Parser.parse("++494070123").should == "++494070123"
          PhoneNumber::Parser.parse("+01494070123").should == "+01494070123"
        end
      end
    end
  end
  
end