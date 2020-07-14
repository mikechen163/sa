$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
 
require "shared_setup"
require "common"
require 'time'
require 'min_list'
require 'asset'
require 'stock'


def find_by_ma60(m_state_list,day1,day2)

  w_list1=[]

  m_state_list.each do |m_state|
    w_list1 += Weekly_records.find(:all, :conditions=>" market_state = #{m_state} and date = date(\'#{day1.to_s}\')", :order=>"id asc")
  end 
  w_list2 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day2.to_s}\')", :order=>"id asc")

  sa=[]
  w_list1.each do |rec|
       code = rec['code']
       r2= w_list2.find{|x| x['code'] == code}
       # r3= w_list3.find{|x| x['code'] == code}
       if (r2!=nil)# and (r3!=nil)
          price = rec['close']
          #if (price>r2['close']) and (r2['close']<r3['close'])

           old_price = rec['ma60']
           ratio = ((price - old_price)/old_price*100)
           
           old_price = r2['close']
           roe = ((price - old_price)/old_price*100)

            h=Hash.new
           h[:code]=rec['code']
           h[:price]=rec['close']
           h[:date]=rec['date']
           h[:roe]=roe
           h[:ratio]=ratio
           h[:pri_price]=r2['close']
           h[:next_roe]=0.0
           h[:next_price]=0.0


           if  ((rec['market_state'] == 3) or (rec['market_state'] == 8)) and ((rec['new_high']-rec['close'])/rec['new_high'] > 0.25)
           #if  ((rec['new_high']-rec['close'])/rec['new_high'] > 0.15)
          
                  if (rec['date']-rec['new_high_date']) < 91 # don't buy in 91 days
                    h[:ratio] =  100000  
                  end
           end 


           sa.push(h)

           #puts "found #{Names.get_name(code)}(#{code}) on #{last.to_s} at price #{price},previous price #{old_price} ,roe:#{(roe*100).floor/100.0}%"
          #end
       end
    end # of each code

    return sa.delete_if{|h| h[:ratio] == 100000}
    #return sa
end


def find_by_ma20(m_state_list,day1,day2)

  w_list1=[]

  m_state_list.each do |m_state|
    w_list1 += Weekly_records.find(:all, :conditions=>" market_state = #{m_state} and date = date(\'#{day1.to_s}\')", :order=>"id asc")
  end 
  w_list2 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day2.to_s}\')", :order=>"id asc")

  sa=[]
  w_list1.each do |rec|
       code = rec['code']
       r2= w_list2.find{|x| x['code'] == code}
       # r3= w_list3.find{|x| x['code'] == code}
       if (r2!=nil)# and (r3!=nil)
          price = rec['close']
          #if (price>r2['close']) and (r2['close']<r3['close'])

           old_price = rec['ma20']
           ratio = ((price - old_price)/old_price*100)
           
           old_price = r2['close']
           roe = ((price - old_price)/old_price*100)

            h=Hash.new
           h[:code]=rec['code']
           h[:price]=rec['close']
           h[:date]=rec['date']
           h[:roe]=roe
           h[:ratio]=ratio
           h[:pri_price]=r2['close']
           h[:next_roe]=0.0
           h[:next_price]=0.0

           h[:ratio]=10000 if (rec['ma20']-rec['ma20_3m_before'])/rec['ma20_3m_before'] <0.1

           #h[:ratio]=10000 if (r2['close']-rec['close'])/r2['close'] >0.03

           if  ((rec['market_state'] == 3) or (rec['market_state'] == 8)) and ((rec['new_high']-rec['close'])/rec['new_high'] > 0.2)
           #if  ((rec['new_high']-rec['close'])/rec['new_high'] > 0.15)
          
                  if (rec['date']-rec['new_high_date']) < 91 # don't buy in 91 days
                    h[:ratio] =  10000  
                  end
           end 

           sa.push(h)

           #puts "found #{Names.get_name(code)}(#{code}) on #{last.to_s} at price #{price},previous price #{old_price} ,roe:#{(roe*100).floor/100.0}%"
          #end
       end
    end # of each code

    return sa.delete_if{|h| h[:ratio] > 20}
    #return sa
end

def find_by_ma20_slope(m_state_list,day1,day2)

  w_list1=[]

  m_state_list.each do |m_state|
    w_list1 += Weekly_records.find(:all, :conditions=>" market_state = #{m_state} and date = date(\'#{day1.to_s}\')", :order=>"id asc")
  end 
  w_list2 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day2.to_s}\')", :order=>"id asc")

  sa=[]
  w_list1.each do |rec|
       code = rec['code']
       r2= w_list2.find{|x| x['code'] == code}
       # r3= w_list3.find{|x| x['code'] == code}
       if (r2!=nil)# and (r3!=nil)
          price = rec['close']
          #if (price>r2['close']) and (r2['close']<r3['close'])

           old_price = rec['ma20']
           ratio = -((rec['ma20'] - rec['ma20_3m_before'])/rec['ma20_3m_before']*100)
           
           old_price = r2['close']
           roe = ((price - old_price)/old_price*100)

            h=Hash.new
           h[:code]=rec['code']
           h[:price]=rec['close']
           h[:date]=rec['date']
           h[:roe]=roe
           h[:ratio]=ratio
           h[:pri_price]=r2['close']
           h[:next_roe]=0.0
           h[:next_price]=0.0

           #h[:ratio]=10000 if (rec['ma20']-rec['ma20_3m_before'])/rec['ma20_3m_before'] <0.1

           h[:ratio]=10000 if (r2['close']-rec['close'])/r2['close'] <0

         #

           sa.push(h)

           #puts "found #{Names.get_name(code)}(#{code}) on #{last.to_s} at price #{price},previous price #{old_price} ,roe:#{(roe*100).floor/100.0}%"
          #end
       end
    end # of each code

    return sa.delete_if{|h| h[:ratio] > 0}
    #return sa
end


def find_by_state_days(m_state_list,day1,day2)

  w_list1=[]

  m_state_list.each do |m_state|
    w_list1 += Weekly_records.find(:all, :conditions=>" market_state = #{m_state} and days_in_state=1 and date = date(\'#{day1.to_s}\')", :order=>"id asc")
  end 
  w_list2 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day2.to_s}\')", :order=>"id asc")

  sa=[]
  w_list1.each do |rec|
       code = rec['code']
       r2= w_list2.find{|x| x['code'] == code}
       # r3= w_list3.find{|x| x['code'] == code}
       if (r2!=nil)# and (r3!=nil)
          price = rec['close']
          #if (price>r2['close']) and (r2['close']<r3['close'])

           #old_price = rec['ma60']
           old_price = rec['ma60']
           ratio = ((price - old_price)/old_price*100)
           
           old_price = r2['close']
           roe = ((price - old_price)/old_price*100)

            h=Hash.new
           h[:code]=rec['code']
           h[:price]=rec['close']
           h[:date]=rec['date']
           h[:roe]=roe
           h[:ratio]=ratio
           h[:pri_price]=r2['close']
           h[:next_roe]=0.0
           h[:next_price]=0.0


           if  ((rec['market_state'] == 3) or (rec['market_state'] == 8)) and ((rec['new_high']-rec['close'])/rec['new_high'] > 0.25)
           #if  ((rec['new_high']-rec['close'])/rec['new_high'] > 0.15)
          
                  if (rec['date']-rec['new_high_date']) < 91 # don't buy in 91 days
                    h[:ratio] =  100000  
                  end
           end 


           sa.push(h)

           #puts "found #{Names.get_name(code)}(#{code}) on #{last.to_s} at price #{price},previous price #{old_price} ,roe:#{(roe*100).floor/100.0}%"
          #end
       end
    end # of each code

    return sa.delete_if{|h| h[:ratio] == 100000}
    #return sa
end

def find_by_ma5(m_state_list,day1,day2,day3)
   w_list1=[]

  m_state_list.each do |m_state|
    w_list1 += Weekly_records.find(:all, :conditions=>" market_state = #{m_state} and date = date(\'#{day1.to_s}\')", :order=>"id asc")
  end 
  w_list2 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day2.to_s}\')", :order=>"id asc")
  w_list3 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day3.to_s}\')", :order=>"id asc")

  sa=[]
  w_list1.each do |rec|
       code = rec['code']
       r2= w_list2.find{|x| x['code'] == code}
       r3= w_list3.find{|x| x['code'] == code}
       if (r2!=nil) and (r3!=nil)
          price = rec['close']
          if (price>r2['close']) and (r2['close']<r3['close'])

           # old_price = rec['ma60']
           # ratio = ((price - old_price)/old_price*100)

           old_price = r2['close']
           roe = ((price - old_price)/old_price*100)
           ratio = roe

            h=Hash.new
           h[:code]=rec['code']
           h[:price]=rec['close']
           h[:date]=rec['date']
           h[:roe]=roe
           h[:ratio]=ratio
           h[:pri_price]=r2['close']
           h[:next_roe]=0.0
           h[:next_price]=0.0

            h[:total_mv] = Stock_Basic_Info.get_stock_total_number(h[:code]) * rec['close']
             h[:total_free_mv] = Stock_Basic_Info.get_stock_free_number(h[:code]) * rec['close']




           if  ((rec['market_state'] == 3) or (rec['market_state'] == 8)) and ((rec['new_high']-rec['close'])/rec['new_high'] > 0.25)
           #if  ((rec['new_high']-rec['close'])/rec['new_high'] > 0.15)
          
                  if (rec['date']-rec['new_high_date']) < 91 # don't buy in 91 days
                    h[:ratio] =  100000  
                  end
            end 
           sa.push(h)

           #puts "found #{Names.get_name(code)}(#{code}) on #{last.to_s} at price #{price},previous price #{old_price} ,roe:#{(roe*100).floor/100.0}%"
          end
       end
    end # of each code

    return sa.delete_if{|h| h[:ratio] == 100000}
    #return sa
end

def find_by_state_and_macd(m_state_list,day1,day2)
   w_list1=[]

  m_state_list.each do |m_state|
    w_list1 += Weekly_records.find(:all, :conditions=>" market_state = #{m_state} and date = date(\'#{day1.to_s}\')", :order=>"id asc")
  end 
  w_list2 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day2.to_s}\')", :order=>"id asc")
  #w_list3 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day3.to_s}\')", :order=>"id asc")

  sa=[]
  w_list1.each do |rec|
       code = rec['code']
       r2= w_list2.find{|x| x['code'] == code}
   #    r3= w_list3.find{|x| x['code'] == code}
       if (r2!=nil) #and (r3!=nil)
          price = rec['close']
          if (rec['diff']>=rec['dea']) and (r2['diff']<=r2['dea'])

            old_price = rec['ma20']
            ratio = ((price - old_price)/old_price*100)

           old_price = r2['close']
           roe = ((price - old_price)/old_price*100)
           #ratio = roe

            h=Hash.new
           h[:code]=rec['code']
           h[:price]=rec['close']
           h[:date]=rec['date']
           h[:roe]=roe
           h[:ratio]=ratio
           h[:pri_price]=r2['close']
           h[:next_roe]=0.0
           h[:next_price]=0.0



           # if  ((rec['market_state'] == 3) or (rec['market_state'] == 8)) and ((rec['new_high']-rec['close'])/rec['new_high'] > 0.25)
           # #if  ((rec['new_high']-rec['close'])/rec['new_high'] > 0.15)
          
           #        if (rec['date']-rec['new_high_date']) < 91 # don't buy in 91 days
           #          h[:ratio] =  100000  
           #        end
           #  end 
           sa.push(h)

           #puts "found #{Names.get_name(code)}(#{code}) on #{last.to_s} at price #{price},previous price #{old_price} ,roe:#{(roe*100).floor/100.0}%"
          end
       end
    end # of each code

    #return sa.delete_if{|h| h[:ratio] == 100000}
    return sa
end

def find_by_macd(day1,day2)
   w_list1=[]

 
  w_list1 += Weekly_records.find(:all, :conditions=>"date = date(\'#{day1.to_s}\')", :order=>"id asc")
  w_list2 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day2.to_s}\')", :order=>"id asc")
 # w_list3 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day3.to_s}\')", :order=>"id asc")

  sa=[]
  w_list1.each do |rec|
       code = rec['code']
       r2= w_list2.find{|x| x['code'] == code}
  #     r3= w_list3.find{|x| x['code'] == code}
       if (r2!=nil) #and (r3!=nil)
          price = rec['close']
          #if (price>r2['close']) # and (r2['close']<r3['close'])
          if (rec['diff']>rec['dea']) and (r2['diff']<r2['dea']) and (rec['diff']>r2['diff']) and (rec['ma20']>rec['ma60'])

           # old_price = rec['ma60']
           # ratio = ((price - old_price)/old_price*100)

           old_price = r2['close']
           roe = ((price - old_price)/old_price*100)
           ratio = roe

            h=Hash.new
           h[:code]=rec['code']
           h[:price]=rec['close']
           h[:date]=rec['date']
           h[:roe]=roe
           h[:ratio]=ratio
           h[:pri_price]=r2['close']
           h[:next_roe]=0.0
           h[:next_price]=0.0



           # if  ((rec['market_state'] == 3) or (rec['market_state'] == 8)) and ((rec['new_high']-rec['close'])/rec['new_high'] > 0.25)
           # #if  ((rec['new_high']-rec['close'])/rec['new_high'] > 0.15)
          
           #        if (rec['date']-rec['new_high_date']) < 91 # don't buy in 91 days
           #          h[:ratio] =  100000  
           #        end
           #  end 
           sa.push(h)

           #puts "found #{Names.get_name(code)}(#{code}) on #{last.to_s} at price #{price},previous price #{old_price} ,roe:#{(roe*100).floor/100.0}%"
          end
       end
    end # of each code

    #return sa.delete_if{|h| h[:ratio] == 100000}
    return sa
