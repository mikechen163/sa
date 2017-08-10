$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
 
require "shared_setup"
require 'time'
require 'active_record'
require 'open-uri'
#require 'math'

class Daily_records < ActiveRecord::Base
  def self.table_name() "daily_records" end

  def initialize
    # @date_list=[]

      list1 = self.class.where(code: '600028').collect {|rec| rec['date']}
    list2 = self.class.where(code: '601857').collect {|rec| rec['date']}
    list3 = self.class.where(code: '600036').collect {|rec| rec['date']}

    
    # # list1.each_with_index do |rec,i|
    # #   d1=list1[i]['date']
    # #   d2=list2[i]['date']
    # #   d3=list3[i]['date']

    # #   day = d1 if (d1==d2) 
    # #   day = d1 if (d1==d3)
    # #   day = d2 if (d2==d3)  
    # #   @date_list.push(day)
    # # end

     @date_list=(list1+list2+list3).uniq.sort

    #@date_list = self.class.where(code: '399905').collect {|rec| rec['date']}

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
    list1 = self.class.where(code: '600028').collect {|rec| rec['date']}
    list2 = self.class.where(code: '601857').collect {|rec| rec['date']}
    list3 = self.class.where(code: '600036').collect {|rec| rec['date']}
    
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

    @date_list=(list1+list2+list3).uniq.sort
    
    #@date_list = self.class.where(code: '399905').collect {|rec| rec['date']}


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
    return 0.0    
   
  end

   def self.get_stock_total_number(code)
    rec = self.where( code: "#{code}").first
    return rec['total_stock_number'] if rec
    return 0.0
   
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

  def normalize_name(s,def_len)

  ind = 0
  real_len = 0
  while ind < s.size
    if s[ind].bytesize == 3
      real_len += 2
    else 
      if s[ind].bytesize == 1
        real_len += 1
      end
    end


    return s[0..ind] if real_len >= def_len
    ind += 1

  end

  return s + ' '*(def_len - real_len)
            

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

def format_price(price,number_of_space = 3)

  price = price.round(2)
  s=price.to_s
  ind=s.index('.')

  i=number_of_space
  nc = 10
  while i > 1 
    nsp = ' '*(i-1)
 
    return nsp+s+'0' if (price<nc) and ((s.length-2) == ind)
    return nsp+price.to_s if (price<nc) 
    
    i = i-1
    nc = nc * 10
  end
  #return ' '+price.to_s+'0' if (price<10) and ((price*100).floor%10 == 0)
  # return '  '+s+'0' if (price<10) and ((s.length-2) == ind)
  # return '  '+price.to_s if (price<10) 
  # #return price.to_s+'0' if (((price*100).floor)%10 == 0)
  # #return s+'0' if (s.length-2) == ind
  # return ' '+s+'0' if (price<100) and ((s.length-2) == ind)
  # return ' '+price.to_s if (price<100) 
  return s+'0' if  ((s.length-2) == ind)
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

def append_index_to_codefile(codefile,index_code)

  counter = 1
  File.open(codefile, "r+") do |file|
         
             file.each_line do |line|
                #puts "#{line}"
                #lineno += 1
                return  if line.index(index_code) != nil
    
                na = line.index ('|')
                counter = (line[0..(na - 1 )]).to_i
                #puts counter
             end

        
          file.seek(0, IO::SEEK_END)

          str = ""
          case index_code
            when '000300'
              str = "#{counter + 1}|000300|沪深300 |SH"
             when '399905'
              str = "#{counter + 1}|399905|中证500 |SZ"
             when '159919'
              str = "#{counter + 1}|159919|300 ETF |SZ"
             when '159915'
              str = "#{counter + 1}|159915|创业板  |SZ"
          end
          file.puts str
  end
end

