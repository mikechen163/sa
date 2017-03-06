$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
 
require "shared_setup"
require 'time'
require 'active_record'
require 'open-uri'
#require 'math'

class Daily_records < ActiveRecord::Base
  def self.table_name() "daily_records" end

  def initialize
    @date_list=[]

    list1 = self.class.find(:all,:conditions=>" code = \'601988\' ")
    list2 = self.class.find(:all,:conditions=>" code = \'601398\' ")
    list3 = self.class.find(:all,:conditions=>" code = \'601328\' ")

    
    # list1.each_with_index do |rec,i|
    #   d1=list1[i]['date']
    #   d2=list2[i]['date']
    #   d3=list3[i]['date']

    #   day = d1 if (d1==d2) 
    #   day = d1 if (d1==d3)
    #   day = d2 if (d2==d3)  
    #   @date_list.push(day)
    # end

    @date_list=(list1+list2+list3).uniq

  end

  def get_date_list
     return @date_list
  end  

  def get_days_between(d1,d2)
    ind1=@date_list.find_index{|x| x==d1}
    ind2=@date_list.find_index{|x| x==d2}
    
    return ind2-ind1 if (ind1!=nil) and (ind2!=nil)
    return 0

  end

  def get_last_record(code)
    return self.class.find(:last,:conditions=>" code = \'#{code}\' ")
  end

end

class Lastest_records < ActiveRecord::Base
  def self.table_name() "lastest_records" end
  def self.get_list_by_date(day)
     return self.find(:all,:conditions=>"date = date(\'#{day.to_s}\')")
  end

end

class Weekly_records < ActiveRecord::Base
   def initialize
    @date_list=[]
    #list1 = self.class.find(:all,:conditions=>" code = \'600028\' ").collect {|rec| rec['date']}
    # list1 = self.class.where(code: '600028').collect {|rec| rec['date']}
    # list2 = self.class.where(code: '601857').collect {|rec| rec['date']}
    # list3 = self.class.where(code: '600900').collect {|rec| rec['date']}
    
    #list2 = self.class.find(:all,:conditions=>" code = \'601857\' ").collect {|rec| rec['date']}
    #list3 = self.class.find(:all,:conditions=>" code = \'600900\' ").collect {|rec| rec['date']}

    # list1.each_with_index do |rec,i|
    #   d1=list1[i]['date']
    #   d2=list2[i]['date']
    #   d3=list3[i]['date']

    #   day = d1 if (d1==d2) 
    #   day = d1 if (d1==d3)
    #   day = d2 if (d2==d3)  
    #   @date_list.push(day)
    # end

    #@date_list=(list1+list2+list3).uniq.sort
    
    @date_list = self.class.where(code: '399905').collect {|rec| rec['date']}


  end

  def self.table_name() "weekly_records" end

  def self.get_date_by_week(code,week)
    rec = self.find(:first,:conditions=>" code = \'#{code}\' and week_num = #{week}")

    return rec['date'] if rec
    return nil
  end

  def self.get_list_by_code(code)
    #return self.find(:all,:conditions=>" code = \'#{code}\'")
    return self.where(code: "#{code}")
  end



  def self.get_market_states(code,date)
    rec = self.find(:first,:conditions=>" code = \'#{code}\' and date = date(\'#{date.to_s}\')")

    return rec['market_state'] if rec
    return nil
  end


  def self.get_week_num(code,date)
 #   p code
  #  p date
    rec = self.find(:first,:conditions=>" code = \'#{code}\' and date = date(\'#{date.to_s}\')")

    #date = date(\'#{day.to_s}\')
#    p rec

    return rec['week_num'] if rec
    return nil
  end

  def get_new_date(date,n)
     #rec_list = self.find(:all,:conditions=>" code = \'600036\' ")
     ind= @date_list.find_index {|x| x['date'] == date} 
     
     return @date_list[ind-n]['date'] if ind >= n
     return nil
  end

  
  def get_date_list
     return @date_list
  end  

  def self.get_start_date(code='000300')
     date_list = self.where(code:"#{code}").collect {|rec| rec['date']}
    return date_list[0]
  end

  def self.get_last_date(code='000300')
    date_list = self.where(code:"#{code}").collect {|rec| rec['date']}
    len = date_list.length
    return date_list[len-1]
  end

  def get_high_list(weeks,offset=0)
    len = @date_list.length
    cl = []
    @date_list[(len-1-offset-(weeks-1))..(len-1-offset)].each_with_index do |date,i|
      p date.to_s
     rec_list = self.class.find(:all,:conditions=>" date = date(\'#{date.to_s}\')")

     cl=rec_list.collect do |rec|
         h = cl.find {|h2| h2[:code] == rec['code']}
         if h!=nil
           h[:high] = rec['high'] if  rec['high'] > h[:high]
         else
            h=Hash.new 
            h[:code] = rec['code']
            h[:high] = rec['high']
            h[:date] = rec['date']
         end
         h
     end #collect

    end

    return cl
  end #get_high_list
   
end

class Weekly_etf_records < ActiveRecord::Base
   def initialize
    @date_list = self.class.find(:all,:conditions=>" code = \'000300\' ").collect {|rec| rec['date']}
   end

  def self.table_name() "weekly_etf_records" end

  def get_date_list
     return @date_list
  end  
  
end


class Monthly_records < ActiveRecord::Base
  def self.table_name() "monthly_records" end
end

class Daily_minlist_records < ActiveRecord::Base
  def self.table_name() "daily_minlist_records" end

  def self.get_min_list(code,least_day=7)
     min_list = self.find(:all,:conditions=>" code = \'#{code}\'")

     return nil if min_list.length == 0

      min_list=min_list.delete_if {|rec| rec['last_days']<least_day}
     return min_list 
  end

  def self.get_last_min(code,day,least_day=7*10)
     min_list = self.find(:all,:conditions=>" code = \'#{code}\'")

     return nil if min_list.length == 0

     min_list=min_list.delete_if {|rec| rec['last_days']<least_day}

     min_list.each do |min|
       return min if min['date'] <= day
     end

     return nil
  end

   def self.get_code_list(day,least_day=7)
      w_list = self.find(:all,:conditions=>" date = date(\'#{day.to_s}\')")

     return nil if w_list.length == 0

     w_list=w_list.delete_if {|rec| rec['last_days']<least_day}

     return w_list.collect{|x| x['code']}
  end
  def self.get_min_list_for_day(day,least_day=7)
    #p day
      w_list = self.find(:all,:conditions=>" date = date(\'#{day.to_s}\')")

     return nil if w_list.length == 0

     #p w_list.collect{|rec| rec['code']}

     w_list=w_list.delete_if {|rec| rec['last_days']<least_day}

     return w_list

  end
end #end of class def