end

def find_by_macd2(day1,day2,day3)
   w_list1=[]

 
  w_list1 += Weekly_records.find(:all, :conditions=>"date = date(\'#{day1.to_s}\')", :order=>"id asc")
  w_list2 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day2.to_s}\')", :order=>"id asc")
  w_list3 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day3.to_s}\')", :order=>"id asc")

  sa=[]
  w_list1.each do |rec|
       code = rec['code']
       r2= w_list2.find{|x| x['code'] == code}
       r3= w_list3.find{|x| x['code'] == code}
       if (r2!=nil) and (r3!=nil)
          price = rec['close']
          #if (price>r2['close']) # and (r2['close']<r3['close'])
          if (rec['macd']>r2['macd']) and (r2['macd']<r3['macd']) and (rec['macd']<0 ) and (rec['ma20']>rec['ma60'])

           # old_price = rec['ma60']
           # ratio = ((price - old_price)/old_price*100)

           old_price = r2['close']
           roe = ((price - old_price)/old_price*100)
           ratio = roe

            h=Hash.new
           h[:code]=rec['code']
           h[:price]=rec['close']
           h[:date]=rec['date']
           h[:roe]=roe
           h[:ratio]=ratio
           h[:pri_price]=r2['close']
           h[:next_roe]=0.0
           h[:next_price]=0.0



           # if  ((rec['market_state'] == 3) or (rec['market_state'] == 8)) and ((rec['new_high']-rec['close'])/rec['new_high'] > 0.25)
           # #if  ((rec['new_high']-rec['close'])/rec['new_high'] > 0.15)
          
           #        if (rec['date']-rec['new_high_date']) < 91 # don't buy in 91 days
           #          h[:ratio] =  100000  
           #        end
           #  end 
           sa.push(h)

           #puts "found #{Names.get_name(code)}(#{code}) on #{last.to_s} at price #{price},previous price #{old_price} ,roe:#{(roe*100).floor/100.0}%"
          end
       end
    end # of each code

    #return sa.delete_if{|h| h[:ratio] == 100000}
    return sa
end

def find_by_ma5_nocheck(m_state_list,day1,day2)
   w_list1=[]

  m_state_list.each do |m_state|
    w_list1 += Weekly_records.find(:all, :conditions=>" market_state = #{m_state} and date = date(\'#{day1.to_s}\')", :order=>"id asc")
  end 
  w_list2 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day2.to_s}\')", :order=>"id asc")
  #w_list3 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day3.to_s}\')", :order=>"id asc")

  sa=[]
  w_list1.each do |rec|
       code = rec['code']
       r2= w_list2.find{|x| x['code'] == code}
       #r3= w_list3.find{|x| x['code'] == code}
       if (r2!=nil) #and (r3!=nil)
          price = rec['close']
          if (price>r2['close']) #and (r2['close']<r3['close'])

           old_price = rec['ma60']
           ratio = ((price - old_price)/old_price*100)

           old_price = r2['close']
           roe = ((price - old_price)/old_price*100)
           #ratio = roe

            h=Hash.new
           h[:code]=rec['code']
           h[:price]=rec['close']
           h[:date]=rec['date']
           h[:roe]=roe
           h[:ratio]=ratio
           h[:pri_price]=r2['close']
           h[:next_roe]=0.0
           h[:next_price]=0.0



           # if  ((rec['market_state'] == 3) or (rec['market_state'] == 8)) and ((rec['new_high']-rec['close'])/rec['new_high'] > 0.25)
           # #if  ((rec['new_high']-rec['close'])/rec['new_high'] > 0.15)
          
           #        if (rec['date']-rec['new_high_date']) < 91 # don't buy in 91 days
           #          h[:ratio] =  100000  
           #        end
           #  end 
           sa.push(h)

           #puts "found #{Names.get_name(code)}(#{code}) on #{last.to_s} at price #{price},previous price #{old_price} ,roe:#{(roe*100).floor/100.0}%"
          end
       end
    end # of each code

    return sa.delete_if{|h| h[:ratio] == 100000}
    #return sa
end

def find_all_stocks(day1)

  sa=[]
  code_list=Names.get_code_list
  # Names.get_code_list.each do |code|
  # end
  w_list1 = Weekly_records.where(date: "#{day1.to_s}")
  cl2 = w_list1.collect{|rec| rec['code']}

  #p code_list.length
  #p w_list1.length

   w_list1.each do |rec| 
     h=Hash.new
     h[:code]=rec['code']
     h[:price]=rec['close']
     h[:date]=rec['date']
     h[:roe]=0
     h[:ratio]=0
     h[:pri_price]=0
     h[:next_roe]=0.0
     h[:next_price]=0.0
     # p rec['code']
     # if rec['code'] == '000300'
     #  h[:name] = "沪深300"
     # else
     h[:name] = format_code(rec['code'],false)
     #end

     sa.push(h)
   end

  


  left_code= code_list - cl2
  #p left_code.length

   left_code.each do |code|
   # p code
     rec = Weekly_records.where(code: "#{code}").last

     h=Hash.new
     h[:code]=rec['code']
     h[:price]=rec['close']
     h[:date]=rec['date']
     h[:roe]=0
     h[:ratio]=0
     h[:pri_price]=0
     h[:next_roe]=0.0
     h[:next_price]=0.0
     h[:name] = format_code(code,false)
     sa.push(h)
   end
  
   sa.sort_by!{|h| h[:code]}
   return sa
end

def find_by_price_inc(day1,offset,etf_flag=false)

    date_list=[]

    if etf_flag
      date_list = Weekly_etf_records.new.get_date_list
    else
      date_list = Weekly_records.new.get_date_list
    end

    #p date_list
    len = date_list.length
    #last = date_list[len-1-pri_week]
    
    #p day1
    day2=date_list.reverse.find {|date| date <= (day1-offset)}
    #p (day1 - offset)
    #p day2 

    if etf_flag
      w_list1 = Weekly_etf_records.where(date: "#{day1.to_s}")
      w_list2 = Weekly_etf_records.where(date: "#{day2.to_s}") 
    else
      w_list1 = Weekly_records.where(date: "#{day1.to_s}")
      w_list2 = Weekly_records.where(date: "#{day2.to_s}")
    
    end

   #p w_list1
   #p w_list2

   sa=[]
   w_list1.each do |rec|
       code = rec['code']
       r2= w_list2.find{|x| x['code'] == code}
       if (r2!=nil) 
          price = rec['close']
          #if (price>r2['close']) and (r2['close']<r3['close'])

           # old_price = rec['ma60']
           # ratio = ((price - old_price)/old_price*100)

           old_price = r2['close']
           roe = ((price - old_price)/old_price*100)
           ratio = roe

           #p ratio 
           #p code 
           ratio = -roe if etf_flag


           if (yield roe)

              h=Hash.new
             h[:code]=rec['code']
             h[:price]=rec['close']
             h[:date]=rec['date']
             h[:roe]=roe
             h[:ratio]=ratio
             h[:pri_price]=r2['close']
             h[:next_roe]=0.0
             h[:next_price]=0.0
             h[:name] = format_code(code,false)

             h[:total_mv] = Stock_Basic_Info.get_stock_total_number(h[:code]) * rec['close']
             h[:total_free_mv] = Stock_Basic_Info.get_stock_free_number(h[:code]) * rec['close']

             sa.push(h)


             puts "found #{Names.get_name(code)}(#{code}) on #{day1.to_s} at price #{price},previous price #{old_price} on #{r2['date'].to_s} ,roe:#{(roe*100).floor/100.0}%"
          end
       end
    end # of each code

    #return sa.delete_if{|h| h[:ratio] == 100000}
    return sa , day2

end



def find_by_ma(day1,day2,sort_method,etf_flag=false) 

    #date_list = Weekly_records.new.get_date_list
    #len = date_list.length
    #last = date_list[len-1-pri_week]
  
    # w_list1=[]

    # len = m_state_list.length

    # if len>0
    #   m_state_list.each do |m_state|
    #    w_list1 += Weekly_records.find(:all, :conditions=>" market_state = #{m_state} and date = date(\'#{day1.to_s}\')", :order=>"id asc")
    #   end 

    # else
    #    w_list1 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day1.to_s}\')", :order=>"id asc")
    # end
    #p day1.to_s
    #p day2.to_s

    if etf_flag
    w_list1 = Weekly_etf_records.find(:all, :conditions=>"date = date(\'#{day1.to_s}\')", :order=>"id asc")
    w_list2 = Weekly_etf_records.find(:all, :conditions=>"date = date(\'#{day2.to_s}\')", :order=>"id asc")
    else
    #w_list1 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day1.to_s}\')", :order=>"id asc")
    #p day1,day2
    w_list1 = Weekly_records.where(date: "#{day1.to_s}")
    w_list2 = Weekly_records.where(date: "#{day2.to_s}")
  
  
    #w_list2 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day2.to_s}\')", :order=>"id asc")

    end

   #w_list1 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day1.to_s}\')", :order=>"id asc")
   #w_list2 = Weekly_records.find(:all, :conditions=>"date = date(\'#{day2.to_s}\')", :order=>"id asc")

   sa=[]
   #p w_list1.length
   #p w_list2.length
   w_list1.each do |rec|
       code = rec['code']
       r2= w_list2.find{|x| x['code'] == code}
       if (r2!=nil) 
          price = rec['close']
          #if (price>r2['close']) and (r2['close']<r3['close'])

           old_price = r2['close']
           roe = ((price - old_price)/old_price*100)

           #old_price = rec['ma20']
           #ratio = ((price - old_price)/old_price*100)
           ratio = 0.0

           case sort_method
             when :sort_by_ma20       
               old_price = rec['ma20']
               #old_price = price if old_price==0.0
               ratio = ((price - old_price)/old_price*100)
               ratio = 200 if old_price==0.0
             when :sort_by_ma60
               old_price = rec['ma60']
               ratio = ((price - old_price)/old_price*100)
             when :sort_by_last_week_roe
               old_price = r2['close']
               ratio = ((price - old_price)/old_price*100)
            when :sort_by_drop_level
               old_price = rec['new_high']
               ratio = ((price - old_price)/old_price*100)
             when :sort_by_days_passed
               old_day = rec['new_high_date']
               ratio = (day1 - old_day).to_i

               #puts "offset = #{ratio} #{day1.to_s} #{price} #{rec['new_high_date']} #{rec['new_high']}"

             when :sort_by_vol_ratio
               old_vol = r2['volume']
               vol = rec['volume']
               ratio = -((vol - old_vol)/old_vol*100)
             when :sort_by_diff
               ratio = rec['diff']
             when :sort_by_gap
               ratio = - (rec['new_high_date']-r2['new_high_date']).to_i
             when :sort_by_ma5
                old_price = rec['ma5']
               #old_price = price if old_price==0.0
               ratio = ((price - old_price)/old_price*100)
               ratio = 200 if old_price==0.0
             else
              puts "unknown sort_method #{sort_method.to_s}"
           end

           #ratio = ((price - old_price)/old_price*100)
          # p ratio

          
           # if ( yield rec)
           #  p 1
           # else
           #  p 2
           # end

           if (yield rec ,r2)
              #(r2['close']>r2['ma5']) and (r2['ma5']>r2['ma10']) and (r2['ma10']>r2['ma20']) and (r2['ma20']>r2['ma60']) 

              h=Hash.new
             h[:code]=rec['code']
             h[:price]=rec['close']
             h[:date]=rec['date']
             h[:roe]=roe
             h[:ratio]=ratio
             h[:pri_price]=r2['close']
             h[:next_roe]=0.0
             h[:next_price]=0.0
             h[:today_roe]=0.0 

             
             h[:total_mv] = Stock_Basic_Info.get_stock_total_number(h[:code]) * rec['close']
             h[:total_free_mv] = Stock_Basic_Info.get_stock_free_number(h[:code]) * rec['close']


             sa.push(h)

             #puts "found #{Names.get_name(code)}(#{code}) on #{last.to_s} at price #{price},previous price #{old_price} ,roe:#{(roe*100).floor/100.0}%"
          end
       end
    end # of each code

    return sa

end

def add_condition1(rec,market_state_list)
  if (market_state_list.find{ |ms| ms==rec['market_state'] })!=nil

    res = true
    res = false if (rec['ma20']-rec['ma20_3m_before'])/rec['ma20_3m_before'] <0.1

    if  ((rec['market_state'] == 3) or (rec['market_state'] == 8)) and ((rec['new_high']-rec['close'])/rec['new_high'] > 0.2)      
      res = false if (rec['date']-rec['new_high_date']) < 91 # don't buy in 91 days     
    end
    
    return res
  end

  return false

end

