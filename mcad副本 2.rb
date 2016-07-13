$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
 
require "shared_setup"
require 'time'
require 'active_record'

class Daily_records < ActiveRecord::Base
  def self.table_name() "daily_records" end
end

class Weekly_records < ActiveRecord::Base
  def self.table_name() "weekly_records" end

  def self.get_date_by_week(code,week)
    rec = self.find(:first,:conditions=>" code = \'#{code}\' and week_num = #{week}")

    return rec['date'] if rec
    return nil
  end
end

class Weekly_mcad_records < ActiveRecord::Base
  def self.table_name() "weekly_mcad_records" end
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


$mcad_short = 12
$mcad_long = 26
$mcad_m    = 9

t=2.0/($mcad_long+1)

def get_calc_para(num,t)
  tl = 1.upto(num).collect do |x|
    1.upto(x-1).inject(1) { |result, element| result*(1-t) }
  end

  return tl.reverse
end

$t_long  = get_calc_para($mcad_long, 2.0/($mcad_long+1)) 
$t_short = get_calc_para($mcad_short,2.0/($mcad_short+1)) 
$t_m     = get_calc_para($mcad_m,    2.0/($mcad_m+1)) 




#$t_short = (1.upto($mcad_short)).collect{|x| x.to_f/na($mcad_short)}
#$t_long = (1.upto($mcad_long)).collect{|x| x.to_f/na($mcad_long)}

#$t_m = (1.upto($mcad_m)).collect{|x| x.to_f/na($mcad_m)}

#p $t_long

# cal ema, input l is array with values, size <= 26
def ema(l)
  #nl = l[0..n]

  #p l
  #p l.length
  tl = $t_m
  len = l.length
  tl = $t_short if len == $mcad_short
  tl = $t_long if len == $mcad_long

  #p l if len == $mcad_m 

  re = l.each_with_index.inject(0) { |mem, (var,i)| mem + var*tl[i]  }
  #Sp re
  return re/(tl.inject(0) { |result, element| result + element })
end

def ema_old(l)
  #nl = l[0..n]

  #p l
  tl = $t_m
  len = l.length
  tl = $t_short if len == $mcad_short
  tl = $t_long if len == $mcad_long

  #p l if len == $mcad_m 

  re = l.each_with_index.inject(0) { |mem, (var,i)| mem + var*tl[i]  }
  #Sp re
  return re
end

# l=[1,2,3,4,5,6]

# l2 = l.each_with_index.collect{|x,i| x*$t_long[i]}

# p l
# p $t_long
# p l2

# p l2.inject(0) { |mem, var| mem + var  }

# p ema(l,5)

def ma(l,n)
  len = l.length
  return nil if len < n 

  l[(n-1)..len-1].each_with_index.collect { |x,i| (l[i..n+i-1].inject(0){|acc,val| acc + val}).to_f/n }
  
end

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
           #diff_list = 1.upto(50).collect{|x| x} 
           len = diff_list.length

           #p len
           if len >= $mcad_m

               ($mcad_m).upto(len) do |i|
               diff = diff_list[i-1]
               dea = ema(diff_list[(i-$mcad_m)..(i-1)])
               mcad = 2*(diff-dea)

               index = i+$mcad_long-2
               result_list.push([$index_list[index],diff,dea,mcad,week_list[index],$ma20_list[index-19]])

               end

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
              ts += ", ma5 below ma60 " if rec[5] > rec[2]

              if date!= nil 
                 puts "Found Valley  point, #{code} at #{date.to_s}  #{ts}" #if date.year >= 2014
              end 
       end 

    end

     elder_ma5 = old_ma5
     old_ma5=rec[2]
        
  end # end of each
end

def cal_ma_peak

  # start analysis
     
    Names.get_code_list.each do |code|
       ##puts code

       # check last (n+2) records. n = 18
       w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"id asc").last($MA60+10)

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
       #p $ma60_list
       
      

       result_list = []

       if len >=$MA60
            $MA60.upto(len) do |i|
               result_list.push([$index_list[i-1],date_list[i-1],$ma5_list[i-5],$ma10_list[i-10],$ma20_list[i-20],$ma60_list[i-60]])
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

check_main_grow_state

# cal_ma_peak