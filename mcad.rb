$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
 
require "shared_setup"
require 'time'
require 'active_record'
require 'common'
require 'asset'


$LOCAL_20_RECORDS = 20
$MACD_BELOW_ZERO_TIMES = 10
$PRICE_GREAT_BASE_TIMES = 10

#check if there exist buy point?
# diff across dea, and both below 0
def check_result(l,code)

  #p l
  #p l.length

  old_diff = 0
  old_dea = 0
  old_macd = 0
  elder_diff = -100
  first = true

  l.each_with_index do |rec,i|
    if first
       first = false
    else
       if rec[1] > old_diff

          if (old_dea > old_diff) and (rec[1] > rec[2]) # is this is a cross, diff cross dea ?
              # found a success record!!!!
              date = Weekly_records.get_date_by_week(code,rec[0])

              ts = ""

              ts += ",diff < 0" if rec[1] < 0

              
              start_ind = (i-$LOCAL_20_RECORDS) > 0 ? (i-$LOCAL_20_RECORDS) : 0 

              macd_count=l[start_ind..i-1].inject(0) {|res,var|  res + (var[3] < 0 ? 1: 0) } 

              #p macd_count

              ts += ",macd < 0 times #{macd_count}" if macd_count > $MACD_BELOW_ZERO_TIMES

              price_count =  l[start_ind..i-1].inject(0) {|res,var|  res + (var[4] > l[i-1][4] ? 1: 0) } 

              ts += ",price lower  times #{price_count}" if price_count > $PRICE_GREAT_BASE_TIMES

              ts += ", below ma20 " if rec[5] > rec[4]

              if date!= nil 
                 puts "Found Cross  point, #{code} at #{date.to_s}  #{ts}" #if date.year >= 2014
              end 

            
          end

          # if elder_diff > old_diff # old_diff is smallest one 

          #    if old_diff < 0
          #    # found a success record!!!!
          #      date = Weekly_records.get_date_by_week(code,rec[0])
          #      if date!= nil 
          #         puts "Found Valley point, #{code} at #{date.to_s}" #if date.year >= 2014
          #      end 
          #     end

          # end

       end 

    end

     elder_diff = old_diff

     old_diff = rec[1]
      old_dea = rec[2]
       old_mcad = rec[3]
        
  end
end


 # code = '600036'
 # date = Daily_records.get_date_by_week(code,3)
 # puts "Found buying point, #{code} at #{date.to_s}" if date!= nil

def na(x)
  return 1.upto(x).inject(0) { |result, element| result + element }
end


# $mcad_short = 12
# $mcad_long = 26
# $mcad_m    = 9



# def get_calc_para(num,t)
#   tl = 1.upto(num).collect do |x|
#     1.upto(x-1).inject(1) { |result, element| result*(1-t) }
#   end

#   return tl.reverse
# end

# $t_long  = get_calc_para($mcad_long, 2.0/($mcad_long+1)) 
# $t_short = get_calc_para($mcad_short,2.0/($mcad_short+1)) 
# $t_m     = get_calc_para($mcad_m,    2.0/($mcad_m+1)) 




#$t_short = (1.upto($mcad_short)).collect{|x| x.to_f/na($mcad_short)}
#$t_long = (1.upto($mcad_long)).collect{|x| x.to_f/na($mcad_long)}

#$t_m = (1.upto($mcad_m)).collect{|x| x.to_f/na($mcad_m)}

#p $t_long

# cal ema, input l is array with values, size <= 26
# def ema(l)
#   #nl = l[0..n]

#   #p l
#   #p l.length
#   tl = $t_m
#   len = l.length
#   tl = $t_short if len == $mcad_short
#   tl = $t_long if len == $mcad_long

#   #p l if len == $mcad_m 

#   re = l.each_with_index.inject(0) { |mem, (var,i)| mem + var*tl[i]  }
#   #Sp re
#   return re/(tl.inject(0) { |result, element| result + element })
# end

# def ema_old(l)
#   #nl = l[0..n]