class Weekly_minlist_records < ActiveRecord::Base
  def self.table_name() "weekly_minlist_records" end
  def self.get_min_list(code,least_day=7)
     min_list = self.find(:all,:conditions=>" code = \'#{code}\'")

     return nil if min_list.length == 0

      min_list=min_list.delete_if {|rec| rec['last_days']<least_day}
     return min_list 
  end

  def self.get_last_min(code,day,least_day=7*10)
     min_list = self.find(:all,:conditions=>" code = \'#{code}\'")

     return nil if min_list.length == 0

     min_list=min_list.delete_if {|rec| rec['last_days']<least_day}

     min_list.each do |min|
       return min if min['date'] <= day
     end

     return nil
  end

   def self.get_code_list(day,least_day=7)
      w_list = self.find(:all,:conditions=>" date = date(\'#{day.to_s}\')")

     return nil if w_list.length == 0

     w_list=w_list.delete_if {|rec| rec['last_days']<least_day}

     return w_list.collect{|x| x['code']}
  end

  def self.get_min_list_for_day(day,least_day=7)
      # p day
      # p least_day

      w_list = self.find(:all,:conditions=>" date = date(\'#{day.to_s}\')")

     return nil if w_list.length == 0

     #p w_list.collect{|rec| rec['code']}

     w_list=w_list.delete_if {|rec| rec['last_days']<least_day}

     return w_list

  end
end #end of class def

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

    def self.get_name(code)
    #rec = self.find(:first,:conditions=>" code = \'#{code}\' ")
    rec = self.where( code: "#{code}").first
  

    return rec['name'] if rec
    return nil
  end

end

class Stock_Basic_Info < ActiveRecord::Base
  def self.table_name() "stock_basic_info" end

  def self.get_stock_free_number(code)
    rec = self.where( code: "#{code}").first
    return rec['total_free_number'] if rec
    return nil    
   
  end


end #of class

class Etf_names < ActiveRecord::Base
  def self.table_name() "etf_name" end



  def self.get_code_list

    name_list = []
    self.all.each do |rec|
    
      name_list.push(rec['code'])
    end

    return name_list

     #return  (Time.now.to_date - s['date']).to_i - 1
  end

    def self.get_name(code)
    #rec = self.find(:first,:conditions=>" code = \'#{code}\' ")
    rec = self.where( code: "#{code}").first

    return rec['name'] if rec
    return nil
  end

end



def ma(l,n)
  len = l.length
  return nil if len < n 

  l[(n-1)..len-1].each_with_index.collect { |x,i| (l[i..n+i-1].inject(0){|acc,val| acc + val}).to_f/n }
  
end


$mcad_short = 12
$mcad_long = 26
$mcad_m    = 9



def get_calc_para(num,t)
  tl = 1.upto(num).collect do |x|
    1.upto(x-1).inject(1) { |result, element| result*(1-t) }
  end

  return tl.reverse
end

$t_long  = get_calc_para($mcad_long, 2.0/($mcad_long+1)) 
$t_short = get_calc_para($mcad_short,2.0/($mcad_short+1)) 
$t_m     = get_calc_para($mcad_m,    2.0/($mcad_m+1)) 

# def ema(l)

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


def make_diff_list(l,long_p,short_p)
   len = l.length

  return nil if len < long_p 

  l[(long_p-1)..len-1].each_with_index.collect do  |x,i| 
            #p i
            #p l
            t1 = ema(l[(i+short_p+2)..(i+long_p-1)])
            #p t1
            t2 = ema(l[i..(i+long_p-1)])
            #p t2

            t1-t2
  end 
end


def make_dea_macd_list(l,long_p,short_p,m,diff_list)
   len = l.length

  return nil , nil if len < long_p+m-1

  dea_list = l[(long_p+m-2)..len-1].each_with_index.collect do  |x,i| 
     ema(diff_list[i..(i+m-1)])
     end 

  macd_list =l[(long_p+m-2)..len-1].each_with_index.collect do  |x,i| 
     2*(diff_list[i+m-1]-dea_list[i])
     end 

  return dea_list,macd_list

end

def is_close_valley?(r1,r2,r3)
  if (r3['close'] >= r3['open']) and (r2['close'] <= r2['open']) 
     if (r3['close'] >= r2['close']) and (r2['close'] >= r1['close'])
       return true
     end 

  end

  return false

end

def is_valley?(v1,v2,v3)
  #print v1,' ',v2,' ',v3
  #puts
  #puts "found"  if (v1>v2) and (v2<v3)
  return true if (v1>v2) and (v2<v3)
  return false
end


def check_ma60_state(v1,v2)
  #puts 
  #print v1,' ',v2
  return false if (v1-v2)/v2 < -0.005 #dont buy any stock, now in bear market.

  #return false if (v1-v2)/v > 0.1  #v1 great than 10% percent v2
  return true 
end

def bear_market?(v1,v2)
  return true if (v2-v1)/v2 > 0.005 #dont buy any stock, now in bear market.
  return false 
end

# def leave_bull_market?(v1,v2)
#   return false if (v1-v2)/v2 > 0.2
#   return true
# end

def bull_market?(v1,v2)
  return true if (v1-v2)/v2 > 0.22  # the bigger, the strict
  return false
end


def start_bear_market?(v1,v2)
  return true if (v2-v1)/v2 > 0.1
  return false
end

def find_max(l,n)
   len = l.length
   #p l[(len-n)..len-1] 
   l[(len-n)..len-1].inject(0) { |mem, var|  var > mem ? var : mem  }
end

def find_min(l,n)
   len = l.length
   #p l[(len-n)..len-1] 
   l[(len-n)..len-1].inject(10000) { |mem, var|  var < mem ? var : mem  }
end

def find_number_of_record(l,date)

  #p date
   tl = l.reverse
   pos= 1
   #p date
  tl.each do |day|
     #p pos 
     #p day
     return pos if day<= date 
     pos += 1
   end

   return pos
end
# def get_52week_high(week_list,date_list,i)
   
#    num = find_number_of_record(date_list[0..i-1],date_list[i]-52*7)
#    return  find_max(week_list[0..i-1],num)
# end

def find_max_pos(l,n,dl)
   len = l.length
   #p len
   #p l[(len-n)..len-1] 
   max = l[(len-n)..len-1].inject(0) { |mem, var|  var > mem ? var : mem  }
   ind =  l[(len-n)..len-1].index(max)
   return max,dl[(len-n)..len-1][ind]
end

def find_min_pos(l,n,dl)
   len = l.length
   #p l[(len-n)..len-1] 
   min = l[(len-n)..len-1].inject(10000) { |mem, var|  var < mem ? var : mem  }
   ind =  l[(len-n)..len-1].index(min)
   return min,dl[(len-n)..len-1][ind]