# def get_last_stock_number(dir)
#    na = Dir.glob("#{dir}\/*.txt").sort.collect {|x| x[(dir.length + 3)..(x.length - 5)]}
#    #na.each {|x| puts x}
#    t1 = na.select {|x| x[0..2] == '603'}
#    t2 = na.select {|x| x[0..2] == '002'}
#    t3 = na.select {|x| x[0..2] == '300'}
#    puts t1.sort.reverse[0]
#    puts t2.sort.reverse[0]
#    puts t3.sort.reverse[0]
# end
# 
def is_new_stock_number?(code)
  case code[0]
    when '6'
     return true if code.to_i > 601000
    when '0'
      return true if code.to_i > 1000
    when '3'
      return true if code.to_i > 300000
    else
      return false
  end

  return false
end

def load_name_into_database(fname = "name.txt")

  name_list = []
  
  File.open(fname).each_line do |line|

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


 def get_main_index_from_ntes(code,type=:year)
  if (type == :year)
    uri="http://quotes.money.163.com/f10/zycwzb_#{code},year.html"
  else
    if  (type == :season)
      uri="http://quotes.money.163.com/f10/zycwzb_#{code},season.html"
    else
      uri="http://quotes.money.163.com/f10/zycwzb_#{code},report.html"
    end
  end

  return get_finance_info_from_ntes(uri) 
 end

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

def fetch_all_stock_for_attr(att)

    #no response for these code
    return [] if att[5..7] == '638'
    return [] if att[5..7] == '500'
    return [] if att[5..7] == '568'
    return [] if att[5..7] == '681'
    return [] if att[5..7] == '701'
   
    res = []
    page = 1
    pagesize = 100
    ta = Array.new(pagesize)

    while ta.size == pagesize

       uri = "http://nufm.dfcfw.com/EM_Finance2014NumericApplication/JS.aspx?type=CT&cmd=C.BK0#{att[5..7]}1&sty=FCOIATA&sortType=C&sortRule=-1&page=#{page}&pageSize=#{pagesize}&js=var%20quote_123%3d{rank:[(x)],pages:(pc)}&token=7bc05d0d4c3c22ef9fca8c2a912d779c&jsName=quote_123&_g=0.7844546340215461"



      html_response = nil  
      open(uri) do |http|  
        html_response = http.read  
      end  
    
      #puts html_response
      ta = []
      sa=html_response.split('"')

      return res if sa.length == 1

      sa.each do |line|
        c = line[0]
        if (line.size > 1) and (c >= '0') and (c <= '9')
          ta.push line[2..7]
        end
      end 

     
      page += 1
      res = res + ta
    end #while

    return res
end

require 'net/http'
def fetch_quoto_from_nasdaq(code,length)

  uri = URI("http://www.nasdaq.com/symbol/#{code.downcase}/historical")
  res = Net::HTTP.start(uri.host, 80) do |http|
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    # The body needs to be a JSON string, use whatever you know to parse Hash to JSON
    req.body = "#{length}|false|#{code.upcase}"
    http.request(req)
  end

  #puts res.body

  sa=res.body.split('Results for')[1].split('<tbody>')[1]
  #sa = sa.scan(/<tr.*>(.*)<\/tr>/)
   nsa = sa.scan(/[0-9:,\/]+\.*[0-9:,\/]+/)
    
  return nsa
end

def fetch_all_hy(file)
  uri="http://quote.ql.com/center/BKList.html#trade_0_0?sortRule=0"
   
    html_response = nil  
    open(uri) do |http|  
      html_response = http.read  
    end  
  
    sa=html_response.split('list.html')

    sa.each do |item|
      ind = item.index('/span')
      if (ind != nil) and (ind < 50)
        item = item[1..(ind - 2)].encode('utf-8','gbk') 

        ind = item.index('text')
        att = item[(ind+6)..(item.length - 1)]

        ind = item.index('"')
        link = item[0..(ind - 1)]

        puts "#{normalize_name(link,18)} #{att}"

        if (link[0..4] == '28001') or (link[0..4] == '28002') or (link[0..4] == '28003')
             stock_list =  fetch_all_stock_for_attr(link)
             file.puts "#{att}, #{stock_list.to_s}"
        end
      end
    end

    return 0
end