#   #p l
#   tl = $t_m
#   len = l.length
#   tl = $t_short if len == $mcad_short
#   tl = $t_long if len == $mcad_long

#   #p l if len == $mcad_m 

#   re = l.each_with_index.inject(0) { |mem, (var,i)| mem + var*tl[i]  }
#   #Sp re
#   return re
# end

# l=[1,2,3,4,5,6]

# l2 = l.each_with_index.collect{|x,i| x*$t_long[i]}

# p l
# p $t_long
# p l2

# p l2.inject(0) { |mem, var| mem + var  }

# p ema(l,5)



def cal_mcad

  # start analysis
      wid = 1
    Names.get_code_list.each do |code|
       #puts code

       # check last (n+2) records. n = 18
       w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"id asc").last($mcad_long+$mcad_m+18)

       len= w_list.length 

       week_list =  w_list.collect{|row| row['close']} 
       $index_list = w_list.collect{|row| row['week_num']}  

       $ma20_list = ma(week_list,20)

       #p $ma20_list
       
       #week_list = 1.upto(50).colllect{|x| x} 
       #p $index_list
       #p week_list
      
       #p len

       #week_list2 = week_list[(len-($mcad_short+$mcad_m+5))..(len-1)] 

       #week_list2 = week_list[(len-50)..(len-1)] 

       
       #len = week_list2.length

       

       diff_list = []

       result_list = []

       if len >=$mcad_long
            $mcad_long.upto(len) do |i|
            t1 = ema(week_list[(i-$mcad_short)..(i-1)])
            #p t1
            t2 = ema(week_list[(i-$mcad_long )..(i-1)])
            #p t2

            diff_list.push (t1-t2)
           end

           #p diff_list
           #p make_diff_list(week_list,26,12)
           #diff_list = 1.upto(50).collect{|x| x} 
           len = diff_list.length

           dea_list=[]
           macd_list=[]

           #p len
           if len >= $mcad_m

               ($mcad_m).upto(len) do |i|
               diff = diff_list[i-1]
               dea = ema(diff_list[(i-$mcad_m)..(i-1)])
               macd = 2*(diff-dea)

               index = i+$mcad_long-2
               result_list.push([$index_list[index],diff,dea,macd,week_list[index],$ma20_list[index-19]])

               #dea_list.push(dea)
               #macd_list.push(macd)
               end


               
               #dl,cl = make_dea_macd_list(week_list,26,12,9,diff_list)
               #p dea_list
               #p dl
               #p macd_list
               #p cl
               #p result_list
               check_result(result_list,code)
           end
           
       end 
       #break;
    end
end

#cal_mcad

$MA60 = 60


$ma5_list = []
       $ma10_list = []
       $ma20_list = []
       $ma20_list = []

def peak_exist?(l,step)


end

# search ma5_peak and ma5 valley, if found, check close < ma60 ?
def check_result_ma60(l,code)

  #p l
  #p l.length

  old_ma5 = 0
  elder_ma5 = -10000
  first = true

  l.each_with_index do |rec,i|
    if first
       first = false if i==1
    else
       if (rec[2] > old_ma5) and (old_ma5 < elder_ma5)
              date = Weekly_records.get_date_by_week(code,rec[0])

              ts = ""
              ts += ", ma5 around ma60 " if (old_ma5 - rec[5])/rec[5] < 0.08 # not over 8% percent

              if date!= nil 
                 puts "Found Valley  point, #{code} at #{date.to_s}  #{ts}" #if date.year >= 2014
              end 
       end 

    end

     elder_ma5 = old_ma5
     old_ma5=rec[2]
        
  end # end of each
end