end


def get_52week_high(week_list,date_list,i,pos_ptr=false)   
   num = find_number_of_record(date_list[0..i-1],date_list[i]-52*7)
   #p num
   return  find_max(week_list[0..i-1],num) if not pos_ptr
   return find_max_pos(week_list[0..i-1],num,date_list[0..i-1])
end

def get_52week_low(week_list,date_list,i,pos_ptr=false)   
   num = find_number_of_record(date_list[0..i-1],date_list[i]-52*7)
   #return  find_max(week_list[0..i-1],num) if not pos_ptr
   return find_min_pos(week_list[0..i-1],num,date_list[0..i-1])
end

def get_13week_low(week_list,date_list,i,pos_ptr=false)   
   num = find_number_of_record(date_list[0..i-1],date_list[i]-13*7)
   #return  find_max(week_list[0..i-1],num) if not pos_ptr
   return find_min_pos(week_list[0..i-1],num,date_list[0..i-1])
end


def get_price_list(cl_list, w_list,asset,old_pl_list)
  pl_list = cl_list.collect do |code|
                 rec = w_list.find {|x| x['code'] == code}

                  h=Hash.new
                  h[:code ] = code 

                 if rec
                     h[:price] = rec['close'] 
                 else
                     #h[:price] = asset.get_price(code)
                     x = old_pl_list.find {|x| x[:code] == code}
                     if x!=nil
                        h[:price] = x[:price]
                     else
                        h[:price] = asset.get_price(code)
                     end
                 end
                 h
             end

    return pl_list
end

 def search_first_nh(code,day)
     # p code, day
     w_list = Weekly_records.find(:all, :conditions=>"code = \'#{code}\'", :order=>"id asc")

     #p w_list.length

     ind = w_list.find_index{|rec| rec['date'] == day}
     # p w_list[ind]['date'] 

     new_high_date=w_list[ind]['new_high_date']
     i=1
     while (new_high_date - w_list[ind-i]['new_high_date']).to_i < 90
      new_high_date = w_list[ind-i]['new_high_date']
      i+=1
     end
     
     return w_list[ind-i+1]
end

 def previous_work_day(day)
#   puts "sss"
  #p day
  pd = day - 1

 #  p pd
  pd = pd - 1 if pd.sunday?
  pd = pd - 1 if pd.saturday?

  return pd
 end

 def format_roe(roe,digit=2)

  negtive = false
  if roe<0
    roe = -roe
    negtive = true
  end

  roe=((roe*100).round)/100.0

  s=roe.to_s
  ind=s.index('.')

  #puts "roe = #{s}"

  return "  0.00%" if roe==0.0
  if roe<10
    if not negtive
      return "  #{s}0%" if ((s.length-2) == ind)
      return "  #{s}%"
    else
      return " -#{s}0%" if ((s.length-2) == ind)
      return " -#{s}%"
    end
  end

  if not negtive
    if roe<100
      return " #{s}0%" if ((s.length-2) == ind)
      return " #{s}%"
    else
      return "#{s}0%" if ((s.length-2) == ind)
      return "#{s}%"
    end
  else
    return "-#{s}0%" if ((s.length-2) == ind)
    return "-#{s}%"
  end

 end

 def format_code(code,etf_flag=false)

  #etf_flag = false

  #p code

  #etf_flag = true if (code.index("SH000")!=nil) or (code.index("SH88")!=nil) or  (code.index("SZ399")!=nil)
 
  if not etf_flag
    name = Names.get_name(code)
  else
    name = Etf_names.get_name(code)    
  end

  name = Etf_names.get_name(code) if (name==nil)
  
  if name == nil
    puts "unknown name for #{code}"
    return code.to_s
  end
 
  #p name.length
  name +=' ' if name.length<4

  ns = name+'('+code.to_s+')'
  #p ns.length
  return ns
end

def format_price(price)
  s=price.to_s
  ind=s.index('.')
  #return ' '+price.to_s+'0' if (price<10) and ((price*100).floor%10 == 0)
  return ' '+s+'0' if (price<10) and ((s.length-2) == ind)
  return ' '+price.to_s if (price<10) 
  #return price.to_s+'0' if (((price*100).floor)%10 == 0)
  return s+'0' if (s.length-2) == ind
  return price.to_s 
end
 
def format_big_num(num,reserve_space=false)
  return "0.0" if num==0.0

  tn=num.floor

  tail=((num.remainder(1)*100).floor/100.0).to_s
  len=tail.length
  str=tail[1..len-1]

  #p tn
  while tn>0
   #p tn
   ns =(tn%1000).to_s
   ns = "00" + ns if (tn%1000) < 10
   ns = "0" + ns if ((tn%1000) >= 10) and ((tn%1000)<=99)

   #p ns 

   str.insert(0,','+ ns)
   
   tn = tn/1000
  end
  len = str.length

  i=1

  while str[i]=='0'
    str[i]=' ' if reserve_space
    i+=1
  end

  st=i
  st=1 if reserve_space

  return str[st..len-3] if (str[len-1]=='0') and (str[len-2]=='.') 
  return str[st..len-1]
end


# def get_market_str(state)
#   return "bear market" if state == 0
#   return "start bear " if state == 1
#   return "shake in low positon"   if state == 128
#   return "main upstream "         if state == 129
#   return "shake in high positon"  if state == 130

# end

# def display_stock_states(code)
  
#       old_market_state = 0

#        # check last (n+2) records. n = 18
#        w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"id asc")
#        start_date = w_list[0]['date']

#        puts ""
#        w_list.each_with_index do |rec,i|
#          market_state = rec['market_state']
#          if market_state != old_market_state
            
#            puts "#{code} turn in #{get_market_str(market_state)} at #{rec['date']}" 
#            old_market_state = market_state
#          end
#        end
    
# end

def load_name_into_database

  name_list = []
  
  File.open("name.txt").each_line do |line|

    fn,fcode,code_name,market=line.split ('|')

    ts = "#{fn},\'#{fcode.to_s}\',\'#{code_name.to_s}\',\'#{market[0..1].to_s}\'"
  
    #p ts        
    name_list.push(ts)
    #p line
  end

   insert_data('name',name_list) if name_list.length!=0

end

def get_data_from_sina(code)
 # pref = "sh"
 #   pref = "sz" if (code[0]!='6')   
   
  uri="http://stock.finance.sina.com.cn/usstock/quotes/aapl.html"
   
    html_response = nil  
    open(uri) do |http|  
      html_response = http.read  
    end

    p html_response  
    #sa= html_response.split('http://vip.stock.finance.sina.com.cn/quotes_service/view/vMS_tradehistory.php?symbol')  

    #return sa
   # sa=html_response.scan(/[0-9]+\.[0-9]+/)

    #return sa[0].to_f,sa[3].to_f,sa[2].to_f,sa[4].to_f
 end

