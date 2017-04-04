require 'quata'
quandl = Quata::API.new 'TB6QKirh7HJdSH3xA3Gz'

result = quandl.get "datasets/WIKI",  date: 2016-12-31 # => Hash

p result['dataset']['data'].to_s