def cal_ma_peak(num_of_weeks_to_check)

  # start analysis
     
    Names.get_code_list.each do |code|
       ##puts code

       # check last (n+2) records. n = 18
       w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"id asc").last($MA60+num_of_weeks_to_check)

       len= w_list.length 

       next if len < $MA60

       week_list =  w_list.collect{|row| row['close']} 
       date_list =   w_list.collect{|row| row['date']} 
       $index_list = w_list.collect{|row| row['week_num']}  

       #p week_list.length

       $ma5_list = ma(week_list,5)
       $ma10_list = ma(week_list,10)
       $ma20_list = ma(week_list,20)
       $ma60_list = ma(week_list,60)
       #p $ma60_list.length
       

       # tl = $ma60_list.length  
       # next if tl<13
      
       # down_state = true
       #  if ($ma60_list[tl-1]-$ma60_list[tl-13]) >= 0 # ma60 should in up state 
       #    down_state = false
       # end

      

       result_list = []

       if len >=$MA60
            ($MA60).upto(len) do |i|
                
                if (i >= $MA60+8) 
                   #p i
                   if ($ma60_list[i-60]-$ma60_list[i-60-8]) >= 0 
                      result_list.push([$index_list[i-1],date_list[i-1],$ma5_list[i-5],$ma10_list[i-10],$ma20_list[i-20],$ma60_list[i-60]]) 
                   end
                end
             end

               #p result_list
               check_result_ma60(result_list,code)
           
           
       end 
       #break;
    end # end of code 
end

#in last may days,what is peak, what is low value
def find_peak(code,field,day,week_num)


  w_list = Weekly_records.find(:all, :conditions=>" code  = \'#{code}\' and date < date(\'#{day.to_s}\') ", :order=>"id asc").last(week_num)
  
   #date_list =   w_list.collect{|row| row['date']} 

   f_list = w_list.collect{|row| row[field]} 

   return f_list.max

   #p f_list


   # ts =                       "select MAX(#{field.to_s}) from weekly_records where code = \'#{code}\' and  date < date(\'#{day.to_s}\') and date >= date(\'#{(day-week_num*7).to_s}\')"
   # p ts 
   # rec = Weekly_records.find_by_sql("select count(id) from weekly_records where code = \'#{code}\' and  date < date(\'#{day.to_s}\') and date >= date(\'#{(day-week_num*7).to_s}\')")
   
   #  p rec[0].class

   #  p rec[0]
   # return rec[0][field] if rec
   # #p date_list
   #p date_list.length
end

# day= Time.new(2014,10,31,0,0,0).to_date

# p day.to_s
# p find_peak('002508','high',day,52)

def check_main_grow_state

  # start analysis
     
    Names.get_code_list.each do |code|
       ##puts code

       # check last (n+2) records. n = 18
       w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"id asc").last(5)

       len= w_list.length 

       next if len < 5

       #week_list =  w_list.collect{|row| row['close']} 
       #date_list =   w_list.collect{|row| row['date']} 
       #$index_list = w_list.collect{|row| row['week_num']}  

      found = false
       w_list.each do |rec|
         if not found 
           h1= find_peak(code,'high',rec['date'],52) 
           if rec['close'] > h1 
             puts "Found #{code} new higher at #{rec['date']}"
             found = true
           end
         end
       end

       #p week_list.length

       #break;
    end # end of code 
end

# def is_valley?(r1,r2,r3)
#   if (r3['close'] >= r3['open']) and (r2['close'] <= r2['open']) 
#      if (r3['close'] >= r2['close']) and (r2['close'] >= r1['close'])
#        return true
#      end 

#   end

#   return false

# end




#check_main_grow_state



def is_valley?(v1,v2,v3)
  #print v1,' ',v2,' ',v3
  #puts
  #puts "found"  if (v1>v2) and (v2<v3)
  return true if (v1>v2) and (v2<v3)
  return false
end

def abs(x)
  (x<0)?(-x):(x)
end