def get_price_from_sina(code)
  pref = "sh"
    pref = "sz" if (code[0]!='6')   
   
  uri="http://hq.sinajs.cn/list=#{pref+code}"
   
    html_response = nil  
    open(uri) do |http|  
      html_response = http.read  
    end  
    #sa= html_response.split('http://vip.stock.finance.sina.com.cn/quotes_service/view/vMS_tradehistory.php?symbol')  

    #return sa
    sa=html_response.scan(/[0-9]+\.[0-9]+/)

    return sa[0].to_f,sa[3].to_f,sa[2].to_f,sa[4].to_f
 end

  def get_trade_data_from_sina(code)
  pref = "sh"
    pref = "sz" if (code[0]!='6')   
   
  uri="http://hq.sinajs.cn/list=#{pref+code}"
   
    html_response = nil  
    open(uri) do |http|  
      html_response = http.read  
    end  
    #sa= html_response.split('http://vip.stock.finance.sina.com.cn/quotes_service/view/vMS_tradehistory.php?symbol')  

    #return sa

    # sa=html_response.scan(/[0-9]\,/)
    # p sa
    # sa=html_response.scan(/[0-9]+\.[0-9]+/)
    # p html_response.index(sa[6])
    # index = html_response.index(sa[6])+sa[6].length
    # p index
    sa=html_response.split(',')
    
    return sa[1].to_f,sa[4].to_f,sa[3].to_f,sa[5].to_f,sa[8].to_i,sa[9].to_f
 end


def calc_fh_inc(years,n1,n2)
  return 0 if n1/n2 < 0
  return ((Math.exp(Math.log(n2/n1)/years)-1)*10000).to_i.to_f/100
end