def find_candidate(mode=1,topN=20,pri_week=0,func_mode=false,days_offset=30,roe_diff=30,sortby_mv=0,sort_order=0)

     date_list = Weekly_records.new.get_date_list
     len = date_list.length
     #p len
     last = date_list[len-1-pri_week]
     d2 = date_list[len-2-pri_week]
     d3 = date_list[len-3-pri_week]
     # w_list1 = Weekly_records.find(:all, :conditions=>" market_state = 6 and date = date(\'#{last.to_s}\')", :order=>"id asc")
     # w_list2 = Weekly_records.find(:all, :conditions=>" date = date(\'#{d2.to_s}\')", :order=>"id asc")
     # w_list3 = Weekly_records.find(:all, :conditions=>" date = date(\'#{d3.to_s}\')", :order=>"id asc")
       
     sa=[]

     case mode
     when 1
      sa=find_by_ma5([6],last,d2,d3)
  
    when 2
      sa=find_by_ma(last,d2,:sort_by_ma60) { |rec,old_rec| add_condition1(rec,[6]) }
  
    when 3 #current the best method
      sa=find_by_ma(last,d2,:sort_by_ma60) { |rec,old_rec| add_condition1(rec,[3]) }
  
    
    when 4
      sa=find_by_ma5([3],last,d2,d3)

    when 5 #current the best method
      sa=find_by_ma(last,d2,:sort_by_ma60) { |rec,old_rec| add_condition1(rec,[8]) }
  
    
    when 6
      sa=find_by_ma5([8],last,d2,d3)

    when 7 #current the best method
      sa=find_by_ma(last,d2,:sort_by_ma60) { |rec,old_rec| add_condition1(rec,[3,8]) }
  
    
    when 8
      sa=find_by_ma5([3,8],last,d2,d3)

    when 9 #current the best method
      sa=find_by_ma(last,d2,:sort_by_ma60) { |rec,old_rec| add_condition1(rec,[3,8,6]) }
  
    
    when 10
      sa=find_by_ma5([3,8,6],last,d2,d3)

    when 11
      sa=find_by_price_inc(last,30) {|ratio| ratio > 30}

    when 12
      sa=find_by_price_inc(last,90) {|ratio| ratio > 30}

    when 13 #current the best method
      sa=find_by_state_days([3,8],last,d2)
    when 14 #current the best method
      sa=find_by_state_days([3],last,d2)
    when 15 #current the best method
      sa=find_by_state_days([8],last,d2)
    when 16 #current the best method
      sa=find_by_ma(last,d2,:sort_by_ma60) {|rec,old_rec| (3==rec['market_state']) }
    when 17 #current the best method
      sa=find_by_ma(last,d2,:sort_by_ma60) {|rec,old_rec| (8==rec['market_state']) }
    when 18 #current the best method
      sa=find_by_ma(last,d2,:sort_by_ma60) {|rec,old_rec| (3==rec['market_state']) or (8==rec['market_state']) }
    when 19#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['ma20']-rec['ma20_3m_before'])/rec['ma20_3m_before'] >=0.1) and (3==rec['market_state'])}
    when 20 #current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['ma20']-rec['ma20_3m_before'])/rec['ma20_3m_before'] >=0.1) and (8==rec['market_state'])}
    when 21 #current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['ma20']-rec['ma20_3m_before'])/rec['ma20_3m_before'] >=0.1) and ((3==rec['market_state']) or (8==rec['market_state']))}

    when 22#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) { |rec,old_rec| add_condition1(rec,[3]) }
    when 23 #current the best method
       sa=find_by_ma(last,d2,:sort_by_ma20) { |rec,old_rec| add_condition1(rec,[8]) }
    when 24 #current the best method
       sa=find_by_ma(last,d2,:sort_by_ma20) { |rec,old_rec| add_condition1(rec,[3,8]) }
    when 25#current the best method
      sa=find_by_ma20_slope([3,8],last,d2)
    when 26#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma60) {|rec,old_rec| (rec['new_high']!=rec['close']) or (rec['new_high_date']!=rec['date']) }
    when 27#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (rec['close']>rec['ma5']) and (rec['ma5']>rec['ma10']) and (rec['ma10']>rec['ma20']) and (rec['ma20']>rec['ma60']) }
    when 28#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (rec['close']>rec['ma5']) and (rec['ma5']<rec['ma10']) and (rec['ma5']>rec['ma20']) and (rec['ma20']>rec['ma60']) }
    when 29#current the best method
     sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec|  (rec['close']>rec['ma5']) and (rec['ma5']>rec['ma10']) and (rec['close'] < rec['ma60'])   }
    when 30#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (rec['ma20'] > rec['ma60']) }
    when 31#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (rec['close'] > rec['ma60']) and (rec['close']<rec['ma20'])} # low than ma20
    when 32#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (rec['close'] > rec['ma20']) and (rec['close']<rec['ma10']) and (rec['close'] > rec['ma60'])  } # low than ma10
    when 33#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (rec['close'] <rec['ma60']) and (rec['close']>rec['ma5']) } # low than ma60 ,but above ma5
    when 34#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (rec['close'] > rec['ma10']) and (rec['close']<rec['ma5']) and (rec['close'] > rec['ma20'])} # low than ma5
    when 35#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['ma5'] - rec['ma20'])/rec['ma20']<=0.01) and  (rec['close'] > rec['ma60'])  } # low than ma5
    when 36#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['diff'] - rec['dea'])/rec['dea']>=0) and (rec['diff']<0.2)} # low than ma5

    #股价创新高的公司
    when 37
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (rec['new_high']==rec['close']) and (rec['new_high_date']==rec['date']) and ((rec['new_high_date']-old_rec['new_high_date']).to_i > 90) } #and ((rec['new_high']-old_rec['new_high'])/old_rec['new_high'] >= 0.03)} # new high

    when 38
      sa=find_by_price_inc(last,30) {|ratio| ratio < 10}

    when 39
      sa=find_by_price_inc(last,90) {|ratio| ratio < 10}

    when 40
      sa=find_by_macd(last,d2)

    when 41#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (rec['macd']>old_rec['macd']) and (rec['macd']<0) and (rec['ma20']>rec['ma60'])  } 
    when 42
      sa=find_by_macd2(last,d2,d3)

    when 43#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['ma5'] - rec['ma20'])/rec['ma20']<=0.01) and  (rec['ma20'] > rec['ma60'])  } # low than ma5
   
     when 44#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['close'] - old_rec['close'])/old_rec['close']>=0.1) and ((old_rec['close'] - old_rec['open'])/old_rec['open']<=0.05) and  (rec['ma20'] > rec['ma60'])  } # low than ma5

     when 45#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['ma5'] - rec['ma10'])/rec['ma10']<=0.01) and  (rec['close'] > rec['ma60'])  } # low than ma5
     
     when 46#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['close'] - rec['ma5'])/rec['ma5']<=0.01) and  (rec['close'] > rec['ma60'])  } # low than ma5
     
     when 47#current the best method
      sa=find_by_ma(last,d2,:sort_by_drop_level) {|rec,old_rec| ((rec['close'] - rec['ma5'])/rec['ma5']<=0.01) and  (rec['close'] > rec['ma60'])  } # low than ma5
 
    when 51
      sa,d2=find_by_price_inc(last,days_offset,false) {|ratio| ratio > roe_diff}
    when 52
      roe_diff = - roe_diff
      sa,d2=find_by_price_inc(last,days_offset,false) {|ratio| ratio < roe_diff}

    # when 52
    #   sa,d2=find_by_price_inc(last,90,false) {|ratio| ratio > roe_diff}

    # when 53
    #   sa,d2=find_by_price_inc(last,180,false) {|ratio| ratio > roe_diff}

    # when 54
    #   sa,d2=find_by_price_inc(last,360,false) {|ratio| ratio > roe_diff}
 
    when 55#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['close'] - rec['ma20'])/rec['ma20']<=0.01) and  (rec['close'] > rec['ma60'])  } # low than ma5
   # when 56#current the best method
   #   sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['close'] - rec['ma10'])/rec['ma10']<=0.01) and  (rec['close'] > rec['ma20'])  } # low than ma5

     when 56#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['close'] - rec['ma5'])/rec['ma5']<=0.01) and  (rec['close'] > rec['ma60']) and (rec['diff'] > rec['dea'])   } # low than ma5

    when 57#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['diff'] - rec['dea'])/rec['dea']>=0) and ((old_rec['diff'] - old_rec['dea'])/old_rec['dea']<0)} # low than ma5
  

    when 58#current the best method
      sa=find_by_ma(last,d2,:sort_by_drop_level) {|rec,old_rec| ((rec['diff'] - rec['dea'])/rec['dea']>=0) and ((old_rec['diff'] - old_rec['dea'])/old_rec['dea']<0)} # low than ma5
   
    #when 58 #current the best method
    #  sa=find_by_ma(last,d2,:sort_by_last_week_roe) {|rec,old_rec| ((rec['diff'] - rec['dea'])/rec['dea']>=0) and ((old_rec['diff'] - old_rec['dea'])/old_rec['dea']<0)} # low than ma5 
    
     when 59#current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['close'] - rec['ma10'])/rec['ma10']<=0.01) and  (rec['close'] > rec['ma60']) } # low than ma5
    
      when 60#
      sa=find_by_state_and_macd([6],last,d2) 

       when 61#
        sa=find_by_state_and_macd([3,6,8],last,d2)     

      when 62#2current the best method
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (((rec['close'] - rec['ma5'])/rec['ma5']>0) and  (rec['close'] > rec['ma60']) and ((old_rec['close'] - old_rec['ma5'])/old_rec['ma5'] <= 0.0) ) } # low than ma5

       # SAME AS 57,BUT LIMIT TO 300xxx
       when 67
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['diff'] - rec['dea'])/rec['dea']>=0) and ((old_rec['diff'] - old_rec['dea'])/old_rec['dea']<0) and (rec['code'][0]=='3')} # low than ma5

      # 成交量放大
       when 68
      sa=find_by_ma(last,d2,:sort_by_vol_ratio) {|rec,old_rec| ((rec['volume'] - old_rec['volume'])/old_rec['volume']>=1.0) and ((rec['close'] - old_rec['close'])/old_rec['close']>0) } # low than ma5
  
     # 价格大于ma5,同时周线为绿
     when 69
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (rec['close']>rec['ma5']) and (rec['ma5']>rec['ma10']) and (rec['ma10']>rec['ma20']) and (rec['ma20']>rec['ma60']) and (rec['open']>rec['close'])}
  
   # 大幅上涨后，继续上涨的股票
     when 70
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (old_rec['close']/old_rec['open']>=1.1)  and (rec['close']/old_rec['close']>=1.05)}
  

   # 成交量放大,涨幅大于10%
       when 71
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['volume'])/old_rec['volume']>=2.0) and ((rec['close'])/old_rec['close']>=1.1) } # low than ma5

     # 涨幅大于10%
       when 72
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec|  ((rec['close'])/old_rec['close']>=1.1) } # low than ma5

      when 80#compare price and ma 
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (old_rec['close'] < rec['ma60']) and  (rec['close'] > rec['ma60'])  } # low than ma5
   
       when 81#compare price and ma 
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (old_rec['close'] < rec['ma20']) and  (rec['close'] > rec['ma20'])  } # low than ma5
   

      when 82#compare price and ma 
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (old_rec['close'] < rec['ma10']) and  (rec['close'] > rec['ma10'])  } # low than ma5
    
      when 83#compare price and ma 
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (old_rec['close'] < rec['ma5']) and  (rec['close'] > rec['ma5'])  } # low than ma5


     #股价创新高组合 分别是90 30 7 180 270 360 
    when 90 # 股价创新高
      sa=find_by_ma(last,d2,:sort_by_gap) {|rec,old_rec| (rec['new_high']==rec['close']) and (rec['new_high_date']==rec['date']) and ((rec['new_high_date']-old_rec['new_high_date']).to_i > 90) } #and ((rec['new_high']-old_rec['new_high'])/old_rec['new_high'] >= 0.03)} # new high

    when 91 # 股价创新高
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (rec['new_high']==rec['close']) and (rec['new_high_date']==rec['date']) and ((rec['new_high_date']-old_rec['new_high_date']).to_i >= 28) } #and ((rec['new_high']-old_rec['new_high'])/old_rec['new_high'] >= 0.03)} # new high

    when 92 # 股价创新高
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (rec['new_high']==rec['close']) and (rec['new_high_date']==rec['date']) and ((rec['new_high_date']-old_rec['new_high_date']).to_i >= 7) } #and ((rec['new_high']-old_rec['new_high'])/old_rec['new_high'] >= 0.03)} # new high

     when 93 # 股价创新高
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (rec['new_high']==rec['close']) and (rec['new_high_date']==rec['date']) and ((rec['new_high_date']-old_rec['new_high_date']).to_i >= 180) } #and ((rec['new_high']-old_rec['new_high'])/old_rec['new_high'] >= 0.03)} # new high
     
      when 94 # 股价创新高
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (rec['new_high']==rec['close']) and (rec['new_high_date']==rec['date']) and ((rec['new_high_date']-old_rec['new_high_date']).to_i >= 270) } #and ((rec['new_high']-old_rec['new_high'])/old_rec['new_high'] >= 0.03)} # new high
     
      when 95 # 股价创新高
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| (rec['new_high']==rec['close']) and (rec['new_high_date']==rec['date']) and ((rec['new_high_date']-old_rec['new_high_date']).to_i >= 360) } #and ((rec['new_high']-old_rec['new_high'])/old_rec['new_high'] >= 0.03)} # new high
     


       when 127#周线多头排列
      sa=find_by_ma(last,d2,:sort_by_ma5) {|rec,old_rec| (rec['close']>rec['ma5']) and (rec['ma5']>rec['ma10']) and (rec['ma10']>rec['ma20']) and (rec['ma20']>rec['ma60']) }
 
          when 128#连续2周上涨
      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['close']-old_rec['open'])/old_rec['open']>0.05) and ((old_rec['close']-old_rec['open'])/old_rec['open']>=0.1)  }
 
     when 129#连续2周上涨

      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['close']-old_rec['open'])/old_rec['open']>0.05) and ((old_rec['close']-old_rec['open'])/old_rec['open']>=0.1) and ((old_rec['close']-old_rec['open'])/old_rec['open']<=0.2)    }

     when 130#连续2周上涨

      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['close']-rec['open'])/rec['open']>0.02) and ((old_rec['close']-old_rec['open'])/old_rec['open']>=0.1) and ((old_rec['close']-old_rec['open'])/old_rec['open']<=0.2)    }
    
      when 138#连续2周上涨

      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['close']-old_rec['open'])/old_rec['open']>0.08) and ((old_rec['close']-old_rec['open'])/old_rec['open']>=0.1) and ((old_rec['close']-old_rec['open'])/old_rec['open']<=0.2)    }
  
   when 139#连续2周上涨

      sa=find_by_ma(last,d2,:sort_by_ma20) {|rec,old_rec| ((rec['close']-old_rec['open'])/old_rec['open']>0.08) and ((old_rec['close']-old_rec['open'])/old_rec['open']>=0.1)    }

    when 150# 周K线 ma20 上升趋势， diff 小于 dea， 本周收阳线，macd大于上周的macd，并且为负值，按照 diff小于dea的时间长度排序，时间越长，越排在前面 2020-07-14
    sa=find_by_ma(last,d2,:sort_by_days_passed) {|rec,old_rec| \
          (rec['ma20'] - rec['ma20_3m_before'] > 0.0) \
      and (rec['diff'] - rec['dea'] < 0.0)   \
      and (rec['close'] - rec['open'] > 0.0) \
       and (rec['macd'] - old_rec['macd'] > 0.0) \
      }

      sort_order = 1

      #list all stocks
       when 100
      sa=find_all_stocks(last)
   # the best method
   # 45/46 for shaking market 2012-12-14  2014-07-04
   # 37/47/57 for bull market from  2015-05-08 
   # 45/46/57  for bull end and bear market
   # 45 is week than 46 in all time.
   # 47 is week than 46 in shaking market ,but much better than 57. 47 is better than 46 in bull market ,but week than 57

   # final: use 46 in almost all time, then use 57 in bull start.

   else

    puts "unknown mode=#{mode}"
    return
   end #case mode


    #sa.delete_if{|h| h[:ratio] == 100000}
    #p sa.length
     
     if (sortby_mv == 0)
      if sort_order == 0
        sa.sort_by!{|h| h[:ratio]}
      else
        sa.sort_by!{|h| h[:ratio]}.reverse!
      end
      
      else
        if (sortby_mv == 1)
          sa.sort_by!{|h| h[:total_free_mv]}
        else
          sa.sort_by!{|h| h[:total_free_mv]}
          sa.reverse!
        end
      end
    len=sa.length
    len = topN if len>topN

    return sa[0..len-1] if func_mode

    #ave_roe = sa[0..len-1].each_with_index.inject(0.0) {|res,(x,i)| (res*i+x[:roe])/(i+1)}

    ave_roe = 0.0
    ave_roe = (sa[0..len-1].inject(0.0){|res,v| res+v[:roe]})/len if len>0


    puts"----------------------------------------------------------------------"
    sa[0..len-1].each do |h|
        #p h
        #puts "#{Names.get_name(h[:code])}(#{h[:code]}) on #{h[:date]}, price #{h[:price]}, last week price #{h[:pri_price]} #{(h[:roe]*100).floor/100.0}% high compared to last price"
        name = format_code(h[:code])
        name = h[:name] if h[:name]!=nil

        #p name
        #puts "#{format_code(h[:code])} on #{h[:date].to_s} at #{format_price(h[:price])} roe=#{format_roe(h[:roe])}" 
        #p h
        puts "#{format_code(h[:code])} on #{h[:date].to_s}, price #{format_price(h[:price])}, on #{d2.to_s} price #{format_price(h[:pri_price])} #{format_roe(h[:roe])} ratio=#{format_price((h[:ratio]*100).to_i/100.0)}, #{(h[:total_free_mv]*100).to_i/100.0}亿 #{(h[:total_mv]*100).to_i/100.0}亿" 
  
    end
    puts "total #{len} ave_roe = #{(ave_roe*100).floor/100.0}%"