def find_buying_point(code,num_of_weeks_to_check)

  # start analysis
     
    #Names.get_code_list.each do |code|
       ##puts code

       ma60_look_ahead = 26
       
    
       return if num_of_weeks_to_check < 3
       #p code
       w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"id asc").last(ma60_look_ahead+num_of_weeks_to_check)

       #p w_list
       len= w_list.length 


     
       week_list =  w_list.collect{|row| row['close']} 
       #p week_list
       ma5_list  =  w_list.collect{|row| row['ma5']} 
       ma10_list  =  w_list.collect{|row| row['ma10']} 
       ma20_list  =  w_list.collect{|row| row['ma20']} 
       ma60_list =  w_list.collect{|row| row['ma60']} 
       date_list =  w_list.collect{|row| row['date']} 
       m_state_list = w_list.collect{|row| row['market_state']} 
       #p m_state_list[134]

       #p ma60_list

       #return if ma60_list[0] == 0.0 # ma60 data is valid
       #p week_list.length

       week_list[(ma60_look_ahead+2)..len-1].each_with_index do |x,i|
          if ma60_list[i] !=0.0

             index = i+ma60_look_ahead+2
             #p index
             #p m_state_list[index]
             #p date_list[index]
             if check_ma60_state(ma60_list[index],ma60_list[index-ma60_look_ahead]) # not in long down state
             #if m_state_list[index] == 1
                
               if is_valley?(ma5_list[index-2],ma5_list[index-1],ma5_list[index])
               #if is_valley?(week_list[index-2],week_list[index-1],week_list[index])
                  ts = ""
                  ts += ", ma5,ma10 around ma20" if   (abs((ma5_list[index] - ma20_list[index])/ma20_list[index]) < 0.02) and (abs((ma10_list[index] - ma20_list[index])/ma20_list[index]) < 0.02)
                  ts += ", ma5 around ma60" if   ((ma5_list[index] - ma60_list[index])/ma60_list[index]) < 0.08
                  puts "Found Valley  point, #{code} at #{date_list[index].to_s}  #{ts} " if ts.length > 0
               end


             end
          end

       end

end

def find_buying_point2(code,num_of_weeks_to_check,check_state=3,single_stock=false)

  # start analysis
     
    #Names.get_code_list.each do |code|
       ##puts code

       
       #p code
       w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"id asc").last(num_of_weeks_to_check+10)

       len = w_list.length
       return if len != num_of_weeks_to_check+10
       w_list[10..len-1].each_with_index do |rec,i|
         case rec['market_state']
         when 3

          #if check_state == 3
             if rec['days_in_state']==1
               puts "#{Names.get_name(code)}(#{code}) enter bull state on #{(rec['date']-7).to_s}"
             end

             if (rec['ma5']-rec['ma10'])/rec['ma10'] < 0.01
               puts "#{Names.get_name(code)}(#{code}) ma5 close to ma10 on #{(rec['date']).to_s}"
             end

             if single_stock

                 if (rec['high']-rec['close'])/rec['high'] > 0.15
                  puts "#{Names.get_name(code)}(#{code}) WARNING!!! top area !!! on #{(rec['date']).to_s}"
                 end

                 if (rec['close']-rec['open'])/rec['open'] > 0.15
                  puts "#{Names.get_name(code)}(#{code}) WARNING!!! speed up !!! on #{(rec['date']).to_s}"
                 end

                 if (rec['ma5']-rec['close'])/rec['close'] > 0.01
                  puts "#{Names.get_name(code)}(#{code}) close below ma5 #{(rec['date']).to_s}"
                 end
             end
           #end

         when 6
            #if check_state == 6

                max = w_list[i..9+i].inject(0) {|res,rec| (rec['close']>res) ? rec['close'] : res}

                if (max - rec['close'])/max> 0.1

                  if (rec['ma5']>rec['ma10']) and (w_list[i-2]['ma5'] < w_list[i-2]['ma10']) and (rec['close'] < rec['ma60'])
                   puts "#{Names.get_name(code)}(#{code}) ma5 cross ma10 and below ma60 on #{(rec['date']).to_s} on state 6"
                  end

                else
                  if single_stock
                      if (rec['ma5']-rec['ma10'])/rec['ma10'] < 0.01
                       puts "#{Names.get_name(code)}(#{code}) ma5 close to ma10 on #{(rec['date']).to_s} on state 6"
                      end
                  end
                end
             #end

         else
           
         end
       end
       #p w_list
       # len= w_list.length 


     
       # week_list =  w_list.collect{|row| row['close']} 
       # #p week_list
       # ma5_list  =  w_list.collect{|row| row['ma5']} 
       # ma10_list  =  w_list.collect{|row| row['ma10']} 
       # ma20_list  =  w_list.collect{|row| row['ma20']} 
       # ma60_list =  w_list.collect{|row| row['ma60']} 
       # date_list =  w_list.collect{|row| row['date']} 
       # m_state_list = w_list.collect{|row| row['market_state']} 
       #p m_state_list[134]

       #p ma60_list

       #return if ma60_list[0] == 0.0 # ma60 data is valid
       #p week_list.length

       # week_list[(ma60_look_ahead+2)..len-1].each_with_index do |x,i|
       #    if ma60_list[i] !=0.0

       #       index = i+ma60_look_ahead+2
       #       #p index
       #       #p m_state_list[index]
       #       #p date_list[index]
       #       if check_ma60_state(ma60_list[index],ma60_list[index-ma60_look_ahead]) # not in long down state
       #       #if m_state_list[index] == 1
                
       #         if is_valley?(ma5_list[index-2],ma5_list[index-1],ma5_list[index])
       #         #if is_valley?(week_list[index-2],week_list[index-1],week_list[index])
       #            ts = ""
       #            ts += ", ma5,ma10 around ma20" if   (abs((ma5_list[index] - ma20_list[index])/ma20_list[index]) < 0.02) and (abs((ma10_list[index] - ma20_list[index])/ma20_list[index]) < 0.02)
       #            ts += ", ma5 around ma60" if   ((ma5_list[index] - ma60_list[index])/ma60_list[index]) < 0.08
       #            puts "Found Valley  point, #{code} at #{date_list[index].to_s}  #{ts} " if ts.length > 0
       #         end


       #       end
       #    end

       # end