def show_roe_list(code,years=20)
  rvn = get_revenue_from_ntes(code)
  asset = get_assets_from_ntes(code)
  as_list = asset[asset.length-2]
  rvn_list = rvn[rvn.length-7] 
  income_list = rvn[1] 
  
  puts "#{format_code(code)}  "
  #print rvn_list
  #puts
  puts "-------------------------------------增长和回报率分析------------------------------"
  roe_list = []
  rvn_list.each_with_index do |rr,i|
    if (i>1) and (i<=years+1)
     # puts "#{i} #{rvn_list[i]} #{rvn_list[i-1]}"
      icn = income_list[i].split(',').inject(:+).to_f
      ic = income_list[i-1].split(',').inject(:+).to_f
      icc = ((ic-icn)/icn*10000).to_i.to_f/100
      lyn = rvn_list[i].split(',').inject(:+).to_f
      ly = rvn_list[i-1].split(',').inject(:+).to_f 
      inc = ((ly-lyn)/lyn*10000).to_i.to_f/100
      asy = as_list[i].split(',').inject(:+).to_f
      asyn = as_list[i-1].split(',').inject(:+).to_f
      roe = (ly/asy*10000).to_i.to_f/100
      roe_list.push(roe)
      inc_asy = ((asyn-asy)/asy*10000).to_i.to_f/100
      puts "#{rvn[0][i-1]} 收入[#{income_list[i-1]}万,增长=#{icc}%] 利润[#{rvn_list[i-1]}万,增长=#{inc}%], 净资产[收益率=#{roe}%, 增长率=#{inc_asy}%]"
    end
  end

  #puts "#{rvn[0][rvn_list.length-1]} 收入=#{income_list[income_list.length-1]}万，利润=#{rvn_list[rvn_list.length-1]}万" 

  if (years > rvn_list.length-1)
    years = rvn_list.length-1
    puts "#{rvn[0][rvn_list.length-1]} 收入=#{income_list[income_list.length-1]}万，利润=#{rvn_list[rvn_list.length-1]}万" 
  end

  years = 3 if (years < 3)

  #p years
  #p roe_list

  ave_roe = roe_list[0..(years-1)].sum/years
  ave_roe = roe_list[0..(years-1)].sum/(years-1) if years == (rvn_list.length-1)

  puts "过去#{years}年，收入复合增长率=#{calc_fh_inc(years,income_list[years].split(',').inject(:+).to_f,\
  income_list[1].split(',').inject(:+).to_f)}%,\
  利润复合增长率=#{calc_fh_inc(years,rvn_list[years].split(',').inject(:+).to_f,\
  rvn_list[1].split(',').inject(:+).to_f)}%,\
  净资产复合增长率=#{calc_fh_inc(years,as_list[years].split(',').inject(:+).to_f,as_list[1].split(',').inject(:+).to_f)}%, 净资产平均收益率=#{format_roe(ave_roe)}"

  puts
  puts "-------------------------------------利润分析------------------------------"
  
  cost_material_list = rvn[9]
  cost_sale_list = rvn[21]
  cost_manage_list = rvn[22]
  cost_finance_list = rvn[23] 
  rvn__operating_list = rvn[rvn.length-14]
  rvn__before_tax_list = rvn[rvn.length-10]
  tax_list = rvn[rvn.length-9]
  minor_holder_list = rvn[rvn.length-4]
  eps_list = rvn[rvn.length-1]

  rvn_list.each_with_index do |rr,i|
    if (i>0) and (i<=years)
    
      #毛利率
      ic = income_list[i].split(',').inject(:+).to_f
      cme = ic - cost_material_list[i].split(',').inject(:+).to_f
      cm_ratio = ((cme)/ic*10000).to_i.to_f/100 

      threefee = cost_sale_list[i].split(',').inject(:+).to_f + cost_manage_list[i].split(',').inject(:+).to_f + cost_finance_list[i].split(',').inject(:+).to_f
      threefee_ratio = ((threefee)/ic*10000).to_i.to_f/100  
      tf1 = ((cost_sale_list[i].split(',').inject(:+).to_f)/threefee*100).to_i
      tf2 = ((cost_manage_list[i].split(',').inject(:+).to_f)/threefee*100).to_i 
      tf3 = ((cost_finance_list[i].split(',').inject(:+).to_f)/threefee*100).to_i

      rvn_opr  = rvn__operating_list[i].split(',').inject(:+).to_f
      opr_ratio = ((rvn_opr)/ic*10000).to_i.to_f/100  

      rvn_btax = rvn__before_tax_list[i].split(',').inject(:+).to_f
      btax_ratio = ((rvn_btax)/ic*10000).to_i.to_f/100  

      tax      = tax_list[i].split(',').inject(:+).to_f
      tax_ratio = ((tax)/rvn_btax*10000).to_i.to_f/100  

      lyn = rvn_list[i].split(',').inject(:+).to_f
      net_rvn_ratio = ((lyn)/ic*10000).to_i.to_f/100  

      mholder  = minor_holder_list[i].split(',').inject(:+).to_f
      mh_ratio = ((mholder)/lyn*10000).to_i.to_f/100   

      eps      = eps_list[i].split(',').inject(:+).to_f
      
      
      puts "#{rvn[0][i]} 毛利率=#{cm_ratio}%, 三费率＝#{threefee_ratio}%，运营利润率=#{opr_ratio}%,税前利润率=#{btax_ratio}%,税率=#{tax_ratio}%,净利润率=#{net_rvn_ratio}%，[销售:管理:财务]费用比例=#{tf1}:#{tf2}:#{tf3} 少数股东权益=#{mh_ratio}%, eps=#{eps} "
    end
  end

  return roe_list

 end #func

 def get_cash_from_ntes(code,year=true)
  if year
    uri="http://quotes.money.163.com/f10/xjllb_#{code}.html?type=year"
  else
    uri="http://quotes.money.163.com/f10/xjllb_#{code}.html"
  end

  return get_finance_info_from_ntes(uri) 
 end

 def get_assets_from_ntes(code,year=true)
  if year
    uri="http://quotes.money.163.com/f10/zcfzb_#{code}.html?type=year"
  else
    uri="http://quotes.money.163.com/f10/zcfzb_#{code}.html"
  end

  return get_finance_info_from_ntes(uri) 
 end

 def get_revenue_from_ntes(code,year=true)
  if year
    uri="http://quotes.money.163.com/f10/lrb_#{code}.html?type=year"
  else
    uri="http://quotes.money.163.com/f10/lrb_#{code}.html"
  end

  return get_finance_info_from_ntes(uri) 
 end

 def get_stockinfo_data_from_ntes(code)
   
   
  uri="http://quotes.money.163.com/f10/gdfx_#{code}.html"
   
    html_response = nil  
    open(uri) do |http|  
      html_response = http.read  
    end  
    title = html_response.scan(/<title>(.*)<\/title>/)
    ind = title[0][0].split(code.to_s)
    #puts ind[0].length
    name = ind[0][0..ind[0].length-2]
    #puts name
    #puts name.length

    name = name + " " if name.length == 3
    name = name + " " if name.length == 5
   
    sa=html_response.split('table_bg001')
    
      al = sa[2].scan(/[0-9]+\.[0-9]+/)
      #al.each_with_index {|c,i| puts "#{i} : #{c}"}

      return name,al.collect{|x| x.to_f} 
    
 end

 def get_finance_info_from_ntes(url)
   
   r=[]
   
    html_response = nil  
    open(url) do |http|  
      html_response = http.read  
    end  
    
    sa=html_response.split('table_bg001')

     thl = []

      sa[1].split('</tr>').each do |line|
        #puts line
        al=line.scan(/<td.*>(.*)<\/td>/)
        al2=line.scan(/<strong>(.*)<\/strong>/)
        
      
        if al2.length !=0 
          thl.push al2[0][0].to_s if al2.length !=0 
        else
          thl.push al[0][0].to_s if al.length !=0
        end

      end

      # puts thl
      # thl.each_with_index do |e,i|
      #   puts "#{i}:#{e}:#{e.length}"
      # end
    
      sl = sa[2].length
      year_list = sa[2].scan(/[0-9]+\-[0-9]+\-[0-9]+/)

      nyl=[]
      nyl.push('报告日期')
      year_list.each {|x| nyl.push x}
      r.push(nyl)

      len = year_list.length
      index = sa[2].index(year_list[len-1]) + 10
      index_end = sa[2][index..(sl-1)].index('table')

      ll = sa[2][index..(index+index_end)].split('</tr>')

      ll.each_with_index do |line,i|
        ##puts "#{i} : #{line}"
        al=line.scan(/[0-9\-][0-9.,\-]*/)
        nal=[]
        nal.push(thl[i-1])
        al.each {|x| nal.push x}

        if al.length !=0
          r.push(nal)
          #print "#{i}:#{thl[i-1]}"
          #al.each {|x| print "#{x} "}
          puts
        end

      end
    return r
 end #func


 def get_history_data_from_nasdaq(code)
   uri="http://www.nasdaq.com/symbol/#{code}/historical"
   
    html_response = nil  
    open(uri) do |http|  
      html_response = http.read  
    end  

    p html_response
 end

  def get_list_data_from_sina(codelist)

  sl = ""

  codelist.each do |code|
    pref = "sh"
    pref = "sz" if (code[0]!='6')   

    #hk02208  gb_bidu
    pref = "" if (code[0]=='h') or (code[0]=='g')  



    if sl.length >0
      sl += ","+ pref + code 
    else
      sl = pref+code
    end

  end

  uri="http://hq.sinajs.cn/list=#{sl}"

  #p uri

  #return
   
    html_response = nil  
    open(uri) do |http|  
      html_response = http.read  
    end 

    #p html_response

    rl =  html_response.split("hq_str_")
    #p rl[0]
    #p rl[1]
    #p rl[2]
    tta=[]

    rl.each_with_index do |str,i|
      #sa=str.scan(/[0-9]\,/)
      if i != 0
        #p str
        sa=str.split(',')
        #p sa
    
        #ta=[ sa[0][2..7], sa[1].to_f,sa[4].to_f,sa[3].to_f,sa[5].to_f,sa[8].to_i,sa[9].to_f]
        h= Hash.new
        h[:code] = sa[0][2..7]
        h[:open] = sa[1].to_f
        h[:high] = sa[4].to_f
        h[:close] = sa[3].to_f 
        h[:low]   = sa[5].to_f
        h[:volume] = sa[8].to_f
        #puts h[:code]
        
        if (h[:code] == '000300') or (h[:code][0..2] == '399' ) or (h[:code][0..2] == '159' )
           h[:trade_ratio] = 0.0 
           h[:total_mv] = 0.0 
        else 
           #puts h[:code]
           free_number = Stock_Basic_Info.get_stock_free_number(h[:code])
           h[:total_mv] = (h[:close]*free_number*100).to_i/100.0

           if free_number > 0.0
             h[:trade_ratio] = ((h[:volume]/(free_number*10000))).to_i/100.0
             #puts "#{free_number} #{h[:volume]}" if not (h[:trade_ratio] > 0.0) 
             
           else
             #puts h[:code]
              h[:trade_ratio] = 0.0

           end
        end

        h[:amount] = (sa[9].to_i/100).to_f/100
        h[:ratio] = 0.0
        h[:ratio] = (h[:close]-h[:open])/h[:open]*100 if h[:open] >0
        tta.push(h)
      end
    end

    #p tta
    return tta

    #sa= html_response.split('http://vip.stock.finance.sina.com.cn/quotes_service/view/vMS_tradehistory.php?symbol')  

    #return sa

    # sa=html_response.scan(/[0-9]\,/)
    # p sa
    # sa=html_response.scan(/[0-9]+\.[0-9]+/)
    # p html_response.index(sa[6])
    # index = html_response.index(sa[6])+sa[6].length
    # p index
    #sa=html_response.split(',')
    
    #return sa[1].to_f,sa[4].to_f,sa[3].to_f,sa[5].to_f,sa[8].to_i,sa[9].to_f
 end

 def search_for_candidate(ma)
  

     datelist = Weekly_records.new.get_date_list
     len = datelist.length
     date = datelist[len-1]
     w_list = Weekly_records.find(:all, :conditions=>"date = date(\'#{date.to_s}\')", :order=>"id asc")
       # check last (n+2) records. n = 18
     
      cl=[]
      puts "close < #{ma}"
      w_list.each do |rec|
       code = rec['code']
       value = rec[ma]
       #puts "#{format_code(code)} at price #{rec['close']}" if rec['date'] == rec['new_low_date']
       if rec['close'] < value
         cl.push(code)
       end
       #puts "#{format_code(code)} at price #{rec['close']}" if rec['close'] < value
    end # of each code

    return cl