def fetch_all_code_list(file,mode=:std)
    uri="http://quote.eastmoney.com/stocklist.html"
   
    html_response = nil  
    open(uri) do |http|  
      html_response = http.read  
    end  
  
    sa=html_response.split('quote.eastmoney.com')
    
    start = 1 
    sa.each  do |x|
      code =  x[1..8]
      ind = x.index('<')
      name = x[16..(ind-1)].encode('utf-8','gbk')
      name = name[0..(name.length-9)]
      name = normalize_name(name,8)
      market = code[0..1].upcase
      if (market == 'SH') 
        case mode
        when :agu
          if (code[2] == '6')
            file.puts "#{start}|#{code[2..7]}|#{name}|#{market}"
            start += 1
          end
        when :bgu
          if (code[2] == '9')
            file.puts "#{start}|#{code[2..7]}|#{name}|#{market}"
            start += 1
          end
        when :etf
          if (code[2] == '5')
            file.puts "#{start}|#{code[2..7]}|#{name}|#{market}"
            start += 1
          end
        when :all
          file.puts "#{start}|#{code[2..7]}|#{name}|#{market}"
          start += 1
        else
          puts "unknown mode #{mode}"
        end
        
      end

      if (market == 'SZ') 
       case mode
        when :agu
          if (code[2] == '0') or (code[2] == '3')
            file.puts "#{start}|#{code[2..7]}|#{name}|#{market}"
            start += 1
          end
        when :bgu
          if (code[2] == '2')
            file.puts "#{start}|#{code[2..7]}|#{name}|#{market}"
            start += 1
          end

         when :cyb
          if  (code[2] == '3')
            file.puts "#{start}|#{code[2..7]}|#{name}|#{market}"
            start += 1
          end
        when :etf
          if (code[2..3] == '15') or (code[2..3] == '16')
            file.puts "#{start}|#{code[2..7]}|#{name}|#{market}"
            start += 1
          end
        when :all
          file.puts "#{start}|#{code[2..7]}|#{name}|#{market}"
          start += 1
        else
          puts "unknown mode #{mode}"
        end
      end

    end
     
    puts "Total #{start - 1} items. "

    
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

    #name = name + " " if name.length == 3
    #name = name + " " if name.length == 5

    name = normalize_name(name,8)
   
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
      
      #puts sa.length
    
      #支持返回结果中有多个表
      sa[2..(sa.length-1)].each do |xa|
        #puts sa
        sl = xa.length
        year_list = xa.scan(/[0-9]+\-[0-9]+\-[0-9]+/)
        nyl=[]
        nyl.push('报告日期')
        year_list.each {|x| nyl.push x}
        r.push(nyl)

        len = year_list.length
        index = xa.index(year_list[len-1]) + 10
        index_end = xa[index..(sl-1)].index('table')

        ll = xa[index..(index+index_end)].split('</tr>')

        ll.each_with_index do |line,i|
          #puts "#{i} : #{line}"
          tal=line.scan(/<td class="td_1">(.*)<\/td>/)

          al=""
          nal=[]
         
          if tal.length !=0 
            nal.push tal[0][0].to_s if tal.length !=0 
            ind = line.index("td_1")
            al=line[(ind+4)..(line.length-1)].scan(/[0-9\-][0-9.,\-]*/)
          else
            nal.push(thl[i-1])
            al=line.scan(/[0-9\-][0-9.,\-]*/)
          end

          al.each {|x| nal.push x}

          if al.length !=0
            r.push(nal)
            #print "#{i}:#{thl[i-1]}"
            #al.each {|x| print "#{x} "}
            #puts
          end

        end
      end
    return r
 end #func


 # def get_finance_info_from_ntes(url)
   
 #   r=[]
   
 #    html_response = nil  
 #    open(url) do |http|  
 #      html_response = http.read  
 #    end  
    
 #    sa=html_response.split('table_bg001')

 #     thl = []

 #      sa[1].split('</tr>').each do |line|
 #        #puts line
 #        al=line.scan(/<td.*>(.*)<\/td>/)
 #        al2=line.scan(/<strong>(.*)<\/strong>/)
        
      
 #        if al2.length !=0 
 #          thl.push al2[0][0].to_s if al2.length !=0 
 #        else
 #          thl.push al[0][0].to_s if al.length !=0
 #        end

 #      end

 #      # puts thl
 #      # thl.each_with_index do |e,i|
 #      #   puts "#{i}:#{e}:#{e.length}"
 #      # end
    
 #      sl = sa[2].length
 #      year_list = sa[2].scan(/[0-9]+\-[0-9]+\-[0-9]+/)

 #      nyl=[]
 #      nyl.push('报告日期')
 #      year_list.each {|x| nyl.push x}
 #      r.push(nyl)

 #      len = year_list.length
 #      index = sa[2].index(year_list[len-1]) + 10
 #      index_end = sa[2][index..(sl-1)].index('table')

 #      ll = sa[2][index..(index+index_end)].split('</tr>')

 #      ll.each_with_index do |line,i|
 #        #puts "#{i} : #{line}"
 #        al=line.scan(/[0-9\-][0-9.,\-]*/)
 #        nal=[]
 #        nal.push(thl[i-1])
 #        al.each {|x| nal.push x}

 #        if al.length !=0
 #          r.push(nal)
 #          #print "#{i}:#{thl[i-1]}"
 #          #al.each {|x| print "#{x} "}
 #          #puts
 #        end

 #      end
 #    return r
 # end #func