end

def find_lastweek_roe(mode,topN,pri_week,func_mode=false,compared_with_last_day=0)

  date_list = Weekly_records.new.get_date_list
  len=date_list.length


  sa=find_candidate(mode,topN,pri_week,true)

  if (pri_week == 0) or (compared_with_last_day == 1)
    day = Time.now.to_date
    sa.each do |h|
      open,high,close,low=get_price_from_sina(h[:code])
      price = close
      old_price = h[:price]
      price = old_price if price == 0.0
      h[:next_roe] = ((price - old_price)/old_price*100)
      h[:next_price] = price   

      old_price = open
      h[:today_roe] = 0.0 
      price = old_price if price == 0.0
      h[:today_roe] = ((price - old_price)/old_price*100) if old_price>0

    end

  else
    
    #day = date_list[len-1]
    day = date_list[len-1-(pri_week-1)] #if compared_with_last_day == 0
    #p day

    #w_list=Weekly_records.find(:all, :conditions=>" date = date(\'#{day.to_s}\')", :order=>"id asc")
    w_list=Weekly_records.where(date: "#{day.to_s}")
    #p w_list

    sa.each do |h|
      #p h
      rec= w_list.find{|rec| rec['code'] == h[:code]}
      if (rec!=nil)
        price = rec['close']
        old_price = h[:price]
        h[:next_roe] = ((price - old_price)/old_price*100)
        h[:next_price] = price

        if not func_mode
          open,high,close,low=get_price_from_sina(h[:code])
          price = close

          old_price = open
          h[:today_roe] = 0.0 
          price = old_price if price == 0.0
          h[:today_roe] = ((price - old_price)/old_price*100) if old_price>0
        end

        #h[:today_roe] = 0.0
        #p h[:today_roe]
      end
    end
  end

  #ave_roe = sa.each_with_index.inject(0.0) {|res,(x,i)| (res*i+x[:next_roe])/(i+1)} 
  if (pri_week == 0) 
    sa.sort_by!{|h| h[:today_roe]}  
  else
    sa.sort_by!{|h| h[:next_roe]}
  end
  sa.reverse!
  

  len = sa.length
  ave_roe = 0.0
  ave_roe = (sa[0..len-1].inject(0.0){|res,v| res+v[:next_roe]})/len if len>0

  return ave_roe if func_mode

  #p ave_roe.class

  len = sa.length


  #check_index_state(0)
  puts"----------------------------------------------------------------------"
  sa[0..len-1].each do |h|
     # p h
      puts "#{format_code(h[:code])} on #{day.to_s}, price #{format_price(h[:next_price])}, on #{h[:date].to_s} price #{format_price(h[:price])} #{format_roe(h[:next_roe])} #{format_roe(h[:today_roe])} #{(h[:total_mv]*100).to_i/100.0}亿" 
  end
  puts "total #{len} ave_roe = #{(ave_roe*100).floor/100.0}%"

end


def cal_sp(from)
  t = ((from/10)/10.0).ceil
  sp = "  "
  sp= ' ' if t==1 #2 digit,1 space, 1 digit, 2 space

  return sp
end

def show_selection_result(from,to,w_list,pri_week,topN,date_list)
  nlist = from.upto(to).collect{|x| x}
  # s= nlist.each_with_index.inject("date                  "){|res,(var,i)| res<<"mode#{var}"+cal_sp(i+1)}
  # puts s

  #return

  ml=[]
  nlist.each do |mode|
    sa=find_candidate(mode,topN,pri_week,true)
    
    sa.each do |h|
      rec= w_list.find{|rec| rec['code'] == h[:code]}
      if (rec!=nil)
        price = rec['close']
        old_price = h[:price]
        h[:next_roe] = ((price - old_price)/old_price*100)
        h[:next_price] = price
      end
    end

    ave_roe = sa.each_with_index.inject(0.0) {|res,(x,i)| (res*i+x[:next_roe])/(i+1)} 
    ml.push(ave_roe)
  end
  #s=ml.each_with_index.inject("select stock on #{date_list[len-1-pri_week]} offset=#{pri_week}") {|res,(var,i)| res<<" ,mode#{i+1} roe="+format_roe(var) }
  s=ml.each_with_index.inject("on #{date_list[date_list.length-1-pri_week]} off=#{pri_week} ") {|res,(var,i)| res<<' '+format_roe(var) }
  puts s
end

def find_longtime_roe(topN,weeks)

  date_list = Weekly_records.new.get_date_list
  len=date_list.length

  day = date_list[len-1]
  w_list=Weekly_records.find(:all, :conditions=>" date = date(\'#{day.to_s}\')", :order=>"id asc")


  nlist = 1.upto(26).collect{|x| x}
  s= nlist.each_with_index.inject("date                  "){|res,(var,i)| res<<"mode#{var}"+cal_sp(i+1)}
  puts s

  1.upto(weeks) do |pri_week|
   show_selection_result(1,26,w_list,pri_week,topN,date_list)
   #show_selection_result(11,20,w_list,pri_week,topN,date_list)
   #show_selection_result(21,26,w_list,pri_week,topN,date_list)
  end
end


def compute_long(mode,weeks=1)
  #sa=[]
  stock_num_list=[10,5,3,1,2,15,20,30]
  date_list = Weekly_records.new.get_date_list
  len=date_list.length

  stock_num_list.each do |stock_num|
    sa=[]
    weeks.downto(1) do |i|
      ave_roe=find_lastweek_roe(mode,stock_num,i,true)
      #puts "stock_num = #{stock_num}, on week #{date_list[len-1-i].to_s}, offset = #{i},ave_roe=#{(ave_roe*100).floor/100.0}%"
      sa.push(ave_roe)
      sum_roe = sa.inject(1.0) {|res,var| res*(1+var/100)}
      puts "stock_num = #{stock_num}, on week #{date_list[len-i].to_s}, offset = #{i},ave_roe=#{(ave_roe*100).floor/100.0}%,sum_roe = #{(sum_roe*10000).floor/100.0}%"
    end
    #p sa.length
    #p sa
    ave_roe = sa.each_with_index.inject(0.0) {|res,(x,i)| (res*i + x )/(i+1)}
    sum_roe = sa.inject(1.0) {|res,var| res*(1+var/100)}
    #ave_roe = sa.inject(0.0) {|res,(x,i)| p x.class}
    puts "stock_num=#{stock_num}, total weeks = #{weeks}, ave_roe=#{(ave_roe*100).floor/100.0}%, sum_roe = #{(sum_roe*10000).floor/100.0}% "
  end
end

#change position in special case
def get_new_position(roe1,roe2,high_value=8.0,low_value=-8.0)

   if   (roe2 >= 2*high_value) or (((roe2+roe1) >= 2*high_value) and (roe1 <= 2*high_value))
     return 0.5 
   end

    if  (roe2 <= 2*low_value) or (((roe2+roe1) <=2*low_value) and (roe1 >= 2*low_value))
     return 2.0 
   end   

   return 1.0

end

def get_new_position_agresive(roe1,roe2,high_value=8.0,low_value=-8.0)

   if   (roe2 >= high_value) and (roe1 >= high_value)
     return 0.5 
   end

     if   (roe2 <= low_value) and (roe1 <= low_value)
     return 2.0 
   end   

   return 1.0

end

def compute_long_with_control(mode,weeks=1)
  #sa=[]
  stock_num_list=[10,5,3,20,30]
  date_list = Weekly_records.new.get_date_list
  len=date_list.length

  stock_num_list.each do |stock_num|
    puts "-----------------------------------------------------------------------------------------------"
    last_ave = ave_roe= 0.0
    sum_roe = 1.0
    pos = 1.0
    sa=[]
    weeks.downto(1) do |i|
      last_ave = ave_roe
      ave_roe=find_lastweek_roe(mode,stock_num,i,true)
      #puts "stock_num = #{stock_num}, on week #{date_list[len-1-i].to_s}, offset = #{i},ave_roe=#{(ave_roe*100).floor/100.0}%"
      #sa.push(ave_roe)
      #sum_roe = sa.inject(1.0) {|res,var| res*(1+var/100)}
      #p "#{ave_roe}"
      sum_roe = (1+pos*ave_roe/100.0)*sum_roe
      #pos = pos * get_new_position(last_ave,ave_roe)
      #sum_roe = (1+pos*ave_roe/100.0)*sum_roe

      puts "stock_num = #{stock_num}, on week #{date_list[len-i].to_s}, offset = #{i},pos = #{format_price(pos)}, ave_roe=#{(ave_roe*100).floor/100.0}%,sum_roe = #{(sum_roe*10000).floor/100.0}%"
      pos = pos * get_new_position(last_ave,ave_roe)
    end
    #p sa.length
    #p sa
    #ave_roe = sa.each_with_index.inject(0.0) {|res,(x,i)| (res*i + x )/(i+1)}
    #sum_roe = sa.inject(1.0) {|res,var| res*(1+var/100)}
    #ave_roe = sa.inject(0.0) {|res,(x,i)| p x.class}
    #puts "stock_num=#{stock_num}, total weeks = #{weeks}, ave_roe=#{(ave_roe*100).floor/100.0}%, sum_roe = #{(sum_roe*10000).floor/100.0}% "
    
  end