end

def get_topN_from_sina(topN,sortby)

  batch_num = 300
  cl = Names.get_code_list

  len = cl.length
  #p len

  step = 0

  all = []


  if sortby <20
    t1= Time.now
    while (step < len)
       a_end = step+batch_num-1
       a_end = len-1 if a_end > len 
       #p step
       #p a_end
       tl = get_list_data_from_sina(cl[step..a_end])
       #p tl
       all += tl
       step += batch_num
    end
    t2 = Time.now
    

    puts "fetching all data from sina takes #{t2-t1} seconds."
  end
  #p (t2.usec-t1.usec)/1000
  

  #p all.length
  case sortby
  when 10
       all.sort_by!{|h| h[:code]}
       #all.reverse!
    when 0
       all.sort_by!{|h| h[:amount]}
       all.reverse!
    when 10
        all.delete_if {|h| h[:volume] == 0.0}
       all.sort_by!{|h| h[:amount]}
    when 1
       all.sort_by!{|h| h[:volume]}
       all.reverse!
    when 11
      all.delete_if {|h| h[:volume] == 0.0}
       all.sort_by!{|h| h[:volume]}
    when 2
       all.sort_by!{|h| h[:ratio]}
       all.reverse!
    when 3
       all.sort_by!{|h| h[:ratio]}
    when 4
       all.sort_by!{|h| h[:amount]}
       all.reverse!
       all.delete_if{|h| h[:ratio] < 3}
    when 5
      # create a new high 
      cl=Weekly_records.new.get_high_list(4,0)
      p cl.length
      #p cl
      all.sort_by!{|h| h[:amount]}
      all.reverse!
      all.delete_if do |h|
        h2=cl.find {|h3| h3[:code] == h[:code]}

        if h2 != nil
          (h2[:high] > h[:close]) ? true : false
        else
          true
        end 

      end

    when 6
       all.sort_by!{|h| h[:trade_ratio]}
       all.reverse!
    when 7
      all.delete_if {|h| h[:volume] == 0.0}

       all.sort_by!{|h| h[:trade_ratio]}

     when 12
       all.sort_by!{|h| h[:total_mv]}
       all.reverse!
    when 13
      all.delete_if {|h| h[:volume] == 0.0}

       all.sort_by!{|h| h[:total_mv]}
      
    when 20 
      cl = search_for_candidate('ma5')
      all=get_list_data_from_sina(cl)
      all.delete_if{|h| h[:amount] == 0.0}
      all.sort_by!{|h| h[:ratio]}
      all.reverse!

    when 21
      cl = search_for_candidate('ma10')
      all=get_list_data_from_sina(cl)
      all.delete_if{|h| h[:amount] == 0.0}
      all.sort_by!{|h| h[:ratio]}
      all.reverse!
    when 22 
      cl = search_for_candidate('ma20')
      all=get_list_data_from_sina(cl)
      all.delete_if{|h| h[:amount] == 0.0}
       all.sort_by!{|h| h[:ratio]}
      all.reverse!
    when 23 
      cl = search_for_candidate('ma60')
      all=get_list_data_from_sina(cl)
      all.delete_if{|h| h[:amount] == 0.0}
       all.sort_by!{|h| h[:ratio]}
      all.reverse!
    
    else
      puts "unknown sort method"
  end

  puts "#{Time.now.strftime("%y-%m-%d %H:%M:%S")}"
  all[0..topN].each do |h|
     puts "#{format_code(h[:code])} 当前价=#{format_price(h[:close])}, 涨幅=#{format_roe(h[:ratio])},换手率=#{format_roe(h[:trade_ratio])}, 成交量=#{format_big_num(h[:volume].to_i/100)}手, 成交额=#{format_price(h[:amount])}万元 流通市值=#{format_price(h[:total_mv])}亿 " 
  end


  #all=get_list_data_from_sina(Name.get_code_list)   
end

def get_fuquan_factor_from_sina(code)

   day = Time.now.to_date
   rep_times = 0

   while rep_times < 10

       return 1.0 if (code[0..2] == '399') or (code[0..2] == '159')
       sa = get_history_data_from_sina_ori_fuquan(code,day)
       len=sa.length
       if len==1
          day -= 90
       else

         div_len = sa[1].length
         sa[len-1]=sa[len-1][0..div_len-1]
         sa=sa[1..len]

         date =sa[0].scan(/[0-9]+\-[0-9]+\-[0-9]+/)
         pa=sa[0].scan(/[0-9]+\.[0-9]+/)
         
         #p "#{date.to_s} #{pa.to_s} "
         qf = pa[pa.length-1].to_f

         return qf
       end #end if
       rep_times += 1

   end #while
 
   return nil

end

#只提供在一个季度内的数据
def get_h_data_from_sina_internal(code,d1,d2,qf)

  ra = []

  if (code[0..2] == '399') or (code[0..2] == '159')
    sa = get_history_data_from_sina(code,d1)
  else
    sa = get_history_data_from_sina_ori_fuquan(code,d1)
  end
       len=sa.length
       return [] if len==1

       div_len = sa[1].length
       sa[len-1]=sa[len-1][0..div_len-1]
       sa=sa[1..len]

       #p sa.length
       sf=ef=false
       sa.sort.each do |line|
         #p line
         date =line.scan(/[0-9]+\-[0-9]+\-[0-9]+/)
         pa = line.scan(/[0-9]+\.[0-9]+/)

         if (code[0..2] == '399') or (code[0..2] == '159')
           nbs = line.scan(/[0-9]+/)
           nbs_len = nbs.length
           nbs_len -= 1 if nbs[nbs_len-1] == '2'
           pa.push(nbs[nbs_len-2])
           pa.push(nbs[nbs_len-1])
         end
         
         #p "#{date.to_s} #{pa.to_s} "
        
         sf = true if  Date.parse(date[0]) >= d1 
         ef = true if  Date.parse(date[0]) > d2 
         
          
         if sf and (not ef)
          ta=[]
          ta.push(date[0])
          pa.each_with_index do |x,i|
            if i<4
              #ta.push (((x.to_f/qf)*100).round)/100.0
              ta.push  x.to_f
            else
              ta.push(x.to_f)
            end
          end

          #p ta
          ra.push(ta) 
          end #end if 

        end #each line    
       return ra
