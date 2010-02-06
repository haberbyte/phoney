require 'lib/parser.rb'

def test_number_parse(number, locale)
  puts "LIVE TYPING RESULTS (#{locale})..."
  number = number.to_s
  
  chars = ""
  number.split(//).each do |char|
    chars += char

    puts "\"#{Parser.parse(chars, locale)}\""
  end
  
  puts "".ljust(30, '-')
  puts
  
end

test_number_parse("7045400211", "us")
test_number_parse("5400211", "us")
test_number_parse("04070108177", "de")
test_number_parse("+494070108177", "de")
test_number_parse("+17045400211", "de")
test_number_parse("4070108177", "de")

puts "DE: \"#{Parser.parse('041058188948', 'de')}\""
puts "UK: \"#{Parser.parse('+17045400211', 'uk')}\""
puts "UK: \"#{Parser.parse('+27654654', 'uk')}\""
puts "SE: \"#{Parser.parse('087587903', 'se')}\""