#港股的股本数据
def get_stockinfo_data_from_sina(code)
   
   
  uri="http://stock.finance.sina.com.cn/hkstock/info/#{code}.html"
  # uri="http://stock.finance.sina.com.cn/hkstock/info/00700.html"
   
    html_response = nil  
    open(uri) do |http|  
      html_response = http.read  
    end  
    title = html_response.scan(/<title>(.*)<\/title>/)
    return "",0.0 if title[0] == nil
    title = title[0][0].encode('utf-8','gbk')
    #puts title
    # ind = title[0][0].split(code.to_s)
    # #puts ind[0].length
    ind = title.index('0')
    name = title[0..(ind-2)]
    #puts name
    # #puts name.length

    # name = name + " " if name.length == 3
    # name = name + " " if name.length == 5
   
    # sa=html_response.split('table_bg001')
     sa = html_response.scan(/<td>(.*)<\/td>/)
     sa.each do |item|
      ns = item[0].encode('utf-8','gbk')
       ind =  ns.index("(股)")
       return  name,ns[0..(ind-1)].to_i if ind != nil
     end
    
    #   al = sa[2].scan(/[0-9]+\.[0-9]+/)
    #   #al.each_with_index {|c,i| puts "#{i} : #{c}"}

    #   return name,al.collect{|x| x.to_f} 
    
    return "" , 0.0
    
 end


 def get_history_data_from_nasdaq(code)
   uri="http://www.nasdaq.com/symbol/#{code}/historical"
   
    html_response = nil  
    open(uri) do |http|  
      html_response = http.read  
    end  

    p html_response
 end


  def get_list_data_from_sina(codelist,etf_flag=false)

  sl = ""

  codelist.each do |code|

    pref = ""
    pref = "sh" if (code[0]=='6') 
    pref = "sz" if (code[0]=='0') || (code[0]=='3')    

    #hk02208  gb_bidu
    pref = "" if (code[0]=='h') or (code[0]=='g') or (code[0]=='s') or (code[0]=='i') 


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
        next if  sa.length < 2
    
        #ta=[ sa[0][2..7], sa[1].to_f,sa[4].to_f,sa[3].to_f,sa[5].to_f,sa[8].to_i,sa[9].to_f]
        h= Hash.new
        ts = sa[0].split('=')
        #p ts
        
        if ts[0][0] == 's'
          h[:code] = sa[0][2..7]
        else
          h[:code] = ts[0]
        end

        nz = ts[1].encode('utf-8','gbk')
        nzlen = nz.length
        nz = nz[1..nzlen-1]
        h[:name] =  nz

        #p ts[0]
        
        case ts[0][0..2]
          when 'EUR' , 'DIN','USD','JPY','CNY','GPB','AUD','CAD'
               len = sa.length
               #p 
               ts = sa[len-2].encode('utf-8','gbk')
            
               h[:name] = ts
               h[:name] =  normalize_name(h[:name],14)
             

               h[:close] = sa[1].to_f
               h[:ratio] = (sa[1].to_f - sa[3].to_f) / sa[3].to_f
        end

        case ts[0][0]
       
          when 'i' , 'b'
            #p h[:name] 
            tl = ts[0].length
            h[:code] = ts[0][4..tl-1]
            h[:close] = sa[1].to_f 
            h[:change_value] = sa[2].to_f 
            h[:ratio] = sa[3].to_f 

      
            h[:name] =  normalize_name(h[:name],14)

          when 's' # sh or sz
          
             h[:name] = normalize_name(h[:name],8)


            h[:open] = sa[1].to_f
            h[:last_close] = sa[2].to_f
            h[:high] = sa[4].to_f
            h[:close] = sa[3].to_f 
            h[:low]   = sa[5].to_f
            h[:volume] = sa[8].to_f
            h[:amount] = (sa[9].to_i/100).to_f/100

             free_number = Stock_Basic_Info.get_stock_free_number(h[:code])
             free_number = 0.0 if free_number == nil
             h[:total_mv] = (h[:close]*free_number*100).to_i/100.0

             if free_number > 0.0
               h[:trade_ratio] = ((h[:volume]/(free_number*10000))).to_i/100.0
             else
                h[:trade_ratio] = 0.0
             end
            h[:ratio] = 0.0
            h[:ratio] = (h[:close]-h[:last_close])/h[:last_close]*100 if h[:last_close] >0
            h[:ratio] = h[:ratio].round(2)
            h[:date] = sa[sa.length-3]
            h[:time] = sa[sa.length-2]


          when 'g' #gb_ us

            tl = ts[0].length
            len = h[:name].length
            #if etf_flag
                #puts h[:name]
            #else
             default_len = 14 
             default_len = 30 if etf_flag

            h[:name] = normalize_name(h[:name],default_len)
           
            h[:close] = sa[1].to_f 
            h[:ratio] = sa[2].to_f
            h[:change_value] = sa[4].to_f
            h[:last_close] = sa[5].to_f
            h[:high] = sa[6].to_f
            h[:low] = sa[7].to_f
            h[:week52_high] = sa[8].to_f
            h[:week52_low] = sa[9].to_f

            h[:volume] = sa[10].to_f
            next if  (h[:volume] == 0.0) and (not etf_flag)
            h[:amount] =  h[:volume] * h[:close]
            h[:volume_10days] = sa[11].to_f
            h[:total_mv] = sa[12].to_f
            h[:total_stock_number] = sa[19].to_f

            h[:total_mv] =h[:total_stock_number] *  h[:close] 
            next if  (h[:total_mv] < 100000000) and (not etf_flag)

            h[:eps] = sa[13].to_f
            h[:pe] = sa[14].to_f
            h[:beta] = sa[16].to_f
            h[:total_stock_number] = sa[19].to_f

            h[:trade_ratio] = 0.0
            if h[:total_stock_number] > 0.0
              h[:trade_ratio] = ((h[:volume]/h[:total_stock_number])*10000).to_i/100.0
            end

            h[:date] = Time.parse(sa[sa.length-3]).to_date.to_s
            h[:time] = Time.parse(sa[sa.length-3]).strftime("%H:%M:%S")
            #next if h[:trade_ratio] = 0.0
           
          when 'h' #hk

            if ts[0][1] == 'k'

              next if  sa[6].to_f < 1
              #p sa
              h[:name] = sa[1].encode('utf-8','gbk')

            
              h[:name] = normalize_name(h[:name],12)



              tl = ts[0].length
              #h[:code] = ts[0][2..tl-1]

              h[:open] = sa[2].to_f
              h[:last_close] = sa[3].to_f
              h[:high] = sa[4].to_f 
              h[:low]   = sa[5].to_f
              h[:close] = sa[6].to_f 
              h[:change_value] = sa[7].to_f
              h[:ratio] = sa[8].to_f
              h[:buy1] = sa[9].to_f
              h[:sell1] = sa[10].to_f
              h[:amount] = sa[11].to_f
              h[:volume] = sa[12].to_f
              h[:pe] = sa[13].to_f
              h[:week_interest_ratio] = sa[14].to_f
              h[:week52_high] = sa[15].to_f
              h[:week52_low] = sa[16].to_f
              # h[:date] = sa[17]
              # h[:time] = sa[18]

              #h[:trade_ratio] = 0.0
              free_number = Stock_Basic_Info.get_stock_free_number(h[:code][2..6])
               free_number = 0.0 if free_number == nil
               h[:total_mv] = (h[:close]*free_number/1000000).to_i/100.0

               if free_number > 0.0
                 h[:trade_ratio] = ((h[:volume]/free_number)*10000).to_i/100.0
               else
                  h[:trade_ratio] = 0.0
               end

                h[:date] = Time.parse(sa[17]).to_date.to_s
              h[:time] = sa[18][0..4]

               next if  h[:total_mv] < 10
           else
             if ts[0][1] == 'f'
               #p sa.to_s
               len = sa.length
               #p 
               ts = sa[len-1].encode('utf-8','gbk')
               ind = ts.index('"')
               h[:name] = ts[0..(ind-1)]
               h[:name] =  normalize_name(h[:name],14)
               ind = sa[0].index('"')

               h[:close] = sa[0][(ind+1)..(sa[0].length-1)].to_f
               h[:ratio] = sa[1].to_f
               #p h[:name]
             end

           end

          else
            #puts "unknown code = #{ts[0]}"
        end

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