end

def get_first_day_for_season(day)
  season = (day.month+2)/3
  mon = (season-1)*3+1
  return Date.new(day.year,mon,1)
end

def get_last_day_for_season(day)
  season = (day.month+2)/3
  mon = (season)*3
  dd=30
  dd=31 if (season==1) or (season==4)
  return Date.new(day.year,mon,dd)
end

def make_date_season_list(d1,d2)

  sa = []
  ta = []
  nta = []
  nnta = []
  nnnta = []
  s1 = (d1.month+2)/3
  s2 = (d2.month+2)/3
  if (s2-s1) == 1
     ta[0]=d1
     ta[1]=get_last_day_for_season(d1)
     sa.push ta
     #p sa

     nta[0]=get_first_day_for_season(d2)
     nta[1]=d2
     #p sa
     sa.push nta
     #p sa 

  else
    if (s2-s1) == 2
     ta[0]=d1
     ta[1]=get_last_day_for_season(d1)
     sa[0]=ta

     nta[0]=get_last_day_for_season(d1)+1
     nta[1]=get_first_day_for_season(d2)-1
     sa[1]=nta

     nnta[0]=get_first_day_for_season(d2)
     nnta[1]=d2
     sa[2]=nnta

     #p sa
    else
     ta[0]=d1
     ta[1]=get_last_day_for_season(d1)
     sa[0]=ta

     sa[1]=[]
     sa[1][0]=Date.new(d1.year,4,1)
     sa[1][1]=Date.new(d1.year,6,30)
     #sa[1][0]=ta

      sa[2]=[]
     sa[2][0]=Date.new(d1.year,7,1)
     sa[2][1]=Date.new(d1.year,9,30)

     nta[0]=get_first_day_for_season(d2)
     nta[1]=d2
     sa[3]=nta

     #p sa

    end
  end
  return sa
end

def get_season_pair(year,season)
  case season
  when 1
    ta=[]
    ta[0]=Date.new(year,1,1)
    ta[1]=Date.new(year,3,31)
    return ta
  when 2
     ta=[]
    ta[0]=Date.new(year,4,1)
    ta[1]=Date.new(year,6,30)
    return ta
  when 3
     ta=[]
    ta[0]=Date.new(year,7,1)
    ta[1]=Date.new(year,9,30)
    return ta
  when 4
     ta=[]
    ta[0]=Date.new(year,10,1)
    ta[1]=Date.new(year,12,31)
    return ta
  end

end

#跨年
def make_year_date_list(d1,d2)
  s1 = (d1.month+2)/3
  s2 = (d2.month+2)/3

  sa=[]
  ta=[]
  ta[0]=d1
  ta[1]=get_last_day_for_season(d1)
  sa.push ta

  if s1!=4
    1.upto(4-s1) do |i|
      sa.push get_season_pair(d1.year,s1+i)
    end
  end

  if (d2.year-d1.year) > 1
    1.upto(d2.year-d1.year-1) do |y|
      1.upto(4) do |s|
        sa.push get_season_pair(d1.year+y,s) 
      end
    end
  end

  if s2!=1
    1.upto(s2-1) do |i|
      sa.push get_season_pair(d2.year,i)
    end
  end

  nta=[]
  nta[0]=get_first_day_for_season(d2)
  nta[1]=d2
  sa.push nta

  return sa
  
end


#从新浪获取某个股票一段时间的复权数据
def get_h_data_from_sina(code,start_date,end_date,fq=:qianfuquan)
  d1 = Date.parse(start_date)
  d2 = Date.parse(end_date)
  ra=[]

  qf = get_fuquan_factor_from_sina(code)

  if (d1.year == d2.year) 
    if (((d1.month+2)/3) == ((d2.month+2)/3))  # same year, same seaso
       return get_h_data_from_sina_internal(code,d1,d2,qf)
    else # not same season
     dl= make_date_season_list(d1,d2)
     #p dl
     return dl.inject([]){|r,v| r+get_h_data_from_sina_internal(code,v[0],v[1],qf) }
    end
  else # year is not same
    dl= make_year_date_list(d1,d2)
     #p dl
     return dl.inject([]){|r,v| r+get_h_data_from_sina_internal(code,v[0],v[1],qf) }
  end

end

 def get_history_data_from_sina_ori_fuquan(code,day)

  # uri='http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/600036.phtml?year=2015&jidu=1'
  uri="http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_FuQuanMarketHistory/stockid/#{code.to_s}.phtml?year=#{day.year}&jidu=#{(day.month+2)/3}"
   
    html_response = nil  
    open(uri) do |http|  
      html_response = http.read  
    end  

#    p html_response
    sa= html_response.split('http://vip.stock.finance.sina.com.cn/quotes_service/view/vMS_tradehistory.php?symbol')  

    return sa
 end

 def get_history_data_from_sina(code,day)

  # uri='http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/600036.phtml?year=2015&jidu=1'
  uri="http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/#{code.to_s}.phtml?year=#{day.year}&jidu=#{(day.month+2)/3}"
   
    html_response = nil  
    open(uri) do |http|  
      html_response = http.read  
    end  
    sa= html_response.split('http://vip.stock.finance.sina.com.cn/quotes_service/view/vMS_tradehistory.php?symbol')  

    return sa
 end

  def get_history_data_from_sina_new(code,day)

    #p code
    #p day
  # uri='http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/600036.phtml?year=2015&jidu=1'
     sa = get_history_data_from_sina(code,day)

     #p sa[1]

     len=sa.length
     div_len = sa[1].length
      sa[len-1]=sa[len-1][0..div_len-1]
      sa=sa[1..len]

     sa.each do |line|
       date =line.scan(/[0-9]+\-[0-9]+\-[0-9]+/)
       pa = line.scan(/[0-9]+\.[0-9]+/)
       nbs = line.scan(/[0-9]+/)
       nbs_len = nbs.length
       nbs_len -= 1 if nbs[nbs_len-1] == '2'
       pa.push(nbs[nbs_len-2])
       pa.push(nbs[nbs_len-1])

       #date = Time.new(line[6..9].to_i,line[0..1].to_i,line[3..4].to_i,0,0,0).to_date
       #p "#{date.to_s} #{pa.to_s} #{nbs.to_s}"
     
       return pa.collect {|x| x.to_f} if day.to_s == date[0] 

     end
 end

 def get_history_data_from_sina_fuquan(code,day)

    #p code
    #p day
  # uri='http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/600036.phtml?year=2015&jidu=1'
     sa = get_history_data_from_sina_ori_fuquan(code,day)

     #p sa[1]

     len=sa.length
     #p sa if len==1
     return [] if len==1
     div_len = sa[1].length
      sa[len-1]=sa[len-1][0..div_len-1]
      sa=sa[1..len]

     #p sa.length
     sa.each do |line|
       #p line
       date =line.scan(/[0-9]+\-[0-9]+\-[0-9]+/)
       pa = line.scan(/[0-9]+\.[0-9]+/)
       
       #p "#{date.to_s} #{pa.to_s} "
     
       return pa.collect {|x| x.to_f} if day.to_s == date[0] 

       return [] # no data for this date
     end
 end


