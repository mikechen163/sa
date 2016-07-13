$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
 
require "shared_setup"

require 'yahoofinance'
require 'time'

require 'active_record'

class Daily_records < ActiveRecord::Base
  def self.table_name() "daily_records" end





  def self.get_last_date()
     s = self.find(:all,  :conditions=>" code = '600036'", :order=>"date desc").first  
     return s['date']
     #return s['TIME'].to_s(:db).gsub!(/[-]/,'/')  if s
     
  end

    def self.get_empty_days()
     s = self.find(:all,  :conditions=>" code = '600036'", :order=>"date desc").first  
     return  (Time.now.to_date - s['date']).to_i - 1

     #return s['TIME'].to_s(:db).gsub!(/[-]/,'/')  if s
     
  end
end

class Weekly_records < ActiveRecord::Base
  def self.table_name() "weekly_records" end
end

class Monthly_records < ActiveRecord::Base
  def self.table_name() "monthly_records" end
end

class Names < ActiveRecord::Base
  def self.table_name() "name" end

  def self.get_code_list

    name_list = []
    self.all.each do |rec|
      appendix = 'SZ'
      appendix = 'SS' if rec['market'] == 'SH'
      #puts appendix
      s = rec['code']+'.'+appendix
      #puts s
      name_list.push( s)
    end

    return name_list

     #return  (Time.now.to_date - s['date']).to_i - 1
  end
end

count=Daily_records.get_empty_days

list= Names.get_code_list
#puts list.count

start= Daily_records.last['id'].to_i+1

puts start


list.each do |code|
  puts code
  sl = []
 YahooFinance::get_HistoricalQuotes_days( code, count ) do |hq|  
    if hq.volume > 0
    

     ts = "\'#{code[0..5]}\',date(\'#{hq.date}\'),#{hq.open},#{hq.high},#{hq.low},#{hq.close},#{hq.volume},#{hq.volume*hq.close},1,1"
 #   #puts "#{hq.symbol},#{hq.date},#{hq.open},#{hq.high},#{hq.low}," + "#{hq.close},#{hq.volume},#{hq.adjClose}"
     
     #puts ts
     sl.push (ts)
    end
 end

 nsl = sl.reverse
 sl2 = []
 nsl.each do |line|
   sl2.push ("#{start},"+line)
   start += 1
 end

 insert_data('daily_records',sl2)

 ts = nil
 sl = nil

     
end