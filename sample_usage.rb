require 'lib/phone_number.rb'

def test_number_parse(number, locale)
  puts "LIVE TYPING RESULTS (#{locale})..."
  number = number.to_s
  
  chars = ""
  number.split(//).each do |char|
    chars += char

    puts "\"#{PhoneNumber.parse(chars, locale)}\""
  end
  
  puts "".ljust(30, '-')
  puts
  
end

test_number_parse("7045400211", "us")
test_number_parse("5400211", "us")
test_number_parse("04070108177", "de")
test_number_parse("+494070108177", "de")
test_number_parse("+17045400211", "de")

puts "DE: \"#{PhoneNumber.parse('041058188948', 'de')}\""
puts "UK: \"#{PhoneNumber.parse('+17045400211', 'uk')}\""
puts "UK: \"#{PhoneNumber.parse('+27654654', 'uk')}\""
puts "SE: \"#{PhoneNumber.parse('087587903', 'se')}\""