def get_day_list_from_file(dir)
  #cl_list=["SH601988.txt","SH601398.txt","SH601328.txt"]
  cl_list = ["SZ399905.txt"]

  i=0
  date_list=[nil,nil,nil]
  cl_list.each do |afile|
    fname = "#{dir}\/#{afile}"

    #p fname
    
    date_list[i]=[]
     File.open(fname,:encoding => 'gbk') do |file|       
        file.each_line do |line|
           t = line[2]
           if t=='/' #non blank line ,has data 
              day_num = Time.new(line[6..9].to_i,line[0..1].to_i,line[3..4].to_i,0,0,0).to_date
              date_list[i].push(day_num)
          end
        end
      end
    i+=1
  end

  return date_list[0]

  dl=[]
  # if (date_list[0].length!= date_list[1].length) or (date_list[1].length!= date_list[2].length)
  #   puts "not same length for 3 code!!!"
  #   return []
  # end


     dl = date_list[0]+date_list[1]+date_list[2]
    return dl.uniq
end


#检查是否发生了状态转换,假设连续5个周期都是向上，如果一个周期出现向下，那么就结束
def is_state_over?(w_list,offset=0,check_value = 1,height=20,func_mode = true)

    check_length = 15
    #w_list = Weekly_records.where(code: "#{code}").order("id asc")
    #
    

    length = w_list.length

    return false,0.0  if length < check_length+1

    # last = w_list[length - 1 - offset]
    # p last
    # check_arr = w_list[(length - 2 - offset - check_length + 1)..(length - 2 - offset)].collect do |rec|
    #   p rec
    # end
    # 
    check_arr = w_list[(length - 2 - offset - check_length )..(length - 1 - offset)].collect {|rec| rec}

    #p check_arr.length
    rate_arr = check_arr.each_with_index.collect do |rec,i|
      if i == 0
        0.0
      else
        price = rec['close'].to_f
        #p price
        old_price = check_arr[i-1]['close'].to_f
        #p old_price
        rate = (price - old_price)/old_price * 100
      end
    end

    return false,0.0  if rate_arr.length == 0 # not enough data

    flag_arr=rate_arr[1..rate_arr.length-1].collect do |v|
       if v <= check_value
        true
       else
        false
       end
    end
    
    len = flag_arr.length
     return false,0.0 if flag_arr[len-1] == flag_arr[len-2]

    #p rate_arr
    #p flag_arr
    flag = flag_arr[len-2]
    sum = rate_arr[len-1]
    flag_arr[0..len-3].reverse.each_with_index do |f,i|
      #p i
       if f == flag 
         sum += rate_arr[len-2-i]    
       else
        break
       end
    end
    
    #p sum
    
         if sum.abs >= height 
           #p "TRUE!!!!!!"
           p "#{w_list[length-1-offset]['date'].to_s} #{format_roe(sum)}" if not func_mode
           return true,sum
         else
          #p "FALSE!!!!!!"
           return false,sum
         end      
     
end

def count_bigger_times(value,list)
   times = 0
    flag = true

    list.reverse.each do |rec|
      if  flag and ( value > rec['close'])
        times += 1
      end

      flag = false if ( value <= rec['close'])
    end

    return times
end

#是否创出新高？ check_value 是连续几周的意思
def is_new_high?(w_list,offset=0,check_value = 5)

    check_length = 26
    #w_list = Weekly_records.where(code: "#{code}").order("id asc")
    #
    

    length = w_list.length

    return false if length < check_length+1

    check_arr = w_list[(length - 2 - offset - check_length )..(length - 1 - offset)].collect {|rec| rec}

    len = check_arr.length

    return false if len < check_value+1

    # last = check_arr[len-1]['close']
    # p_last = check_arr[len-2]['close']

    # return false if last < p_last

   
   times = count_bigger_times(check_arr[len-1]['close'],check_arr[0..len-2])
   p_times = count_bigger_times(check_arr[len-2]['close'],check_arr[0..len-3])
   pp_times = count_bigger_times(check_arr[len-3]['close'],check_arr[0..len-4])
   ppp_times = count_bigger_times(check_arr[len-4]['close'],check_arr[0..len-5])
   

   return true if (times >= check_value) and (p_times <= (check_value-1)) and (pp_times <= (check_value-2)) and (ppp_times <= (check_value-3))

   return false     
     
end

def check_index_state(offset)
   w_list = Weekly_records.where(code: "#{399905}").order("id asc")
   flag,sum =  is_state_over?(w_list,offset,1,20,false)
   if flag
     if sum > 0 
      p "中证500指数上涨过程结束，上涨幅度#{format_roe(sum)}，建议卖出!!!"
     else
      p "中证500指数下跌过程结束，下跌幅度#{format_roe(sum)}，考虑买入!!!"
     end
   end

   w_list = Weekly_records.where(code: "#{159915}").order("id asc")
   flag,sum = is_state_over?(w_list,offset,1,20,false)
   if flag
     if sum > 0 
      p "创业板指数上涨过程结束，上涨幅度#{format_roe(sum)}，建议卖出!!!"
     else
      p "创业板指数下跌过程结束，下跌幅度#{format_roe(sum)}，考虑买入!!!"
     end
   end

   w_list = Weekly_records.where(code: "#{000300}").order("id asc")
   flag,sum = is_state_over?(w_list,offset,1,20,false)
   if flag
      if sum > 0 
      p "沪深300指数上涨过程结束，上涨幅度#{format_roe(sum)}，建议卖出!!!"
     else
      p "沪深300指数下跌过程结束，下跌幅度#{format_roe(sum)}，考虑买入!!!"
     end
   end

end

