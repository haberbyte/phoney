require File.dirname(__FILE__) + '/../spec_helper'

describe PhoneNumber::Parser do
  
  describe "with region set to [:de] (Germany)" do
    before(:each) do
      PhoneNumber.default_region = :de
    end
  
    describe "given a valid phone number" do
      it "should output the correct format" do
        # with national prefix '0'
        PhoneNumber::Parser.parse("040789554488").should == "040 789554488"
        # without national prefix '0'
        PhoneNumber::Parser.parse("40789554488").should == "40 789554488"
      end
    end
  
    describe "without international prefix" do
      describe "given an any phone number" do
        it "should guess the current formatting correctly" do
          PhoneNumber::Parser.parse("04").should == "04"
          PhoneNumber::Parser.parse("040").should == "040"
          PhoneNumber::Parser.parse("0407").should == "040 7"
      
          PhoneNumber::Parser.parse("4").should == "4"
          PhoneNumber::Parser.parse("40").should == "40"
          PhoneNumber::Parser.parse("407").should == "40 7"
        end
      end
    end
  
    describe "with internatoinal prefix" do
      describe "given an any phone number" do
        it "should guess the current formatting correctly" do
          PhoneNumber::Parser.parse("+494").should == "+49 4"
          PhoneNumber::Parser.parse("+4940").should == "+49 40"
          PhoneNumber::Parser.parse("+49407").should == "+49 40 7"
          PhoneNumber::Parser.parse("+494070").should == "+49 40 70"
          PhoneNumber::Parser.parse("+4940705").should == "+49 40 705"
          PhoneNumber::Parser.parse("+49407055").should == "+49 40 7055"
          PhoneNumber::Parser.parse("+494070558").should == "+49 40 70558"
        end
      end
    end
  
    describe "with country specific internatoinal prefix" do
      describe "given an any phone number" do
        it "should guess the current formatting correctly" do
          PhoneNumber::Parser.parse("00494").should == "00 49 4"
          PhoneNumber::Parser.parse("004940").should == "00 49 40"
          PhoneNumber::Parser.parse("0049407").should == "00 49 40 7"
          PhoneNumber::Parser.parse("00494070").should == "00 49 40 70"
          PhoneNumber::Parser.parse("004940705").should == "00 49 40 705"
          PhoneNumber::Parser.parse("0049407055").should == "00 49 40 7055"
          PhoneNumber::Parser.parse("00494070558").should == "00 49 40 70558"
        end
      end
    end
  end
  
end