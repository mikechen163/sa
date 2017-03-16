require 'yahoofinance'

YahooFinance::get_historical_quotes( 'AMZN',
                                      Date.parse( '2017-03-01' ),
                                      Date.today() ) do |row|
  puts "AMZN,#{row.join(',')}"
end



#Getting the data as YahooFinance::HistoricalQuote objects using the
#days API.

YahooFinance::get_HistoricalQuotes_days( '0700.HK', 30 ) do |hq|
  puts "#{hq.symbol},#{hq.date},#{hq.open},#{hq.high},#{hq.low}," + "#{hq.close},#{hq.volume},#{hq.adjClose}"
end


# Set the type of quote we want to retrieve.
# Available type are:
#  - YahooFinance::StandardQuote
#  - YahooFinance::ExtendedQuote
#  - YahooFinance::RealTimeQuote
quote_type = YahooFinance::ExtendedQuote

# Set the symbols for which we want to retrieve quotes.
# You can include more than one symbol by separating
# them with a ',' (comma).
quote_symbols = "0700.HK,2208.HK,UBNT,603898.SS,300450.SZ"

# Get the quotes from Yahoo! Finance.  The get_quotes method call
# returns a Hash containing one quote object of type "quote_type" for
# each symbol in "quote_symbols".  If a block is given, it will be
# called with the quote object (as in the example below).
YahooFinance::get_quotes( quote_type, quote_symbols ) do |qt|
    puts "------------------------------------------------------------"
    puts "QUOTING: #{qt.symbol}"
    puts qt.to_s
end

# You can get the same effect using the quote specific method.
quotes = YahooFinance::get_standard_quotes( quote_symbols )
quotes.each do |symbol, qt|
    puts "-----------------------------------------------------------"
    puts "QUOTING: #{symbol}"
    puts qt.to_s
end

# quotes = YahooFinance::get_realtime_quotes( quote_symbols )
# quotes.each do |symbol, qt|
#     puts "-----------------------------------------------------------"
#     puts "QUOTING: #{symbol}"
#     puts qt.to_s
# end