end

def compute_long_with_control_aggresive(mode,weeks=1)
  #sa=[]
  stock_num_list=[10,5,3,20,30]
  date_list = Weekly_records.new.get_date_list
  len=date_list.length

  stock_num_list.each do |stock_num|
    puts "-----------------------------------------------------------------------------------------------"
    last_ave = ave_roe= 0.0
    sum_roe = 1.0
    pos = 1.0
    sa=[]
    weeks.downto(1) do |i|
      last_ave = ave_roe
      ave_roe=find_lastweek_roe(mode,stock_num,i,true)
      #puts "stock_num = #{stock_num}, on week #{date_list[len-1-i].to_s}, offset = #{i},ave_roe=#{(ave_roe*100).floor/100.0}%"
      #sa.push(ave_roe)
      #sum_roe = sa.inject(1.0) {|res,var| res*(1+var/100)}
      #p "#{ave_roe}"
      sum_roe = (1+pos*ave_roe/100.0)*sum_roe
      #pos = pos * get_new_position(last_ave,ave_roe)
      #sum_roe = (1+pos*ave_roe/100.0)*sum_roe

      puts "stock_num = #{stock_num}, on week #{date_list[len-i].to_s}, offset = #{i},pos = #{format_price(pos)}, ave_roe=#{(ave_roe*100).floor/100.0}%,sum_roe = #{(sum_roe*10000).floor/100.0}%"
      pos = pos * get_new_position_agresive(last_ave,ave_roe)
    end
    #p sa.length
    #p sa
    #ave_roe = sa.each_with_index.inject(0.0) {|res,(x,i)| (res*i + x )/(i+1)}
    #sum_roe = sa.inject(1.0) {|res,var| res*(1+var/100)}
    #ave_roe = sa.inject(0.0) {|res,(x,i)| p x.class}
    #puts "stock_num=#{stock_num}, total weeks = #{weeks}, ave_roe=#{(ave_roe*100).floor/100.0}%, sum_roe = #{(sum_roe*10000).floor/100.0}% "
    
  end
end



def get_compare_roe(zz500_list, day)
  #zz500_list = Weekly_records.new.get_list_by_code('399905')
  #len=zz500_list.length

  ind=zz500_list.index {|rec| rec['date'] == day}

  return 0.0,0 if ind==nil

  #p day

  #p ind

  p1 = zz500_list[ind]['close']
  p2 = zz500_list[ind-1]['close']

  roe = (p1-p2)/p2*100

  # p day
  # p p2,p1
  # p roe

  #return roe,zz500_list[ind-1]['market_state']

  v1= zz500_list[ind-1]['ma60'] 
  v2= zz500_list[ind-1]['ma20']  
  #v2= zz500_list[ind-1]['ma10']  

  hedge_flag = false
  hedge_flag = true if (v2-v1)/v1 < -0.02
  #hedge_flag = true if (v2-v1)/v1 < 0.11

  #hedge_flag = true if (p2-v2)/v2 < -0.02


  return roe,hedge_flag

end

def now_in_bull_market?(zz500_list, day)
  ind=zz500_list.index {|rec| rec['date'] == day}
  return false if ind==nil


  rec =  zz500_list[ind-1]

  return true if (rec['ma10']-rec['ma60'])/rec['ma60'] > 0.11
        
  return false 
end

def compute_long2(mode,weeks=1)
  #sa=[]
  stock_num_list=[10,5,3,1,2,15,20,30]
  date_list = Weekly_records.new.get_date_list
  len=date_list.length
  zz500_list = Weekly_records.get_list_by_code('399905')
  #len2=zz500_list.length

  stock_num_list.each do |stock_num|
    sa=[]
    weeks.downto(1) do |i|
      ave_roe=find_lastweek_roe(mode,stock_num,i,true)
      # ind_roe,market_state = get_compare_roe(zz500_list, date_list[len-i])

      # case market_state
      #  when 0,2
      #    ave_roe = ave_roe - ind_roe
      #  when 1,3
      #   ave_roe = ave_roe
       
      # end
      old_roe = ave_roe
      
      hf = "hedge off"
      ind_roe,hedge_flag = get_compare_roe(zz500_list, date_list[len-i])
      if hedge_flag
        ave_roe =  ave_roe - ind_roe 
          hf = "hedge on"
      else
       #ave_roe =  2*ave_roe 
      end
      #puts "stock_num = #{stock_num}, on week #{date_list[len-1-i].to_s}, offset = #{i},ave_roe=#{(ave_roe*100).floor/100.0}%"
      sa.push(ave_roe)
      sum_roe = sa.inject(1.0) {|res,var| res*(1+var/100)}
      #puts "stock_num = #{stock_num}, on week #{date_list[len-i].to_s}, offset = #{i},ave_roe=#{(ave_roe*100).floor/100.0}%,sum_roe = #{(sum_roe*10000).floor/100.0}%, ori_roe=#{(old_roe*100).floor/100.0}%, index_roe=#{(ind_roe*100).floor/100.0}%, #{hf}"
      puts "stock=#{stock_num}, #{date_list[len-i].to_s}, offset=#{i}, mode=#{mode}, ave_roe=#{format_roe(ave_roe)},sum_roe=#{format_roe(sum_roe*100)}, ori_roe=#{format_roe(old_roe)}, index_roe=#{format_roe(ind_roe)}, #{hf}"
    end
    #p sa.length
    #p sa
    ave_roe = sa.each_with_index.inject(0.0) {|res,(x,i)| (res*i + x )/(i+1)}
    sum_roe = sa.inject(1.0) {|res,var| res*(1+var/100)}
    #ave_roe = sa.inject(0.0) {|res,(x,i)| p x.class}
    puts "stock_num=#{stock_num}, total weeks = #{weeks}, ave_roe=#{(ave_roe*100).floor/100.0}%, sum_roe = #{(sum_roe*10000).floor/100.0}% "
  end
end

def best_mothod(weeks=1)
  #sa=[]
  stock_num_list=[10,5,3,1,2,15,20,30]
  date_list = Weekly_records.new.get_date_list
  len=date_list.length
  zz500_list = Weekly_records.get_list_by_code('399905')
  #len2=zz500_list.length

  stock_num_list.each do |stock_num|
    sa=[]
    weeks.downto(1) do |i|
      
      mode = 46
      mode = 57 if now_in_bull_market?(zz500_list, date_list[len-i])

      ave_roe=find_lastweek_roe(mode,stock_num,i,true)
      # ind_roe,market_state = get_compare_roe(zz500_list, date_list[len-i])

      # case market_state
      #  when 0,2
      #    ave_roe = ave_roe - ind_roe
      #  when 1,3
      #   ave_roe = ave_roe
       
      # end

       old_roe = ave_roe
      
      hf = "hedge off"
      
      ind_roe,hedge_flag = get_compare_roe(zz500_list, date_list[len-i])
      if hedge_flag
        ave_roe =  ave_roe - ind_roe 
        hf = "hedge on"
      else
       #ave_roe =  2*ave_roe 
      end
      #puts "stock_num = #{stock_num}, on week #{date_list[len-1-i].to_s}, offset = #{i},ave_roe=#{(ave_roe*100).floor/100.0}%"
      sa.push(ave_roe)
      sum_roe = sa.inject(1.0) {|res,var| res*(1+var/100)}
      puts "stock=#{stock_num}, #{date_list[len-i].to_s}, offset=#{i}, mode=#{mode}, ave_roe=#{format_roe(ave_roe)},sum_roe=#{format_roe(sum_roe*100)}, ori_roe=#{format_roe(old_roe)}, index_roe=#{format_roe(ind_roe)}, #{hf}"
    end
    #p sa.length
    #p sa
    ave_roe = sa.each_with_index.inject(0.0) {|res,(x,i)| (res*i + x )/(i+1)}
    sum_roe = sa.inject(1.0) {|res,var| res*(1+var/100)}
    #ave_roe = sa.inject(0.0) {|res,(x,i)| p x.class}
    puts "stock_num=#{stock_num}, total weeks = #{weeks}, ave_roe=#{(ave_roe*100).floor/100.0}%, sum_roe = #{(sum_roe*10000).floor/100.0}% "
  end
end

def mode_compare(weeks=1)
  #sa=[]
  stock_num_list=[10,5,3,1,2,15,20,30]
  mode_list = [45,46,47,57,58,37]
  date_list = Weekly_records.new.get_date_list
  len=date_list.length
  zz500_list = Weekly_records.get_list_by_code('399905')



  stock_num_list.each do |stock_num|
    sum_roe_list = mode_list.collect {|x| 1.0}
       s = "                        mode     "
    s = mode_list.inject(s){|res,var|  res+"                #{var}"}
    #puts s
    puts "--------------------------------------------------------------------------------------------------------------------------------------------"
    puts s

    weeks.downto(1) do |i|
      #add hedge in bear market
      ind_roe,hedge_flag = get_compare_roe(zz500_list, date_list[len-i])

      s = ""
      mode_list.each_with_index do |mode,ind|
        #h = Hash.new
        ave_roe=find_lastweek_roe(mode,stock_num,i,true)
        #puts "stock_num = #{stock_num}, on week #{date_list[len-1-i].to_s}, offset = #{i},ave_roe=#{(ave_roe*100).floor/100.0}%"


        #add hedge in bear market
        #ind_roe,hedge_flag = get_compare_roe(zz500_list, date_list[len-i])
        # if hedge_flag
        #   ave_roe =  ave_roe - ind_roe 
        # else
        #  #ave_roe =  2*ave_roe 
        # end

        
     #   sa.push(ave_roe)
        #sum_roe = sa.inject(1.0) {|res,var| res*(1+var/100)}
        sum_roe_list[ind] = (1+ave_roe/100)*sum_roe_list[ind]

        # h[:mode] = mode
        # h[:ave_roe] = ave_roe
        # h[:sum_roe] = sum_roe
        # tsa.push(h)
        #s += " [#{mode}:#{(ave_roe*100).floor/100.0}%:#{(sum_roe_list[ind]*10000).floor/100.0}%]"
        s += " [#{format_roe(ave_roe)}:#{format_roe(sum_roe_list[ind]*100)}]"
      end
      
      puts "stock_num=#{stock_num}, on #{date_list[len-i].to_s}, offset=#{i}, #{s}"
    end
    #p sa.length
    #p sa
    #ave_roe = sa.each_with_index.inject(0.0) {|res,(x,i)| (res*i + x )/(i+1)}
    #sum_roe = sa.inject(1.0) {|res,var| res*(1+var/100)}
    #ave_roe = sa.inject(0.0) {|res,(x,i)| p x.class}
   # puts "stock_num=#{stock_num}, total weeks = #{weeks}, ave_roe=#{(ave_roe*100).floor/100.0}%, sum_roe = #{(sum_roe*10000).floor/100.0}% "
  end
end


def get_pri_week_number(wr,day)
  date_list = wr.get_date_list
  len=date_list.length

  i=0
  0.upto(len-1) do |date|
    #puts date_list[len-1-i].to_s
    #p day
    return i if date_list[len-1-i] == day
    i+=1
  end

  return nil
end
# return the most lower positon in all m_state = 3 codes.