end

# search for lowest number
# def find_min_list(code,least_days=8*7, day=Time.now.to_date,show_info=false,return_list = false)

#     w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"date asc")
#     len=w_list.length
#     return nil if len == 0

#     ind = 0
#     w_list.reverse.each do |rec| 
#       if rec['date'] > day 
#         ind +=1 
#       else
#         break
#       end
#     end



#     w_list = w_list[0..len-ind-1]
#     len=w_list.length
#     return nil if len==0

#     close1=w_list[len-1]['close'] 
#     date1 = w_list[len-1]['date']

#     min_list=[]
#     min = close1
#     min_date = date1
    
#      # h= Hash.new
#      # h[:date]  = min_date
#      # h[:price] = min
#      # h[:last_days] = 0
#      # min_list.push(h)
     

#     w_list[0..len-2].reverse.each do |rec|
#       if ( rec['close'] - min) / min < -0.03

#         h= Hash.new
#         # p rec['date'].class
#         # p rec['date']
#         # p h[:date].class
#         # p h[:date]
#         h[:last_days] = (min_date - rec['date']).to_i 
#         h[:date]  = min_date
#         h[:price] = min

#         min_list.push(h)

#         min = rec['close']
#         min_date = rec['date']

        
#       # else
#       #   min_last_day = (rec['date'] - h[:date]).to_i
#       end

#       break if (day - rec['date']).to_i > 730
#     end


#     #min_list.push(h)
#     #p min_list

#     #min_list.each {|x| p x}
#     min_list.delete_if {|x| x[:last_days] < least_days}
#     min_list.each {|x| p x} if show_info
#     if min_list.length !=0
#       return min_list[0] if not return_list
#       return min_list if return_list
#     end
#    return nil
# end

