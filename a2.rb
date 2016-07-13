$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
 
require "shared_setup"
require 'time'
require 'active_record'

class Daily_records < ActiveRecord::Base
  def self.table_name() "daily_records" end
end

class Weekly_records < ActiveRecord::Base
  def self.table_name() "weekly_records" end
end

class Monthly_records < ActiveRecord::Base
  def self.table_name() "monthly_records" end
end

class Names < ActiveRecord::Base
  def self.table_name() "name" end

  def self.get_code_list_for_yahoo

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


  def self.get_code_list

    name_list = []
    self.all.each do |rec|
    
      name_list.push(rec['code'])
    end

    return name_list

     #return  (Time.now.to_date - s['date']).to_i - 1
  end

end




#update database weekly and month data
def cal_week_data(table,col_name)

  wid = 1
  Names.get_code_list.each do |code|

    puts "calculating #{table} : #{code}"
    week_t =  0
    week = 0

        week_open = 0
         week_high = 0
          week_low = 0
           week_close = 0
            week_volume = 0
             week_amount = 0 
    
    week_list = []
   
    Daily_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"id asc").each do |row|

     # p row
     
     week = row[col_name]
    
       if week_t != week
        

             if week_t != 0 # not first time ,save week data
                
                ts = "#{wid},\'#{code.to_s}\',#{week-1},#{week_open},#{week_high},#{week_low},#{week_close},#{week_volume},#{week_amount}"
                #puts ts
                week_list.push(ts)
                wid += 1

             end
        
         #record a new week data
        week_open = row['open']
         week_high = row['high']
          week_low = row['low']
           week_close = row['close']
            week_volume = row['volume']
             week_amount = row['amount']

             week_t = week

        else
          week_high = row['high'] if week_high < row['high']
          week_low = row['low'] if week_low > row['low']
           week_close = row['close']
            week_volume += row['volume']
             week_amount += row['amount']
         end

         


     
  end #records

   #save before last week of code
  ts = "#{wid},\'#{code.to_s}\',#{week},#{week_open},#{week_high},#{week_low},#{week_close},#{week_volume},#{week_amount}"
  #puts ts
  week_list.push(ts)
  wid += 1

  insert_data(table,week_list)

  #break
end # each code

end


def cal_week_month_data(table,field_name)

  wid = 1
  mid =1 
 

    week_t =  0
    week = 0

        week_open = 0
         week_high = 0
          week_low = 0
           week_close = 0
            week_volume = 0
             week_amount = 0 
    
    week_list = []


    code_t = nil

    last =  Daily_records.last['id'].to_i
    inc =1 
    while inc <= last
   
      row = Daily_records.find(inc)

      inc += 1
    #Daily_records.all.each do |row|

      code = row['code']
#      p row

     if code_t != code 

        if code_t != nil # not first time change code , save data.

                ts = "#{wid},\'#{code_t.to_s}\',#{week},#{week_open},#{week_high},#{week_low},#{week_close},#{week_volume},#{week_amount}"
                #puts ts
                week_list.push(ts)
                wid += 1

                insert_data(table,week_list)
                week_list = []

                #exit
                puts "Generating #{table} : #{code_t}"
        end 

        # first time entry
        code_t = code

    

        week_open = row['open']
         week_high = row['high']
          week_low = row['low']
           week_close = row['close']
            week_volume = row['volume']
             week_amount = row['amount']

             week_t = 1

       

         
   else  # in same code process

      week = row[field_name]
    
       if week_t != week
        

             if week_t != 0 # not first time ,save week data
                
                ts = "#{wid},\'#{code.to_s}\',#{week_t},#{week_open},#{week_high},#{week_low},#{week_close},#{week_volume},#{week_amount}"
                #puts ts
                week_list.push(ts)
                wid += 1

             end
        
         #record a new week data
        week_open = row['open']
         week_high = row['high']
          week_low = row['low']
           week_close = row['close']
            week_volume = row['volume']
             week_amount = row['amount']

             week_t = week

        else
          week_high = row['high'] if week_high < row['high']
          week_low = row['low'] if week_low > row['low']
           week_close = row['close']
            week_volume += row['volume']
             week_amount += row['amount']
         end # if week_t != week 

   end # if code_t != code
     
  end #records

   #save before last week of code
  ts = "#{wid},\'#{code.to_s}\',#{week},#{week_open},#{week_high},#{week_low},#{week_close},#{week_volume},#{week_amount}"
  #puts ts
  week_list.push(ts)
  wid += 1

  insert_data(table,week_list)

  

end


cal_week_month_data('weekly_records','week_num')
cal_week_month_data('monthly_records','month_num')