$wr = Weekly_records.new
def make_choice_list(mode,unit_num,asset,total_money,day)

  #number_of_unit = unit_num
  
  #unit_amount = total_money.to_f/number_of_unit
  left_money = asset.get_current_money
  left_money=0.0 if left_money<0

  need_num =unit_num -  asset.get_code_list.length
  need_num =0 if need_num < 0
  return [],[],[] if need_num == 0

  unit_amount = left_money/need_num
  return [],[],[] if unit_amount == 0.0

   pri_week=get_pri_week_number($wr,day)
  return [],[],[] if pri_week == nil

  port_code_list = asset.get_code_list
  len =port_code_list.length

  tl_list = find_candidate(mode,need_num+len,pri_week,true) 
   #p day.to_s
   #find_candidate(15,need_num+len,pri_week,false) 

  tl_list.delete_if {|h| (port_code_list.find {|code| h[:code] == code}) !=nil  }
  #p tl_list.length


  code_list   = tl_list[0..need_num-1].collect {|h| h[:code] }
  price_list  = tl_list[0..need_num-1].collect {|h| h[:price] }
  amount_list = tl_list[0..need_num-1].collect {|h| (unit_amount/(h[:price]*100)).floor*100 } 

  # p code_list
  # p price_list
  # p amount_list

  return code_list,price_list,amount_list

  # len = w_list.length
  # return [],[],[] if len < need_num

  #port_code_list = asset.get_code_list

  # tl_list = w_list.collect do |rec|
  
  #     h= Hash.new
  #     h[:code] = rec['code']
  #     h[:price] = rec['close']
  #    # h[:date] = rec['date']
  #     h[:amount] = (unit_amount/(h[:price]*100)).floor*100

  #     h[:ratio]  = (rec['close'] - rec['ma60']) /rec['ma60']
  #     #h[:ratio]  = -(rec['ma20'] - rec['ma20_3m_before']) /rec['ma20_3m_before']
  #     #h[:ratio]  = (rec['ma5'] - rec['ma10']) /rec['ma10']
  #     #h[:ratio] = rec['days_in_state']

  #    if  ((rec['market_state'] == 3) or (rec['market_state'] == 8)) and ((rec['new_high']-rec['close'])/rec['new_high'] > 0.15)
  #    #if  ((rec['new_high']-rec['close'])/rec['new_high'] > 0.15)
    
  #           if (rec['date']-rec['new_high_date']) < 91 # don't buy in 91 days
  #             h[:ratio] =  100000  
  #           end
  #     end 

  #     if bear_market?(rec['ma60'],rec['ma60_3m_before']) 
  #        h[:ratio] =  100000  
  #     end

  #     h[:ratio] =  100000  if (rec['high']-rec['close'])/rec['high'] > 0.08
  #     h[:ratio] =  100000  if nil!=port_code_list.find{|x| x == rec['code']} #skip exist record
  #     h
  # end

  # #tl_list.each {|x| p x}
  # tl_list.delete_if{|h| h[:ratio]==100000 }
  # tl_list.sort_by!{|h| h[:ratio]}
  # #tl_list.delete_if {|h| h[:date] != day }
  # #tl_list.reverse!
  # # puts "after sorting "
  # # tl_list.each {|x| p x}

  # #p tl_list

end

# def make_choice_list_by_min(w_list,asset,run_para,total_money,old_day)

#   number_of_unit = 3
  
#   unit_amount = total_money/number_of_unit
#   left_money = asset.get_current_money
#   need_num = (left_money/unit_amount).floor
#   return [],[],[] if need_num == 0

#   len = w_list.length
#   return [],[],[] if len < need_num

#   port_code_list = asset.get_code_list
#   # run_para[:class].methods.each {|x| p x}
#   # puts "sssssss"
#   min_list = run_para[:class].get_min_list_for_day(old_day,run_para[:last_days])
#   return [],[],[] if min_list==nil

#   tl_list = w_list.collect do |rec|
  
#       h= Hash.new
#       h[:code] = rec['code']
#       h[:price] = rec['close']
#      # h[:date] = rec['date']
#       h[:amount] = (unit_amount/(h[:price]*100)).floor*100


#       price = rec['close']
#       #min=Weekly_minlist_records.get_last_min(code,old_day)
#       min = min_list.find {|x| x['code'] == rec['code']}
#       #p min
#       buy_price = price
#       if min!=nil
#         buy_price = min['price']
#       end
 
#       roe = ((price - buy_price)/buy_price*100)
#       roe = 100 if roe <=0
#       roe +=50 if roe<=run_para[:roe_skip]
   

#       h[:ratio]  = roe
#       #h[:ratio]  = min['last_days'] if min!=nil
      

#       #h[:ratio]  = -(rec['ma20'] - rec['ma20_3m_before']) /rec['ma20_3m_before']
#       #h[:ratio]  = (rec['ma5'] - rec['ma10']) /rec['ma10']
#       #h[:ratio] = rec['days_in_state']

    
#       if  ((rec['market_state'] == 3) or (rec['market_state'] == 8)) and ((rec['new_high']-rec['close'])/rec['new_high'] > 0.15)
#             if (rec['date']-rec['new_high_date']) < 91 # don't buy in 91 days
#               h[:ratio] =  100000  
#             end
#       end 
#       h[:ratio] =  100000  if  min == nil #skip is not found on min_code_list
#       h[:ratio] =  100000  if nil!=port_code_list.find{|x| x == rec['code']} #ecskip exist record
#       h
#   end

#   #tl_list.each {|x| p x}
#   #p tl_list.length
#   # tl_list.delete_if{|h| h[:ratio]<=1 } 
#   # tl_list.delete_if{|h| h[:ratio]>2 } # if run_para[:class]==Daily_minlist_records
#   # #p tl_list.length
#   tl_list.delete_if{|h| h[:ratio]==100000 }
#   tl_list.sort_by!{|h| h[:ratio]}


#   #tl_list.delete_if {|h| h[:date] != day }
#   #tl_list.reverse!
#   # puts "after sorting "
#   # tl_list.each {|x| p x}

#   #p tl_list

#   code_list   = tl_list[0..need_num-1].collect {|h| h[:code] }
#   price_list  = tl_list[0..need_num-1].collect {|h| h[:price] }
#   amount_list = tl_list[0..need_num-1].collect {|h| h[:amount] }

#   return code_list,price_list,amount_list
# end


def rebanlance(asset,pl_list,day,show_trade)
  gmv= asset.get_gmv(pl_list)
  # if gmv == asset.get_current_money
  #   asset.reserve(0.8)
  #   return
  # end


  price_list = []
  code_list=  asset.get_checked_code_list 
  code_list.each do |code|
    h = pl_list.find{|h| h[:code] == code}
    if h!=nil
      price_list.push(h[:price])
    else
      price_list.push(0.0)
    end
 end

 len = (price_list.select {|x| x!=0.0}).length
 return if len==0
 unit_amount =  gmv*0.8/len

 amount_list=price_list.collect do |price|
  if price !=0
    (unit_amount/(price*100)).floor*100
  else
    0.0
  end
 end

  code_list.each_with_index do |code,i|
     if amount_list[i] !=0
       exist_amount = asset.get_amount(code)
       new_amount = amount_list[i] - exist_amount
       if new_amount > 0
         asset.buy(code,day,price_list[i],new_amount,Names.get_name(code))
                puts "rebanlance adjust   :buy  #{new_amount} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{price_list[i]}" #if show_trade!=0  
       else
          if new_amount < 0
            new_amount = -new_amount
            
            reason = "rebanlance adjust   "
            buy_price=asset.get_price(code)
            roe = ((price_list[i] - buy_price)/buy_price*100)
            puts "#{reason}:sell #{new_amount} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{price_list[i]} (roe = #{(roe*100).floor/100.0}%)" #if show_trade!=0
            asset.sell(code,day,price_list[i],new_amount,Names.get_name(code),roe,reason)
          end
       end
     end
  end

    asset.show_portfilo(day,pl_list) if show_trade!=0

end