def scan_for_min_chance(recent_days=120)

  sa = []
  #result_file = File.open(result_file_name,'w')

  d1 = Weekly_records.find(:last, :conditions=>" code = \'600036\'", :order=>"date asc")['date']
  d2 = Weekly_records.find(:last, :conditions=>" code = \'600000\'", :order=>"date asc")['date']

  return if d1!=d2

  last_day = d1


  Names.get_code_list.each do |code|
     #puts "Scanning #{code}..." 
     rec = Weekly_records.find(:last, :conditions=>" code = \'#{code}\'", :order=>"id asc")
     #p rec['date']
     min=Weekly_minlist_records.get_last_min(code,last_day) 
     next if min==nil 

     roe = ((rec['close']-min['price'])/min['price']*100).floor
     if (last_day - min['date']).to_i < recent_days 
     #if roe < 30
       # p rec['close']
       # p min[:price]
       #result_file.puts "#{Names.get_name(code)}(#{code}) (high:#{roe}%) found on #{min[:date].to_s} at price #{min[:price]},last for #{min[:last_days]} days"
       puts "#{Names.get_name(code)}(#{code}) (high:#{roe}%) found on #{min['date'].to_s} at price #{min['price']},last for #{min['last_days']} days"


       h=Hash.new
       h[:code] = code
       h[:date] = min['date']
       h[:price] = min['price']
       h[:last_days] = min['last_days']
       h[:days] = (Time.now.to_date - min['date']).to_i
       h[:roe] = roe
       h[:m_state] = rec['market_state']

      
       if rec['date'] == last_day
         sa.push(h)
       end

     end
  end
   
       sa.sort_by!{|h| h[:last_days]}
       sa.reverse.each {|x| p x}

       # sa.each do |h|
       #     result_file.puts "#{Names.get_name(h[:code])},#{h[:code]}, #{h[:roe]}%, #{h[:date].to_s},  #{h[:price]},#{h[:last_days]} "
       # end

       # result_file.close

end

def check_min_after_state(code)
  w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"id asc")
  min=Weekly_minlist_records.get_last_min(code,Time.now.to_date) 
  return if min == nil

  last= w_list[w_list.length-1]
  price = last['close']


  w_list.each do|rec|
    if (rec['market_state'] == 5) or (rec['market_state'] == 6) or (rec['market_state'] == 3) or (rec['market_state'] == 8)
       #h = min_list.find {|h| h[:date] == rec['date']}
       if min['date'] == rec['date']

       h =min 
       if h
        roe = ((price-h['price'])/h['price']*100).floor
        puts "#{Names.get_name(code)}(#{code}) (supposed roe:#{[roe]}%) #{rec['date'].to_s} price at #{rec['close']} "
        end
      end
    end
  end

end

def print_help
    puts "This Tool is used to do stock analysis from ma system, when ma5 step out a valley, it will check if ma5 is aroud ma60, if so , this is a buying point"
    puts "-n num    ---  how many records need to be analysis, default is 5 "
    puts "-c code   ---  which stock to be analysis "
    puts "-f code   ---  find min list for code "
    puts "-s recent_days   ---  scaning stock list to find min point in recent_days "
    puts "-h        ---  This help"    
end


num_of_weeks_to_check = 3
code = "600000"
state = 3
if ARGV.length != 0
 
    ARGV.each do |ele|       
      if  ele == '-h'          
          print_help
          exit 
        end 
  
        if ele == '-n'
          nn = ARGV[ARGV.index(ele)+1].to_i
          num_of_weeks_to_check = nn 
      
        end

        if ele == '-c'
          code = ARGV[ARGV.index(ele)+1].to_s
          #puts code
          find_buying_point2(code,num_of_weeks_to_check,state,true)  
        end

        if ele == '-a'
          Names.get_code_list.each do |code|
             #puts code
             #find_buying_point2(code,1,state,false)
             check_min_after_state(code)
          end
        end

        if ele == '-f'
          code = ARGV[ARGV.index(ele)+1].to_s
          #puts code
          Weekly_minlist_records.get_min_list(code).each do |rec|
              puts "#{Names.get_name(rec['code'])}(#{rec['code']}) on #{rec['date'].to_s}, minimum days #{rec['last_days']} at price #{rec['price']}"
          end
        end


        if ele == '-s'
          recent_days = ARGV[ARGV.index(ele)+1].to_i
          #puts code
          scan_for_min_chance(recent_days)
        end



   end
end

# aguo 

 #cal_ma_peak(num_of_weeks_to_check)
 

 #find_buying_point2(code,num_of_weeks_to_check)