def get_all_stock_price_from_sina(cl,etf_flag=false)
   
  batch_num = 300
  #cl = Names.get_code_list
  len = cl.length
  step = 0
  all = []

  while (step < len)
     a_end = step+batch_num-1
     a_end = len-1 if a_end > len 
     tl = get_list_data_from_sina(cl[step..a_end],etf_flag)
     all += tl
     step += batch_num
  end
  
  return all
end

def get_topN_from_sina(topN,sortby,given_ratio=3,market=:china,file = nil)

  t1= Time.now

  case market 
    when :china
      #all = get_all_stock_price_from_sina(Names.get_code_list)
       cl = []
       File.open('name.txt') do |file|
            file.each_line do |line|
              na = line.split('|')
              code = na[1].strip
              cl.push(code) 
            end
       end
       puts "total #{cl.length} stocks"
       t1= Time.now
       all = get_all_stock_price_from_sina(cl)
    when :hk
       cl = []
       File.open('hk_name.txt') do |file|
            file.each_line do |line|
              na = line.split('|')
              code = "hk"+na[1].strip
              cl.push(code) 
            end
       end
       puts "total #{cl.length} stocks"
       t1= Time.now
       all = get_all_stock_price_from_sina(cl)
    when :us
       cl = []
       File.open('us_name.txt') do |file|
            file.each_line do |line|
              na = line.split(',')
              code = "gb_"+na[0].strip.downcase
              cl.push(code) 
            end
       end
       puts "total #{cl.length} stocks"
       t1= Time.now
       all = get_all_stock_price_from_sina(cl)
       #all.each {|x| puts x.to_s;puts}
     when :us_etf
       cl = []
       File.open('us_etf.txt') do |file|
            file.each_line do |line|
              na = line.split(',')
              code = "gb_"+na[0].strip.downcase
              cl.push(code) 
            end
       end
       puts "total #{cl.length} stocks"
       t1= Time.now
       all = get_all_stock_price_from_sina(cl,true)
       #all.each {|x| puts x.to_s;puts}
    else
      puts "unknown market #{market.to_s}"
  end

  t2 = Time.now
  
  puts "fetching all data from sina takes #{t2-t1} seconds."
  
  
  #p all.length
  case sortby
    
    when 0
       all.sort_by!{|h| h[:amount]}
       all.reverse!
    when 1
        all.delete_if {|h| h[:volume] == 0.0}
       all.sort_by!{|h| h[:amount]}
    when 2
       all.sort_by!{|h| h[:volume]}
       all.reverse!
    when 3
      all.delete_if {|h| h[:volume] == 0.0}
       all.sort_by!{|h| h[:volume]}
    when 4
       all.sort_by!{|h| h[:trade_ratio]}
       all.reverse!
    when 5
      all.delete_if {|h| h[:volume] == 0.0}
      all.sort_by!{|h| h[:trade_ratio]}
    when 6
       all.sort_by!{|h| h[:ratio]}
       all.reverse!
    when 7
        all.delete_if {|h| h[:volume] == 0.0}
       all.sort_by!{|h| h[:ratio]}
    when 8
       all.sort_by!{|h| h[:total_mv]}
       all.reverse!
    when 9
      all.delete_if {|h| h[:volume] == 0.0}
      all.sort_by!{|h| h[:total_mv]}

    # when 4
    #    all.sort_by!{|h| h[:code]}
    #    #all.reverse!
    
    when 99
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

   when 13
       all.delete_if {|h| h[:ratio] < given_ratio}
       all.delete_if {|h| h[:volume] == 0.0}
       all.sort_by!{|h| h[:trade_ratio]}
       
    when 14
       all.delete_if {|h| h[:ratio] > -given_ratio}
       all.delete_if {|h| h[:volume] == 0.0}
       all.sort_by!{|h| h[:total_mv]}
       all.reverse!

    when 15
       all.delete_if {|h| h[:volume] == 0.0}
       all.sort_by!{|h| h[:amount]}
       all.reverse!
       all.delete_if{|h| h[:ratio] > - given_ratio }



     when 16
       all.sort_by!{|h| h[:amount]}
       all.reverse!
       all.delete_if{|h| h[:ratio] < given_ratio}

     when 17
       all.delete_if {|h| h[:ratio] < given_ratio}
       all.delete_if {|h| h[:volume] == 0.0}
       all.sort_by!{|h| h[:total_mv]}
       all.reverse!

    when 18
       all.delete_if {|h| h[:ratio] < given_ratio}
       all.delete_if {|h| h[:volume] == 0.0}
       all.sort_by!{|h| h[:total_mv]}

    when 19
      all.delete_if {|h| h[:ratio] < given_ratio}
       all.sort_by!{|h| h[:trade_ratio]}
       all.reverse!
      
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

  topN = all.length - 1 if (all.length - 1)  < topN 

  #return if all.length == 0
  #puts "OK"

  if file != nil
      #puts "OK"
    
    begin
       # #file.rewind
       line = file.readline
       #puts line
       sa = line.split(',')
       ind = sa.index('date')  
       # line = file.readline
       # sa = line.split(',')
       # date = sa[ind]
       # 
       file.seek(-200, IO::SEEK_END)
       
       last_line = nil

       file.each_line do |line|
             last_line = line
             #puts line
       end

       #puts last_line
       sa = last_line.split(',')
       date = sa[ind]

       #puts date
       #puts all[0][:date]
       if date == all[0][:date]
         puts "data already fetched for #{date}."
         return
       end

        file.seek(0, IO::SEEK_END)
    rescue
      #file.puts
      all[0].keys.each { |key| file.print "#{key},"}
      file.puts
    end
    

    all.each do |h|
      #file.puts
      name = h.values[0]
      len = h.values.length 
      case name[0]
        when 'g'
          name = name[3..(name.length - 1 )].upcase
        when 'h'  
        else
          name = 'sh' + name if name[0] == '6'
          name = 'sz' + name if (name[0] == '0') or (name[0] == '3')
      end
      file.print "#{name}"
      h.values[1..(len-1)].each {|v| file.print ",#{v}"} 
      file.puts
    end
    return 
  end

  #puts "#{Time.now.strftime("%y-%m-%d %H:%M:%S")}"
  case market 
    when :china
      all[0..topN].each do |h|
         
          cje = "#{((h[:amount]/100).to_i/100.0)}亿元"
         if (h[:amount] < 10000)
           cje = "#{((h[:amount]).to_i)}万元"
         end

         puts "#{h[:name]}(#{h[:code]}) #{format_price(h[:close])}, 涨幅=#{format_roe(h[:ratio])},换手率=#{format_roe(h[:trade_ratio])}, 成交量=#{format_big_num(h[:volume].to_i/100)}手, 成交额=#{cje} 流通市值=#{format_price(h[:total_mv])}亿 " 
      end
    when :hk
      all[0..topN].each do |h|
  
         cje = "#{((h[:amount]/100.0).to_i/100.0)}万元"
         if (h[:amount] > 100000000)
           cje = "#{((h[:amount]/1000000.0).to_i/100.0)}亿元"
         end
         puts "#{h[:name]}[#{h[:code][2..6]}] #{format_price(h[:close])}, 涨幅=#{format_roe(h[:ratio])}, 换手率=#{format_roe(h[:trade_ratio])}, 成交量=#{((h[:volume]/100.0).to_i/100.0)}万股, 成交额=#{cje}, 市值=#{format_price(h[:total_mv])}亿 " 
      end

    when :us 
        all[0..topN].each do |h|

          cje = "#{((h[:amount]/100.0).to_i/100.0)}万元"
         if (h[:amount] > 100000000)
           cje = "#{((h[:amount]/1000000.0).to_i/100.0)}亿元"
         end 
       
         code = h[:code][3..(h[:code].length-1)].upcase
         code = code + ' '*(5-code.size)
         puts "#{h[:name]}[#{code}] #{format_price(h[:close])}, 涨幅=#{format_roe(h[:ratio])} ,换手率=#{format_roe(h[:trade_ratio])}, 成交量=#{format_big_num(h[:volume].to_i)}股, 成交额=#{cje} 市值=#{format_price(h[:total_mv]/100000000)}亿 " 
      end

       when :us_etf 
        all[0..topN].each do |h|

          cje = "#{((h[:amount]/100.0).to_i/100.0)}万元"
         if (h[:amount] > 100000000)
           cje = "#{((h[:amount]/1000000.0).to_i/100.0)}亿元"
         end 
       
         code = h[:code][3..(h[:code].length-1)].upcase
         code = code + ' '*(4-code.size)
         puts "#{h[:name]}[#{code}] #{format_price(h[:close])}, 涨幅=#{format_roe(h[:ratio])} ,换手率=#{format_roe(h[:trade_ratio])}, 成交量=#{format_big_num(h[:volume].to_i)}股, 成交额=#{cje}" 
      end

    else
      puts "unknown market #{market.to_s}"
  end

  ave_ratio = 0.0 
  if all.length > 0 
    ave_ratio = (all[0..topN].collect{|h| h[:ratio]}.inject(:+)/topN*100).to_i/100.0
  end
  puts "总共#{topN}支股票 平均涨幅 = #{ave_ratio}% on #{Time.now.strftime("%y-%m-%d %H:%M:%S")}"


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
     

        return [] if sa == nil

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

  
    if $proxy == nil
      open(uri) do |http|  
        html_response = http.read  
      end  
    else
      open(uri, proxy: $proxy) do |http|  
        html_response = http.read  
      end
    end

#    p html_response
    sa= html_response.split('http://vip.stock.finance.sina.com.cn/quotes_service/view/vMS_tradehistory.php?symbol')  

    return sa
 end

 def get_history_data_from_sina(code,day)

  # uri='http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/600036.phtml?year=2015&jidu=1'
  uri="http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/#{code.to_s}.phtml?year=#{day.year}&jidu=#{(day.month+2)/3}"
   
    html_response = nil  

     if $proxy == nil
      open(uri) do |http|  
       
        html_response = http.read  
       
      end  
    else
      open(uri, proxy: $proxy) do |http|  
        html_response = http.read  
      end
    end
    
   
    sa= html_response.split('http://vip.stock.finance.sina.com.cn/quotes_service/view/vMS_tradehistory.php?symbol') 
  
    #puts sa.length
 
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