def test_trade(mode,unit_num,asset,run_class, num_of_records,show_trade=1)

     #date_list = Weekly_records.find(:all, :conditions=>" code = \'600036\'", :order=>"id asc").last(num_of_records).collect{|x| x['date']}
       # check last (n+2) records. n = 18

     # p run_class.class
     # a=run_class.methods 
     # a.each {|x| p x}

     date_list = run_class.get_date_list
     len = date_list.length
     date_list = date_list[len-num_of_records..len-1]
    
     last_day_money = 10000000.0
     total_money = 0.0
     pl_list = []
     old_pl_list = []
     old_day = Time.now.to_date
     last_check_list=[]
     strong_list=[]

     asset.set_log_off

     bull_list=[]
     bull_list_prepare=[]


     first_week_check=8
     every_week_check=3
     puts "on #{Time.now.to_s} : mode=#{mode},unit_num=#{unit_num},1st week check=#{first_week_check}, every_week_check=#{every_week_check}, run weeks=#{num_of_records}"
     puts "--------------------------------------------------------------------------------------------------------"
     iii=0
     date_list.each do |day|

        #p day
        cl_list =asset.get_code_list
        w_list = []
        #p cl_list
        if cl_list.length >0 
          #w_list = run_class.class.find(:all, :conditions=>"date = date(\'#{day.to_s}\')", :order=>"id asc")
          w_list = run_class.class.where(date:"#{day.to_s}")  

          pl_list = get_price_list(cl_list,w_list,asset,old_pl_list)

          total_money = asset.get_gmv(pl_list)
        else
          total_money = asset.get_current_money
        end

        #printf "%s total rate = %.2f%c ,inc rate = %.2f%c ,last week = %s , this week = %s\r\n",day.to_s,total_money/100000,'%',(total_money-last_day_money)/last_day_money*100,'%',format_big_num(last_day_money),format_big_num(total_money)
        printf "%s total rate = %s ,inc rate = %s ,last week = %s , this week = %s\r\n",day.to_s,format_roe( total_money/100000),format_roe( (total_money-last_day_money)/last_day_money*100),format_big_num(last_day_money),format_big_num(total_money)
       
        #asset.show_portfilo(pl_list) if (iii % 13 == 0)
        last_day_money = total_money
      

        #check portfilo state and need sell stock?
        pl_list=pl_list.reverse
        cl_list.reverse.each_with_index do |code,i|
          saled = false
          buy_date = asset.get_date(code)
          buy_price = asset.get_price(code)
          # if ((pl_list[i][:price]-buy_price)/buy_price) < -0.1 # 10% stop loss
          #    puts "sell #{asset.get_amount(code)} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{pl_list[i][:price]}"
          #    asset.sell(code,day,pl_list[i][:price],asset.get_amount(code),Names.get_name(code))
          #    #next
          #    saled = true
          # end

          if not saled #check every month
            #if (((day - buy_date).to_i%31) < 7) 
            #if not strong_list.find{|x| x==code} 

              
                price = pl_list[i][:price]  
                sell_flag = false
                reason = ""

                 x =  (last_check_list.find{|x| x[:code]==code})
                     #p x
                 if x != nil 
                   old_price = x[:price]

                 else
                     old_price = buy_price
                     roe = ((price - buy_price)/buy_price*100)
                     if roe<first_week_check #should increase 10% for 1 month
                       sell_flag = true
                       reason = "roe<#{first_week_check} for 1st week"
                     else
                       #p "setting check flag for #{code}"
                       asset.set_check_flag(code,true)
                     end
                  end

               if (sell_flag) 
                   puts "#{reason}:sell #{format_big_num( asset.get_amount(code),true)} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{format_price( pl_list[i][:price])} buy at #{buy_date.to_s} (roe=#{format_roe(roe)})" if show_trade!=0
                   asset.sell(code,day,pl_list[i][:price],asset.get_amount(code),Names.get_name(code),roe,"season check fail")
                   saled = true
                 
               end

               # h= Hash.new
               # h[:code]=code
               # h[:price]= pl_list[i][:price]
               # last_check_list.push(h)

               
            #end
          end

          if not saled #check every week
             x =  (last_check_list.find{|x| x[:code]==code})
                 #p x
             if x != nil 

                   sell_flag = false
                   old_price = x[:price]

                    #core kernel, if found niugu, hold as long as possible
                   price = pl_list[i][:price]  
                   roe_last_week = ((price - old_price)/old_price*100).floor

                    # if (roe_last_week>20) 
                    #    reason = "jump over 20%         "
                    #    sell_flag = true
                    # end

                    # if (roe_last_week < -0.15) #
                    #    reason = "drop from high over 15%"
                    #    sell_flag = true
                    # end


                    # if (roe_last_week < every_week_check) #
                    #    reason = "roe<#{every_week_check} per week    "
                    #    sell_flag = true
                    # end



                    roe = ((price - buy_price)/buy_price*100)
                   # if roe < 5
                   #   reason = "roe<5 for portfilo "
                   #   sell_flag = true
                   # end

                   # if (((day - buy_date).to_i>31) ) #Sand ((day - buy_date).to_i< 50) #only first time
                   #   roe = ((price - buy_price)/buy_price*100)
                   #   if roe<25 #should increase 10% for 1 month
                   #     sell_flag = true
                   #     reason = "roe<25 for 1 month"

                   #     x=bull_list.find{|nc| nc==code}
                   #     sell_flag=false if (x!=nil) and (roe > 10)
                       
                   #   else
                   #    #  x=bull_list.find{|nc| nc==code}
                   #    # # bull_list_prepare.push(code) if x==nil
                   #    #  if (x==nil)
                   #    #    amount = asset.get_amount(code)
                   #    #    if asset.get_current_money >= amount*price
                   #    #      asset.buy(code,day,price,amount,Names.get_name(code))
                   #    #      puts "add position 1 month  :buy  #{amount} #{format_code(code)} on #{day.to_s} at price #{price}" #if show_trade!=0  

                   #    #      bull_list.push(code)
                   #    #    end

                   #    #    #bull_list.push(code)
                   #    #  end
                   #   end
                   #  end

                   #  if (((day - buy_date).to_i%91) < 7) 
                   #   roe = ((price - buy_price)/buy_price*100)
                   #   if roe<60 #should increase 10% for 1 month
                   #     sell_flag = true
                   #     reason = "roe<60 for 3 month"
                   #   else
                   #     # amount = asset.get_amount(code)/2
                   #     # if asset.get_current_money >= amount*price
                   #     #   asset.buy(code,day,price,amount,Names.get_name(code))
                   #     #   puts "add position 3 month  :buy  #{amount} #{format_code(code)} on #{day.to_s} at price #{price}" #if show_trade!=0  
                   #     # end 

                   #   end
                   #  end

                   # if (((day - buy_date).to_i%181) < 7) 
                   #   roe = ((price - buy_price)/buy_price*100)
                   #   if roe<90 #should increase 10% for 1 month
                   #     sell_flag = true
                   #     reason = "roe<90 for 6 month"
                   #   else
                   #     #  amount = asset.get_amount(code)/3
                   #     # if asset.get_current_money >= amount*price
                   #     #   asset.buy(code,day,price,amount,Names.get_name(code))
                   #     #   puts "add position 6 month  :buy  #{amount} #{format_code(code)} on #{day.to_s} at price #{price}" #if show_trade!=0  
                   #     # end 
                   #   end
                   #  end

                    if sell_flag == true
                       puts "#{reason}:sell #{format_big_num( asset.get_amount(code),true)} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{format_price( pl_list[i][:price])} buy at #{buy_date.to_s} (roe=#{format_roe(roe)})" if show_trade!=0
                       asset.sell(code,day,pl_list[i][:price],asset.get_amount(code),Names.get_name(code),roe,"season check fail")
                       saled = true
                    end
            end
          end

           
          # if not saled and (old_pl_list.length !=0)
          #   # p old_pl_list
          #   # p pl_list
          #   old_price = (old_pl_list.find{|x| x[:code]==code})[:price]
          # #  old_code = (old_pl_list.find{|x| x[:code]==code})[:code]
          #   if (((old_price-pl_list[i][:price])/old_price) > 0.1)
          #      price = pl_list[i][:price] 
          #      roe = ((price - buy_price)/buy_price*100).floor
          #      puts "drop over 20% :sell #{asset.get_amount(code)} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{pl_list[i][:price]} (roe = #{roe}%)"  if show_trade!=0
          #      asset.sell(code,day,pl_list[i][:price],asset.get_amount(code),Names.get_name(code),roe,"close price drop over 20%")
          #      saled = true

          #      # puts "#{old_day} , #{code} , old price #{old_price} #{old_code}"
          #      # puts "#{day} , #{code} , new price #{pl_list[i][:price]} #{pl_list[i][:code]}  "
             
          #      #puts
          #   end
          # end


          if not saled

            rec=nil
            rec = w_list.find {|x| x['code'] == code} if cl_list.length >0 
            if rec

             # if  ((rec['high']-rec['close'])/rec['high'] >0.1)
               if (rec['market_state'] == 4) or ((rec['close']-rec['ma5'])/rec['ma5'] <-0.01)
              #if ((rec['high']-rec['close'])/rec['high'] >0.1)

                price = rec['close']
                roe = ((price - buy_price)/buy_price*100).floor

                reason = ""
                if (rec['market_state'] == 4)
                  reason = "exit from bull    " 
                else
                  reason = "below ma5         " 
                  x=bull_list.find{|nc| nc==code}
                  reason="" if x!=nil
                end
          
                if (reason.length!=0)
                 # puts "#{reason}:sell #{asset.get_amount(code)} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{rec['close']} (roe = #{roe}%)"  if show_trade!=0       
                  puts "#{reason}:sell #{format_big_num( asset.get_amount(code),true)} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{format_price( rec['close'])} buy at #{buy_date.to_s} (roe=#{format_roe(roe)})" if show_trade!=0
                  asset.sell(code,day,rec['close'],asset.get_amount(code),Names.get_name(code),roe,reason)
                  #next
                  saled = true
                end
              end
            end
          end
        end

        # pl_list = get_price_list(asset.get_code_list ,w_list,asset,old_pl_list) 
        # tl = bull_list_prepare.collect{|x| x}
        # tl.each do |code|
        #    amount = asset.get_amount(code)
        #    price = (pl_list.find {|h| h[:code]==code})[:price]
        #    if asset.get_current_money >= amount*price
        #      asset.buy(code,day,price,amount,Names.get_name(code))
        #      puts "add position 1 month  :buy  #{amount} #{format_code(code)} on #{day.to_s} at price #{price}" #if show_trade!=0  

        #      bull_list.push(code)
        #      #bull_list_prepare.delete_if{|x| x==code}
        #    end
        # end
        # bull_list_prepare=[]
          
         pl_list = get_price_list(asset.get_code_list ,w_list,asset,old_pl_list) 
         asset.show_portfilo(day,pl_list) #if show_trade!=0

         #rebanlance(asset,pl_list,day,show_trade)  #if (((day - buy_date).to_i%31) < 7) 

         strong_list=asset.get_code_list.collect{|x| x}
         #last_check_list = get_price_list(asset.get_code_list,w_list,asset,old_pl_list)
         pl_list = get_price_list(asset.get_code_list ,w_list,asset,old_pl_list)
         
         last_check_list = pl_list.collect do |h|
          ind= last_check_list.find_index {|x| x == h[:code]}
          
          if ind!=nil
           last_check_list[ind][:price] =(h[:price] > last_check_list[ind][:price]) ? h[:price]  : last_check_list[ind][:price]
           last_check_list[ind]
          else
            h
          end
         end

         #p last_check_list.length

        #is there new stock to buy?
        #w_list = Weekly_records.find(:all, :conditions=>"market_state = 6 and date = date(\'#{day.to_s}\')", :order=>"id asc")
        #w_list = Weekly_records.find(:all, :conditions=>"market_state = 3 and date = date(\'#{day.to_s}\')", :order=>"id asc")  
        #w_list = Weekly_records.find(:all, :conditions=>"market_state = 8 and date = date(\'#{day.to_s}\')", :order=>"id asc")  
        # w_list += Weekly_records.find(:all, :conditions=>"market_state = 5 and date = date(\'#{day.to_s}\')", :order=>"id asc")  
        #w_list = run_class.class.find(:all, :conditions=>" date = date(\'#{day.to_s}\')", :order=>"id asc")  
        w_list = run_class.class.where(date:"#{day.to_s}")  
        

        len = w_list.length

        #asset.reserve(0.8,total_money) if asset.get_code_list.length==0
        if len>50
            #code_list,price_list,amount_list = make_choice_list(w_list,asset,total_money,day)
             # run_para =Hash.new
             # if run_class.class== Daily_records
             #   run_para[:class] = Daily_minlist_records
             #   run_para[:last_days] = 2
             #   run_para[:roe_skip] = 1
             # else
             #   run_para[:class] = Weekly_minlist_records
             #   run_para[:last_days] = 7
             #   run_para[:roe_skip] = 1
             # end

             #code_list,price_list,amount_list = make_choice_list_by_min(w_list,asset,run_para,total_money,old_day)
              code_list,price_list,amount_list = make_choice_list(mode,unit_num, asset,total_money,day)

          
          code_list.each_with_index do |code,i|
             asset.buy(code,day,price_list[i],amount_list[i],Names.get_name(code))
             puts "#{code},#{day.to_s}"if (nil == (w_list.find{|rec| rec['code']==code}))
             m_state = (w_list.find{|rec| rec['code']==code})['market_state']
             puts "buy  #{amount_list[i]} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{price_list[i]},m_state=#{m_state}" if show_trade!=0  
             

             h=Hash.new
             h[:code] = code
             h[:price] = price_list[i]
             pl_list.push(h)
          end
        end

        #asset.reserve(0.0) #restore money
        #asset.show_portfilo(day,  pl_list)
        #end
        iii+=1
        # old_pl_list = pl_list.each_with_index.collect do |h|
        #   ind= old_pl_list.find_index {|x| x == h[:code]}
        #   if ind!=nil
        #     (h[:close] > old_pl_list[ind][:close]) ? h[:close]  : old_pl_list[ind][:close]
        #   else
        #     h
        #   end
        # end

        old_pl_list = pl_list.collect{|x| x}
        old_day = day
        #break
      end # of each day

      asset.show_log
      asset.show_portfilo(Time.now.to_date,  pl_list)
end


def get_buying_amount(asset,price,unit_num)
  left_money = asset.get_current_money
  left_money=0.0 if left_money<0

  #left_money /= 3

  need_num =unit_num -  asset.get_code_list.length
  need_num =0 if need_num < 0
  return 0 if need_num == 0

  unit_amount = left_money/need_num
  return 0 if unit_amount == 0.0

  return (unit_amount/(price*100)).floor*100
end

def test_trade2(mode,unit_num,asset,run_class, num_of_records,show_trade=1)

     date_list = run_class.get_date_list
     len = date_list.length
     date_list = date_list[len-num_of_records..len-1]
    
     last_day_money = 10000000.0
     total_money = 0.0
     pl_list = []
     old_pl_list = []
     old_day = Time.now.to_date

     track_list=[]
     portfilo_list = []
     over_jump_list = []
     old_w_list=[]
    

     asset.set_log_off

     first_week_check=8
     every_week_check=5
     puts "on #{Time.now.to_s} : unit_num=#{unit_num}, run weeks=#{num_of_records}"
     puts "--------------------------------------------------------------------------------------------------------"
     iii=0

     date_list.each do |day|

        #w_list = run_class.class.find(:all, :conditions=>"date = date(\'#{day.to_s}\')", :order=>"id asc")

        w_list = run_class.class.where(date:"#{day.to_s}")  
        
        cl_list =asset.get_code_list
        pl_list = get_price_list(cl_list,w_list,asset,old_pl_list)

        total_money = asset.get_gmv(pl_list)
        printf "%s total rate = %s ,inc rate = %s ,last week = %s , this week = %s\r\n",day.to_s,format_roe( total_money/100000),format_roe( (total_money-last_day_money)/last_day_money*100),format_big_num(last_day_money),format_big_num(total_money)
        #asset.show_portfilo(day,pl_list) 
        last_day_money = total_money

        asset.show_portfilo(day,pl_list) 

        portfilo_list.each do |stock|
          code=stock.get_code
          #stock.update_status(day,x)

          x= w_list.find{|rec| rec['code'] == code} 
          stock.update_status(day,x)

          reason =  stock.should_sell?(day,x)
          if reason != :hold
              price = x['close']
              old_price = stock.get_buy_price
              roe = ((price - old_price)/old_price*100)

             amount = stock.get_amount
           
             puts "#{reason.to_s}:sell #{format_big_num( amount,true)} #{format_code(code)} on #{day.to_s} at price #{format_price( price)} buy at #{stock.get_buy_date.to_s} (roe=#{format_roe(roe)})" 
             asset.sell(code,day,price,amount,Names.get_name(code),roe,"check fail")  
 
             
             stock.sell(amount,reason,day) 
             # if reason == :"quick jump over 40%"
             #   over_jump_list.push(stock)
             # end   
          end

        end #portfilo list
        portfilo_list.delete_if {|stock| stock.get_state == :sold}

        # portfilo_list.each do |stock|
        #   code=stock.get_code
          
        #   x= w_list.find{|rec| rec['code'] == code} 
        #   #stock.update_status(day,x)

        #   if (stock.get_buy_state==:bought) and stock.should_add_position?(day,x)
        #       price=x['close']
  
        #       amount = get_buying_amount(asset,price,unit_num)

        #       #puts "found #{format_code(code)} on #{day.to_s} at price #{price} to add position, amount=#{amount}"
              
        #       if stock.get_add_position_times ==0
        #         if asset.get_current_money >= (3*amount*price)
        #            amount *=3
        #         end
        #       end

        #       # if stock.get_jump_sell_postion!=0
        #       #    if asset.get_current_money >= ((stock.get_jump_sell_postion-100 )*price)
        #       #      amount = stock.get_jump_sell_postion-100 
        #       #   end
        #       # end


        #       puts "found #{format_code(code)} on #{day.to_s} at price #{price} to add position, amount=#{amount}"
        #       if amount>0
        #         asset.buy(code,day,price,amount,Names.get_name(code))
        #         puts "add_position  #{amount} #{format_code(code)} on #{day.to_s} at price #{price} in portfilo_list check"

        #         stock.add_position(price,amount,day)
        #       end
        #   end


        # end


        # over_jump_list.each do |stock|

        #   code=stock.get_code
        #   #puts "jump list #{code}.."
        
        #   x= w_list.find{|rec| rec['code'] == code}
        #   stock.update_status(day,x) 


        #   if stock.should_buy?(day,x)
        #       price=x['close']  
        #       #puts "found #{format_code(code)} on #{day.to_s} at price #{price} to buy again for jump list"
  
        #       amount = get_buying_amount(asset,price,unit_num)
        #       puts "found #{format_code(code)} on #{day.to_s} at price #{price} amount=#{amount} to buy again for jump list"
        #       # if stock.get_add_position_times ==0
        #       #   if asset.get_current_money >= (3*amount*price)
        #       #      amount *=3
        #       #   end
        #       # end

        #       # if stock.get_jump_sell_postion!=0
        #       #    if asset.get_current_money >= ((stock.get_jump_sell_postion)*price)
        #       #      amount = stock.get_jump_sell_postion
        #       #   end
        #       # end

        #       if amount>0
        #         asset.buy(code,day,price,amount,Names.get_name(code))
        #         puts "jump list buy  #{amount} #{format_code(code)} on #{day.to_s} at price #{price}"

        #         stock.buy(price,amount,day,:drop_after_new_high)
        #       end
        #   end

        # end #over_jump

        #over_jump_list.delete_if {|stock| stock.get_state == :bought}
        #over_jump_list.delete_if {|stock| stock.is_bear_coming?}

        track_list.each do |stock|
          code=stock.get_code
          x= w_list.find{|rec| rec['code'] == code} 
         
          stock.update_status(day,x) 

          if (stock.get_buy_state!=:bought) and stock.should_buy?(day,x)
            price=x['close']
            #puts "found #{format_code(code)} on #{day.to_s} at price #{price} to buy from track list"
            amount = get_buying_amount(asset,price,unit_num)
            #puts "found #{format_code(code)} on #{day.to_s} at price #{price} amount=#{amount} to buy from track list"
            if amount>0
              asset.buy(code,day,price,amount,Names.get_name(code))
              puts "drop after new high : buy  #{amount} #{format_code(code)} on #{day.to_s} at price #{price}"

              stock.buy(price,amount,day,:drop_after_new_high)

              portfilo_list.push(stock)
            end
          end

        end




        #add new member
        #code_list,price_list,amount_list = make_choice_list(mode,unit_num, asset,total_money,day)
        code_list=[]
        i=0
        w_list.reverse.each do |rec|
          #if (rec['new_high'] == rec['close']) and (rec['new_high_date'] == rec['date'])
          if (rec['market_state'] == 3) or (rec['market_state'] == 8) 

            #p rec['code'],rec['new_high_date'],rec['close']
            #code_list.push(rec['code'])
            code = rec['code']

            old_rec =  old_w_list.find{|r2| r2['code'] == code}
            if (old_rec!=nil) and ((old_rec['market_state']!=3) and (old_rec['market_state']!=8)) #or (old_rec==nil)

              if (track_list.find{|stock| stock.get_code==code })==nil
                #puts "adding #{format_code(code)} to track_list"
                stock = Stock.new(rec,:new_high)
                stock.update_status(day,rec) 

                track_list.push(stock) 
                i+=1


                # price=rec['close']
                # amount = get_buying_amount(asset,price,unit_num)
                # if amount>0
                #   asset.buy(code,day,price,amount,Names.get_name(code))
                #   puts "buy  #{amount} #{format_code(code)} on #{day.to_s} at price #{price} for first time"

                #   stock.buy(price,amount,day,:new_high)

                #   portfilo_list.push(stock)
                # end

              end
            end

            #break if i>100

          end
        end

        #track_list.delete_if {|stock| stock.is_bear_coming?}

        # code_list.each_with_index do |code,i|
        #   x= w_list.find{|rec| rec['code'] == code} 
        #   if x!=nil
        #     track_list.push(Stock.new(x))
        #   end
        # end

        
        # code_list.each_with_index do |code,i|
        #    asset.buy(code,day,price_list[i],amount_list[i],Names.get_name(code))
        #    puts "#{code},#{day.to_s}"if (nil == (w_list.find{|rec| rec['code']==code}))
        #    m_state = (w_list.find{|rec| rec['code']==code})['market_state']
        #    puts "buy  #{amount_list[i]} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{price_list[i]},m_state=#{m_state}" if show_trade!=0  
           

        #    h=Hash.new
        #    h[:code] = code
        #    h[:price] = price_list[i]
        #    pl_list.push(h)
        # end
       
        old_pl_list = pl_list.collect{|x| x}
        old_day = day
        old_w_list= w_list
        #break
      end # of each day

      #asset.show_log
      #asset.show_portfilo(old_day,  old_pl_list)
end

# def test_trade(asset,run_class, num_of_records,show_trade=1)

#      #date_list = Weekly_records.find(:all, :conditions=>" code = \'600036\'", :order=>"id asc").last(num_of_records).collect{|x| x['date']}
#        # check last (n+2) records. n = 18

#      # p run_class.class
#      # a=run_class.methods 
#      # a.each {|x| p x}

#      date_list = run_class.get_date_list
#      len = date_list.length
#      date_list = date_list[len-num_of_records..len-1]
    
#      last_day_money = 100000000.0
#      total_money = 0.0
#      pl_list = []
#      old_pl_list = []
#      old_day = Time.now.to_date
#      last_check_list=[]
#      strong_list=[]

#      asset.set_log_off



#      iii=0
#      date_list.each do |day|

#         #p day
#         cl_list =asset.get_code_list
#         w_list = []
#         #p cl_list
#         if cl_list.length >0 
#           w_list = run_class.class.find(:all, :conditions=>"date = date(\'#{day.to_s}\')", :order=>"id asc")
#           pl_list = get_price_list(cl_list,w_list,asset,old_pl_list)

#           total_money = asset.get_gmv(pl_list)
#         else
#           total_money = asset.get_current_money
#         end

#         printf "%s total rate = %.2f%c ,inc rate = %.2f%c ,last week = %.2f , this week = %.2f\r\n",day.to_s,total_money/100000,'%',(total_money-last_day_money)/last_day_money*100,'%',last_day_money,total_money
#         #asset.show_portfilo(pl_list) if (iii % 13 == 0)
#         last_day_money = total_money
      

#         #check portfilo state and need sell stock?
#         cl_list.each_with_index do |code,i|
#           saled = false
#           buy_date = asset.get_date(code)
#           buy_price = asset.get_price(code)
#           # if ((pl_list[i][:price]-buy_price)/buy_price) < -0.1 # 10% stop loss
#           #    puts "sell #{asset.get_amount(code)} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{pl_list[i][:price]}"
#           #    asset.sell(code,day,pl_list[i][:price],asset.get_amount(code),Names.get_name(code))
#           #    #next
#           #    saled = true
#           # end

#           if not saled
#             # p day
#             # p buy_date
#             #p (day - buy_date).to_i
#             #p (day - buy_date).to_i%90
#             #if (((day - buy_date).to_i%31) < 7) 
#             #if not strong_list.find{|x| x==code} 

#                 old_price = 0.0
#                 check_flag = false
#                 reason = ""

#                  #p last_check_list.length
#                  x =  (last_check_list.find{|x| x[:code]==code})
#                  #p x
#                  if x != nil #not just buy code
#                    old_price = x[:price]

#                     #core kernel, if found niugu, hold as long as possible
#                    price = pl_list[i][:price]  
#                     roe = ((price - buy_price)/buy_price*100)
#                     check_flag = true if roe<9.9
#                     reason = "roe<9.9 for portfilo "


#                     # roe_last_week = ((price - old_price)/old_price*100).floor

#                     # if (roe_last_week>15) 
#                     #    reason = "jump over 15%       "
#                     #    puts "#{reason}:sell #{asset.get_amount(code)} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{pl_list[i][:price]} (roe = #{roe}%)" if show_trade!=0
#                     #    asset.sell(code,day,pl_list[i][:price],asset.get_amount(code),Names.get_name(code),roe,"season check fail")
#                     #    saled = true
#                     # end

#                    # if (((pl_list[i][:price]-old_price)/old_price) < -0.15) # drop from high value over 0.05
#                    #  puts "drop over -10% #{asset.get_amount(code)} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{pl_list[i][:price]} (high_price = #{old_price})"
              
#                    #  check_flag = true 
#                    # end
#                    check_flag = true if roe>=10
#                    reason = "clear exist portfilo" if roe>=10
#                  else 
#                    old_price = buy_price
#                    check_flag = true
#                    reason = "first buy check fail"
#                  end

#                if (check_flag) and (((pl_list[i][:price]-old_price)/old_price) < 0.099) # sell if price not great than 120%
#                  price = pl_list[i][:price] 
#                  roe = ((price - buy_price)/buy_price*100).floor

#                  #if roe<10
#                    puts "#{reason}:sell #{asset.get_amount(code)} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{pl_list[i][:price]} (roe = #{roe}%)" if show_trade!=0
#                    asset.sell(code,day,pl_list[i][:price],asset.get_amount(code),Names.get_name(code),roe,"season check fail")
#                    saled = true
#                  #end


#                end

#                # h= Hash.new
#                # h[:code]=code
#                # h[:price]= pl_list[i][:price]
#                # last_check_list.push(h)

               
#           # end
#           end

#           # if not saled and (old_pl_list.length !=0)
#           #   # p old_pl_list
#           #   # p pl_list
#           #   old_price = (old_pl_list.find{|x| x[:code]==code})[:price]
#           # #  old_code = (old_pl_list.find{|x| x[:code]==code})[:code]
#           #   if (((old_price-pl_list[i][:price])/old_price) > 0.1)
#           #      price = pl_list[i][:price] 
#           #      roe = ((price - buy_price)/buy_price*100).floor
#           #      puts "drop over 20% :sell #{asset.get_amount(code)} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{pl_list[i][:price]} (roe = #{roe}%)"  if show_trade!=0
#           #      asset.sell(code,day,pl_list[i][:price],asset.get_amount(code),Names.get_name(code),roe,"close price drop over 20%")
#           #      saled = true

#           #      # puts "#{old_day} , #{code} , old price #{old_price} #{old_code}"
#           #      # puts "#{day} , #{code} , new price #{pl_list[i][:price]} #{pl_list[i][:code]}  "
             
#           #      #puts
#           #   end
#           # end


#           if not saled

#             rec=nil
#             rec = w_list.find {|x| x['code'] == code} if cl_list.length >0 
#             if rec

#              # if  ((rec['high']-rec['close'])/rec['high'] >0.1)
#              #  if (rec['market_state'] == 4) or ((rec['high']-rec['close'])/rec['high'] >0.1)
#               if ((rec['high']-rec['close'])/rec['high'] >0.1)

#                 price = rec['close']
#                 roe = ((price - buy_price)/buy_price*100).floor

#                 # reason = ""
#                 # if (rec['market_state'] == 4)
#                 #   reason = "exit from bull " 
#                 # else
#                 #   reason = "drop over 10%  " 
#                 # end
          
#                 reason = "drop over 10%  " 
                
#                 puts "#{reason}:sell #{asset.get_amount(code)} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{rec['close']} (roe = #{roe}%)"  if show_trade!=0       
    
#                 asset.sell(code,day,rec['close'],asset.get_amount(code),Names.get_name(code),roe,reason)
#                 #next
#                 saled = true
#               end
#             end
#           end
#         end

#          asset.show_portfilo(day,pl_list) if show_trade!=0
#          strong_list=asset.get_code_list.collect{|x| x}
#          #last_check_list = get_price_list(asset.get_code_list,w_list,asset,old_pl_list)
#          pl_list = get_price_list(asset.get_code_list ,w_list,asset,old_pl_list)

#          last_check_list = pl_list.collect do |h|
#           ind= last_check_list.find_index {|x| x == h[:code]}
#           if ind!=nil
#            last_check_list[ind][:price] =(h[:price] > last_check_list[ind][:price]) ? h[:price]  : last_check_list[ind][:price]
#            last_check_list[ind]
#           else
#             h
#           end
#          end

#         #is there new stock to buy?
#         #w_list = Weekly_records.find(:all, :conditions=>"market_state = 6 and date = date(\'#{day.to_s}\')", :order=>"id asc")
#         # w_list += Weekly_records.find(:all, :conditions=>"market_state = 3 and date = date(\'#{day.to_s}\')", :order=>"id asc")  
#         # w_list += Weekly_records.find(:all, :conditions=>"market_state = 8 and date = date(\'#{day.to_s}\')", :order=>"id asc")  
#         # w_list += Weekly_records.find(:all, :conditions=>"market_state = 5 and date = date(\'#{day.to_s}\')", :order=>"id asc")  
#         w_list = run_class.class.find(:all, :conditions=>" date = date(\'#{day.to_s}\')", :order=>"id asc")  
        

#         len = w_list.length


#         if len>50
#             #code_list,price_list,amount_list = make_choice_list(w_list,asset,total_money,day)
#              run_para =Hash.new
#              if run_class.class== Daily_records
#                run_para[:class] = Daily_minlist_records
#                run_para[:last_days] = 2
#                run_para[:roe_skip] = 1
#              else
#                run_para[:class] = Weekly_minlist_records
#                run_para[:last_days] = 7
#                run_para[:roe_skip] = 1
#              end

#              code_list,price_list,amount_list = make_choice_list_by_min(w_list,asset,run_para,total_money,old_day)

#           code_list.each_with_index do |code,i|
#              asset.buy(code,day,price_list[i],amount_list[i],Names.get_name(code))
#              puts "buy  #{amount_list[i]} #{Names.get_name(code)}(#{code}) on #{day.to_s} at price #{price_list[i]}" if show_trade!=0  
             

#              h=Hash.new
#              h[:code] = code
#              h[:price] = price_list[i]
#              pl_list.push(h)
#           end
#         end
#         #end
#         iii+=1
#         # old_pl_list = pl_list.each_with_index.collect do |h|
#         #   ind= old_pl_list.find_index {|x| x == h[:code]}
#         #   if ind!=nil
#         #     (h[:close] > old_pl_list[ind][:close]) ? h[:close]  : old_pl_list[ind][:close]
#         #   else
#         #     h
#         #   end
#         # end

#         old_pl_list = pl_list.collect{|x| x}
#         old_day = day
#         #break
#       end # of each day

#       asset.show_log
#       asset.show_portfilo(Time.now.to_date,  pl_list)
# end