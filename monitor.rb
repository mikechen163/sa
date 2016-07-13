$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
 
require "shared_setup"
require 'common'
require "open-uri"  
require 'time'
    #如果有GET请求参数直接写在URI地址中  
    #uri = 'http://hq.sinajs.cn/list=sh601006'
    #uri='http://vip.stock.finance.sina.com.cn/quotes_service/view/vMS_tradehistory.php?symbol=sh601872&date=2015-03-16'
    # uri='http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/600036.phtml?year=2015&jidu=1'
    # html_response = nil  
    # open(uri) do |http|  
    #   html_response = http.read  
    # end  
    # puts html_response  
 # def get_price_from_sina(code)
 # 	pref = "sh"
 #    pref = "sz" if (code[0]!='6') 	
   
 # 	uri="http://hq.sinajs.cn/list=#{pref+code}"
   
 #    html_response = nil  
 #    open(uri) do |http|  
 #      html_response = http.read  
 #    end  
 #    #sa= html_response.split('http://vip.stock.finance.sina.com.cn/quotes_service/view/vMS_tradehistory.php?symbol')  

 #    #return sa
 #    sa=html_response.scan(/[0-9]+\.[0-9]+/)

 #    return sa[0].to_f,sa[3].to_f,sa[2].to_f,sa[4].to_f
 # end

 #  def get_trade_data_from_sina(code)
 # 	pref = "sh"
 #    pref = "sz" if (code[0]!='6') 	
   
 # 	uri="http://hq.sinajs.cn/list=#{pref+code}"
   
 #    html_response = nil  
 #    open(uri) do |http|  
 #      html_response = http.read  
 #    end  
 #    #sa= html_response.split('http://vip.stock.finance.sina.com.cn/quotes_service/view/vMS_tradehistory.php?symbol')  

 #    #return sa

 #    # sa=html_response.scan(/[0-9]\,/)
 #    # p sa
 #    # sa=html_response.scan(/[0-9]+\.[0-9]+/)
 #    # p html_response.index(sa[6])
 #    # index = html_response.index(sa[6])+sa[6].length
 #    # p index
 #    sa=html_response.split(',')
    
 #    return sa[1].to_f,sa[4].to_f,sa[3].to_f,sa[5].to_f,sa[8].to_i,sa[9].to_f
 # end

 # def get_history_data_from_sina(code,day)

 # 	# uri='http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/600036.phtml?year=2015&jidu=1'
 # 	uri="http://vip.stock.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/#{code.to_s}.phtml?year=#{day.year}&jidu=#{day.month/3}"
   
 #    html_response = nil  
 #    open(uri) do |http|  
 #      html_response = http.read  
 #    end  
 #    sa= html_response.split('http://vip.stock.finance.sina.com.cn/quotes_service/view/vMS_tradehistory.php?symbol')  

 #    return sa
 # end

#  def previous_work_day(day)
# # 	puts "sss"
#  	#p day
#  	pd = day - 1

#  #	p pd
#  	pd = pd - 1 if pd.sunday?
#  	pd = pd - 1 if pd.saturday?

#  	return pd
#  end

 def get_price_for_day(code,d1,d2,d3)
 	sa=get_history_data_from_sina(code,d1)
   len=sa.length
   div_len = sa[1].length
   sa[len-1]=sa[len-1][0..div_len-1]
   sa=sa[1..len]

   p1=p2=p3=0.0
   sa.each do |line|
   	 date =line.scan(/[0-9]+\-[0-9]+\-[0-9]+/)
   	 pa = line.scan(/[0-9]+\.[0-9]+/)

   	 #date = Time.new(line[6..9].to_i,line[0..1].to_i,line[3..4].to_i,0,0,0).to_date
   	 
   	 p1=pa[2].to_f if d1.to_s == date[0] 
     p2=pa[2].to_f if d2.to_s == date[0]  
     p3=pa[2].to_f if d3.to_s == date[0]   
   end
  
  #p2,p3 not in the same season as p1
  if p2==0.0

  	sa=get_history_data_from_sina(code,d2)
   len=sa.length
   div_len = sa[1].length
   sa[len-1]=sa[len-1][0..div_len-1]
   sa=sa[1..len]

   
   sa.each do |line|
   	 date =line.scan(/[0-9]+\-[0-9]+\-[0-9]+/)
   	 pa = line.scan(/[0-9]+\.[0-9]+/)
   	 
     p2=pa[2].to_f if d2.to_s == date[0]  
     p3=pa[2].to_f if d3.to_s == date[0]   
   end

  end

   #p1,p2 in same season,p3 in last season
   if p3==0.0

  	sa=get_history_data_from_sina(code,d3)
   len=sa.length
   div_len = sa[1].length
   sa[len-1]=sa[len-1][0..div_len-1]
   sa=sa[1..len]

   
   sa.each do |line|
   	 date =line.scan(/[0-9]+\-[0-9]+\-[0-9]+/)
   	 pa = line.scan(/[0-9]+\.[0-9]+/)
   	 
     p3=pa[2].to_f if d3.to_s == date[0]   
   end

  end

  return p1,p2,p3
 end

 def monitor_run
  #  day=Time.now.to_date
  #  return if day.sunday?
  #  return if day.saturday?

  # # p day
  #  d1=previous_work_day(day)
  #  d2=previous_work_day(d1)  
  #  d3=previous_work_day(d2)

  #  #p1,p2,p3=get_price_for_day('000651',d1,d2,d3)

  #  #p d1,d2,d3

  #  #p p1,p2,p3
  #  sa=[]
  #  i = 0
  # Names.get_code_list.each do |code|
  # 	puts "getting #{code} data from sina..."
  #   #p1,p2,p3=get_price_for_day(code,d1,d2,d3)

  #   #if (p1<p2) and (p1<p3)
  #    open,high,close,low=get_price_from_sina(code)
  #    #roe = (close-p1)/p1*100
  #    #roe +=50 if roe<=1

  #    h=Hash.new
  #    h[:price]=close
  #    #h[:roe]=roe
  #    h[:time] = Time.now
  #    sa.push(h)

  #   #end
  #   #break;
  #   # i += 1
  #   # if (i>=25)
  #   #   puts "wait 10 seconds"
  #   #   sleep(10)
  #   #   i = 0
  #   # end

  # end

  #   sa.sort_by{|h| h[:roe]}
  #   sa.each {|h| p h}


  

   day=Time.now.to_date
   return if day.sunday?
   return if day.saturday?


   #day=previous_work_day(day)

  # p day
   d1=previous_work_day(day)
   d2=previous_work_day(d1)  
   d3=previous_work_day(d2)

  #min_list = Daily_minlist_records.get_min_list_for_day(d1,2)
 
  w_list1 = Lastest_records.find(:all, :conditions=>" date = date(\'#{d1.to_s}\')", :order=>"id asc")
  w_list2 = Lastest_records.find(:all, :conditions=>" date = date(\'#{d2.to_s}\')", :order=>"id asc")
  #w_list3 = Lastest_records.find(:all, :conditions=>" date = date(\'#{d3.to_s}\')", :order=>"id asc")
 
  sa=[]

  rl=[]
  w_list1.each do |r1|
  	r2=w_list2.find {|rec| rec['code'] == r1['code']}
   # r3=w_list3.find {|rec| rec['code'] == r1['code']}
    if (r2!=nil) #and (r3!=nil)    
       #if (0.99*r1['close']<=r2['close']) and (0.99*r1['close']<=r3['close'])
         if (r2['close']>=0.99*r1['close'])# and (r3['close']>=r1['close'])
     
       	 #( h2[:price] - min) / min < -0.01
       	   h=Hash.new
       	   h[:code]=r1['code']
       	   h[:price]=r1['close']
       	   h[:date]=r1['date']
           rl.push(h)
       end
    end
  end

 #p rl.length

    while(1)

       rl.each_with_index do |h2,i|
       	# puts "checking #{h2[:code]}..."
	       open,high,close,low=get_price_from_sina(h2[:code])
	       #sleep(1) if (i%9 == 0)
       	   if (0.99*close >= h2[:price]) and (close>0.0)
       	   #if h2[:price]<= 0.99*close
       	   #if ((h2[:price]-close)/close< -0.01 )
               #p h2
               #p close
       	   	   price = close
		       old_price = h2[:price]
		       roe = ((price - old_price)/old_price*100)
		       #p roe
		       if roe>1
			       puts "found #{Names.get_name(h2[:code])}(#{h2[:code]}) on #{Time.now.to_s} at price #{price},low price #{h2[:price]} ,roe:#{(roe*100).floor/100.0}%"

			       h=Hash.new 
			       h[:code] =h2[:code]
			       h[:price]=price
			       h[:min_price]=h2[:price]
			       h[:date] = day
			       h[:min_date] = h2[:date]
			       h[:last_days]= 2
			      # h[:sort_key]= min['last_days']

			       #roe +=100 if roe<=1

			       h[:roe]=roe

			       #h[:sort_key]=  h[:sort_key]+35 if  h[:sort_key]<=63
			       

			       sa.push(h) if (nil==sa.find{|h3| h3[:code]==h2[:code]})
		       end
		   end
		 end


        puts "------------------------------------------------------------------------------"
	    #p sa.length
	    sa.sort_by!{|h| h[:roe]}
	    #sa.reverse!
	    len = sa.length

	    len=10 if len>10

	    sa[0..len-1].each do |h|
	     # p h
	      puts "#{Names.get_name(h[:code])}(#{h[:code]}) on #{Time.now.to_s}, price #{h[:price]}, last price #{h[:min_price]} on #{h[:min_date]} #{(h[:roe]*100).floor/100.0}% high compared to last price" 
	    end

	     puts "------------------------------------------------------------------------------"
	    #p sa.length

	    len = sa.length

	    len=25 if len>25

	    rsa =sa.reverse

	    rsa[0..len-1].each do |h|
	     # p h
	      puts "#{Names.get_name(h[:code])}(#{h[:code]}) on #{Time.now.to_s}, price #{h[:price]}, last price #{h[:min_price]} on #{h[:min_date]} #{(h[:roe]*100).floor/100.0}% high compared to last price" 
	    end


	    sleep(300) #check every 5 minutes
    end


 end

 #monitor_run

 def monitor_run2
  #  day=Time.now.to_date
  #  return if day.sunday?
  #  return if day.saturday?

  # # p day
  #  d1=previous_work_day(day)
  #  d2=previous_work_day(d1)  
  #  d3=previous_work_day(d2)

  #  #p1,p2,p3=get_price_for_day('000651',d1,d2,d3)

  #  #p d1,d2,d3

  #  #p p1,p2,p3
  #  sa=[]
  #  i = 0
  # Names.get_code_list.each do |code|
  # 	puts "getting #{code} data from sina..."
  #   #p1,p2,p3=get_price_for_day(code,d1,d2,d3)

  #   #if (p1<p2) and (p1<p3)
  #    open,high,close,low=get_price_from_sina(code)
  #    #roe = (close-p1)/p1*100
  #    #roe +=50 if roe<=1

  #    h=Hash.new
  #    h[:price]=close
  #    #h[:roe]=roe
  #    h[:time] = Time.now
  #    sa.push(h)

  #   #end
  #   #break;
  #   # i += 1
  #   # if (i>=25)
  #   #   puts "wait 10 seconds"
  #   #   sleep(10)
  #   #   i = 0
  #   # end

  # end

  #   sa.sort_by{|h| h[:roe]}
  #   sa.each {|h| p h}


  

   day=Time.now.to_date
   return if day.sunday?
   return if day.saturday?


   #day=previous_work_day(day)

  # p day
   d1=previous_work_day(day)
   d2=previous_work_day(d1)  
   d3=previous_work_day(d2)

  min_list = Daily_minlist_records.get_min_list_for_day(d1,2)
 
  w_list1 = Lastest_records.find(:all, :conditions=>" date = date(\'#{d1.to_s}\')", :order=>"id asc")
  w_list2 = Lastest_records.find(:all, :conditions=>" date = date(\'#{d2.to_s}\')", :order=>"id asc")
  #w_list3 = Lastest_records.find(:all, :conditions=>" date = date(\'#{d3.to_s}\')", :order=>"id asc")
 
  sa=[]

  rl=[]
  w_list1.each do |r1|
  	r2=w_list2.find {|rec| rec['code'] == r1['code']}
   # r3=w_list3.find {|rec| rec['code'] == r1['code']}
    if (r2!=nil) #and (r3!=nil)    
       #if (0.99*r1['close']<=r2['close']) and (0.99*r1['close']<=r3['close'])
         if (r2['close']>=0.99*r1['close'])# and (r3['close']>=r1['close'])
     
       	 #( h2[:price] - min) / min < -0.01
       	   h=Hash.new
       	   h[:code]=r1['code']
       	   h[:price]=r1['close']
       	   h[:date]=r1['date']
           rl.push(h)
       end
    end
  end

 #p rl.length

    while(1)

       rl.each_with_index do |h2,i|
       	# puts "checking #{h2[:code]}..."
	       open,high,close,low=get_price_from_sina(h2[:code])
	       #sleep(1) if (i%9 == 0)
       	   if (0.99*close >= h2[:price]) and (close>0.0)
       	   #if h2[:price]<= 0.99*close
       	   #if ((h2[:price]-close)/close< -0.01 )
               #p h2
               #p close
       	   	   price = close
		       old_price = h2[:price]
		       roe = ((price - old_price)/old_price*100)
		       #p roe
		       if roe>1
			       puts "found #{Names.get_name(h2[:code])}(#{h2[:code]}) on #{Time.now.to_s} at price #{price},low price #{h2[:price]} ,roe:#{(roe*100).floor/100.0}%"

			       h=Hash.new 
			       h[:code] =h2[:code]
			       h[:price]=price
			       h[:min_price]=h2[:price]
			       h[:date] = day
			       h[:min_date] = h2[:date]
			       h[:last_days]= 2
			      # h[:sort_key]= min['last_days']

			       #roe +=100 if roe<=1

			       h[:roe]=roe

			       #h[:sort_key]=  h[:sort_key]+35 if  h[:sort_key]<=63
			       

			       sa.push(h) if (nil==sa.find{|h3| h3[:code]==h2[:code]})
		       end
		   end
		 end


        puts "------------------------------------------------------------------------------"
	    #p sa.length
	    sa.sort_by!{|h| h[:roe]}
	    #sa.reverse!
	    len = sa.length

	    len=10 if len>10

	    sa[0..len-1].each do |h|
	     # p h
	      puts "#{Names.get_name(h[:code])}(#{h[:code]}) on #{Time.now.to_s}, price #{h[:price]}, last price #{h[:min_price]} on #{h[:min_date]} #{(h[:roe]*100).floor/100.0}% high compared to last price" 
	    end

	     puts "------------------------------------------------------------------------------"
	    #p sa.length

	    len = sa.length

	    len=25 if len>25

	    rsa =sa.reverse

	    rsa[0..len-1].each do |h|
	     # p h
	      puts "#{Names.get_name(h[:code])}(#{h[:code]}) on #{Time.now.to_s}, price #{h[:price]}, last price #{h[:min_price]} on #{h[:min_date]} #{(h[:roe]*100).floor/100.0}% high compared to last price" 
	    end


	    sleep(300) #check every 5 minutes
    end


 end


 def monitor_run3(period,topN)

  sa=[]
  day= Time.now.to_date
  old_day = previous_work_day(day)
  min_list = Daily_minlist_records.get_min_list_for_day(old_day,2)
 
  w_list2 = Daily_records.find(:all, :conditions=>" date = date(\'#{old_day.to_s}\')", :order=>"id asc")

  
  while (1)
  	sa = []

	min_list.each do |min|

	    code=min['code']    
	    if ((r2 = w_list2.find {|rec| rec['code'] == code})!=nil)
	       #puts "fetching data from sina for code #{code}..."
	       open,high,close,low=get_price_from_sina(code)

	       if ((r2['close'] - close) / close < -0.01 ) and (r2['amount'] !=0.0)
	       	  # it's a real case.
	       	   price = close
		       old_price = r2['close']
		       roe = ((price - old_price)/old_price*100)

		       if roe>1
		           #puts "found #{Names.get_name(code)}(#{code}) on #{Time.now.to_s} at price #{price},low price #{old_price} ,roe:#{(roe*100).floor/100.0}%"
	   	   
			       h=Hash.new 
			       h[:code] =code
			       h[:price]=price
			       h[:min_price]=min['price']
			       h[:date] = day
			       h[:min_date] = min['date']
			       h[:last_days]= min['last_days']
			      # h[:sort_key]= min['last_days']

			      # roe = 100 if roe <=0
			      # roe +=10 if roe<=1

			       h[:roe]=roe

			       #h[:sort_key]=  h[:sort_key]+35 if  h[:sort_key]<=63
			       

			       sa.push(h)
		       end
	       end

	       
	       #p h
	    end
	end

	    #p sa.length
	    sa.sort_by!{|h| h[:roe]}
	    
	    ind = sa.length
	    ind = topN if ind>topN

	    puts "------------------------------------------------------------------------------"
	    sa[0..ind].each do |h|
	     # p h
	      puts "#{Names.get_name(h[:code])}(#{h[:code]}) on #{Time.now.to_s}, last #{h[:last_days]} days, price #{h[:price]}, last price #{h[:min_price]} on #{h[:min_date]} #{(h[:roe]*100).floor/100.0}% high compared to last price"  
	    end
 
      sleep(period)   
  end # while(1)

end

def monitor_run4(period,topN,sort_roe=0)

  sa=[]
  day= Time.now.to_date
  old_day = previous_work_day(day)
  old_day = previous_work_day(old_day)

  #p old_day
  
  min_list = Daily_minlist_records.get_min_list_for_day(old_day,2)
  w_list2 = Daily_records.find(:all, :conditions=>" date = date(\'#{previous_work_day(day).to_s}\')", :order=>"id asc")

  if sort_roe!=1
	  min_list.sort_by! do |min|
		    code=min['code']    
		    if ((r2 = w_list2.find {|rec| rec['code'] == code})!=nil)
		       old_price = r2['close']
		       roe_passed = ((old_price-min['price'])/min['price']*100)
		       roe_passed+=1000 if roe_passed<=1 
		       roe_passed
		    end
	  end


    ind = min_list.length
    ind = topN if ind>topN
    min_list = min_list[0..topN-1]
  end

  
  while (1)
  	sa = []

	min_list.each do |min|
	    code=min['code']    
	    if ((r2 = w_list2.find {|rec| rec['code'] == code})!=nil)
	       #puts "fetching data from sina for code #{code}..."
	       open,high,close,low=get_price_from_sina(code)
       	   price = close
	       old_price = r2['close']
	       roe = ((price - old_price)/old_price*100)
	       roe_passed = ((old_price-min['price'])/min['price']*100)

           #puts "found #{Names.get_name(code)}(#{code}) on #{Time.now.to_s} at price #{price},buy price #{old_price} ,roe:#{(roe*100).floor/100.0}%"
	   
	       h=Hash.new 
	       h[:code] =code
	       h[:price]=price
	       h[:min_price]=min['price']
	       h[:date] = day
	       h[:min_date] = min['date']
	       h[:last_days]= min['last_days']
	       h[:roe]=roe

	       roe_passed+=1000 if roe_passed<=1 
	       h[:roe_passed]=roe_passed
	       sa.push(h)
	    end
	end

	    #p sa.length
	    if sort_roe==1
	      sa.sort_by!{|h| h[:roe]}
	      sa.reverse!
	    else
	       sa.sort_by!{|h| h[:roe_passed]}
	    end
	    #sa.reverse!

	    ind = sa.length
	    ind = topN if ind>topN

	    puts "------------------------------------------------------------------------------"
	    sa[0..ind].each do |h|
	     # p h
	      puts "#{Names.get_name(h[:code])}(#{h[:code]}) on #{Time.now.to_s}, last #{h[:last_days]} days, price #{h[:price]}, last price #{h[:min_price]} on #{h[:min_date]} today roe=#{(h[:roe]*100).floor/100.0}%, last roe=#{(h[:roe_passed]*100).floor/100.0}%"  
	    end
 
      sleep(period)   
  end # while(1)

end

#  def weekly_monitor(period,topN)

#   sa=[]
#   day= Time.now.to_date
#   old_day = previous_work_day(day)
#   min_list = Daily_minlist_records.get_min_list_for_day(old_day,2)
 
#   w_list2 = Daily_records.find(:all, :conditions=>" date = date(\'#{old_day.to_s}\')", :order=>"id asc")

  
#   while (1)
#     sa = []

#   min_list.each do |min|

#       code=min['code']    
#       if ((r2 = w_list2.find {|rec| rec['code'] == code})!=nil)
#          #puts "fetching data from sina for code #{code}..."
#          open,high,close,low=get_price_from_sina(code)

#          if ((r2['close'] - close) / close < -0.01 ) and (r2['amount'] !=0.0)
#             # it's a real case.
#              price = close
#            old_price = r2['close']
#            roe = ((price - old_price)/old_price*100)

#            if roe>1
#                #puts "found #{Names.get_name(code)}(#{code}) on #{Time.now.to_s} at price #{price},low price #{old_price} ,roe:#{(roe*100).floor/100.0}%"
         
#              h=Hash.new 
#              h[:code] =code
#              h[:price]=price
#              h[:min_price]=min['price']
#              h[:date] = day
#              h[:min_date] = min['date']
#              h[:last_days]= min['last_days']
#             # h[:sort_key]= min['last_days']

#             # roe = 100 if roe <=0
#             # roe +=10 if roe<=1

#              h[:roe]=roe

#              #h[:sort_key]=  h[:sort_key]+35 if  h[:sort_key]<=63
             

#              sa.push(h)
#            end
#          end

         
#          #p h
#       end
#   end

#       #p sa.length
#       sa.sort_by!{|h| h[:roe]}
      
#       ind = sa.length
#       ind = topN if ind>topN

#       puts "------------------------------------------------------------------------------"
#       sa[0..ind].each do |h|
#        # p h
#         puts "#{Names.get_name(h[:code])}(#{h[:code]}) on #{Time.now.to_s}, last #{h[:last_days]} days, price #{h[:price]}, last price #{h[:min_price]} on #{h[:min_date]} #{(h[:roe]*100).floor/100.0}% high compared to last price"  
#       end
 
#       sleep(period)   
#   end # while(1)

# end

 def generate_nday_data(num_of_records=3)

 	date_list = Daily_records.new.get_date_list
     len = date_list.length
     date_list = date_list[len-num_of_records..len-1]

    wid=1
    date_list.each do |day|
    	puts "generating data for #{day.to_s}..."
	 	w_list = Daily_records.find(:all, :conditions=>" date = date(\'#{day.to_s}\')", :order=>"id asc")
	 	sa=[]
	    w_list.each do |rec|

	 	  ts = "#{wid},\'#{rec['code'].to_s}\',date(\'#{rec['date']}\'),#{rec['open']},#{rec['high']},#{rec['low']},#{rec['close']},#{rec['volume']},#{rec['amount']}"
	            
	 	  sa.push(ts)
	 	  wid+=1
	 	end

	 	insert_data('lastest_records',sa)
 	end
end

def add_today_data

    if Lastest_records.count==0
      puts "empty table for lastest_records,importing data from daily_records"
      generate_nday_data(5)
    end
    #return

    date=Lastest_records.last['date']
    if Time.now.to_date == date
    	puts "already have today's data"
    	return
    end 

    if previous_work_day(Time.now.to_date) != date
    	puts "lastest_records last date=#{date}, should be #{previous_work_day(Time.now.to_date)} ,add_today_data only add today's data."
    	return 
    end
    
    puts "updating lastest_records table..."
    wid=Lastest_records.last['id'].to_i+1
    sa=[]
  	Names.get_code_list.each do |code|
  		puts "fetch data from sina for #{code} for #{Time.now.to_date.to_s}..."
  		open,high,close,low,volume,amount=get_trade_data_from_sina(code)
  		if open!=0.0

  		 ts = "#{wid},\'#{code.to_s}\',date(\'#{Time.now.to_date.to_s}\'),#{open},#{high},#{low},#{close},#{volume},#{amount}"
	            
	 	  sa.push(ts)
	 	  wid+=1
	 	end
	 	  #break
  	end
  	insert_data('lastest_records',sa)

    return


   #  puts "updating daily_records table..."
   #  wid=Daily_records.last['id'].to_i+1
   
  	# nsa=sa.collect do |line|
  	
  	# 	ind = line.index(',')
  	# 	len = line.length
  	# 	ns = line[ind+1..len-1]

  	# 	ind=ns.index(',')
  	# 	code=ns[1..ind-2]
  	# 	#p code.to_s
  	# 	last=Daily_records.new.get_last_record(code)
  	
  	# 	week_num = 0
	  #   month_num = 0
	  #   if last['date'].cweek == Time.now.to_date.cweek
	  #     week_num = last['week_num']
	  #   else
	  #     week_num = last['week_num']+1
	  #   end

	  #   if last['date'].month == Time.now.to_date.month
	  #     month_num = last['month_num']
	  #   else
	  #     month_num = last['month_num']+1
	  #   end

  	
  	# 	ts = "#{wid},"+ns+",#{week_num},#{month_num}" 	
	  #   wid+=1
	  #   #p ts 
	 	
  	# end
  	# insert_data('daily_records',nsa)

    puts "updating daily_minlist_records table..."
    old_day=previous_work_day(Time.now.to_date)
    min_list = Daily_minlist_records.get_min_list_for_day(old_day,0)
  
    if min_list==nil
      puts "can't find #{old_day} from daily_minlist_records "
      return
    end

    today_list = Lastest_records.get_list_by_date(Time.now.to_date)
    old_list = Lastest_records.get_list_by_date(previous_work_day(Time.now.to_date))
    elder_list = Lastest_records.get_list_by_date(previous_work_day(previous_work_day(Time.now.to_date)))
   # elder_list2 = Lastest_records.get_list_by_date(previous_work_day(previous_work_day(previous_work_day(Time.now.to_date))))
    #wid=Daily_minlist_records.get_min_list_for_day()
    p today_list.length
    p Names.get_code_list.length


    sa=[]
    min_list.each do |rec|
    	#p "checking #{rec['code']}..."

        t=Lastest_records.find(:first, :conditions=>"code = \'#{rec['code']}\' and date = date(\'#{rec['date'].to_s}\')", :order=>"id asc")
        if (t!=nil) and (t['amount'] == 0.0)
        	ts = "delete from daily_minlist_records where id=#{rec['id']}"
		    sa.push(ts)     
        end

    	r= today_list.find{|r| r['code'] == rec['code']}
    	if r==nil
    		ts = "delete from daily_minlist_records where id=#{rec['id']}"
		    sa.push(ts) 
    	else
	    	price = r['close']
	    	old_price = rec['price']

		    if ((old_price - price) / price < -0.01) and (r['amount'] !=0.0)
		    	
		    else
		    	ts = "delete from daily_minlist_records where id=#{rec['id']}"
		        sa.push(ts) 	
		    end
	    end
    end
    insert_data('daily_minlist_records',sa)

    sa=[]
    wid=Daily_minlist_records.last['id']+1

    # today_list.each do |rec|
    #     code= rec['code']
    #     puts "checking #{code}..."
    #     last_days = 0
    #     price = rec['close'] 
    #     w_list = Daily_records.find(:all, :conditions=>"code = \'#{code}\'", :order=>"id asc")

    #     w_list.reverse.each do |r|
    #     	old_price = r['close']
    #     	#puts "checking #{r['date'].to_s} for #{code}"
	   #      if ((old_price - price) / price < -0.01)
    #              last_days = (rec['date']-r['date']).to_i

    #              if last_days>1
			 #         ts = "#{wid},\'#{code.to_s}\',date(\'#{Time.now.to_date.to_s}\'),#{last_days},#{rec['price']}"
			 #         sa.push(ts)
			 #         wid += 1
		  #        end

		  #        break
	   #       end
    #      end

    # end

     today_list.each do |rec|
        code= rec['code']
        puts "checking #{code}..."
        last_days = 0
        price = rec['close'] 

        r1=old_list.find{|x| x['code']==code}
        if (r1!=nil) 
        	old_price = r1['close']
        	 if ((old_price - price) / price < -0.01)
        	 	#next
        	 else

        	 	r2=elder_list.find{|x| x['code']==code}
			        if (r2!=nil) 
			        	old_price = r2['close']
			        	 #if ((old_price - price) / price < -0.01)
		        	 	last_days = (rec['date']-r2['date']).to_i
		        	 	#p last_days

		                 #if last_days>1
				         ts = "#{wid},\'#{code.to_s}\',date(\'#{Time.now.to_date.to_s}\'),#{last_days},#{rec['close']}"
				         #p ts
				         sa.push(ts)
				         wid += 1
				         #end

			        	 	#next
			        	 #end
			       
				     
			        end


        	 end
        else

        	        	 #if ((old_price - price) / price < -0.01)
		        	 	# last_days = 2
		        	 	# #p last_days

		           #       #if last_days>1
				         # ts = "#{wid},\'#{code.to_s}\',date(\'#{Time.now.to_date.to_s}\'),#{last_days},#{rec['close']}"
				         # #p ts
				         # sa.push(ts)
				         # wid += 1

        end

        # r2=elder_list.find{|x| x['code']==code}
        # if (r2!=nil) 
        # 	old_price = r2['close']
        # 	 if ((old_price - price) / price < -0.01)
        # 	 	last_days = (rec['date']-r2['date']).to_i
        # 	 	#p last_days

        #          if last_days>1
			     #     ts = "#{wid},\'#{code.to_s}\',date(\'#{Time.now.to_date.to_s}\'),#{last_days},#{rec['close']}"
			     #     p ts
			     #     sa.push(ts)
			     #     wid += 1
		      #    end

        # 	 	#next
        # 	 end
        # else
	       #  r3=elder_list2.find{|x| x['code']==code}
	       #  if (r3!=nil) 
	       #  	old_price = r3['close']
	       #  	 if ((old_price - price) / price < -0.01)
	       #  	 	last_days = (rec['date']-r3['date']).to_i
	       #  	 	#p last_days

	       #           if last_days>1
				    #      ts = "#{wid},\'#{code.to_s}\',date(\'#{Time.now.to_date.to_s}\'),#{last_days},#{rec['close']}"
				    #      p ts
				    #      sa.push(ts)
				    #      wid += 1
			     #     end
			         
	       #  	 	next
	       #  	 end
	       #  end
        # end

        # w_list = Daily_records.find(:all, :conditions=>"code = \'#{code}\'", :order=>"id asc")

        # w_list.reverse.each do |r|
        # 	old_price = r['close']
        # 	#puts "checking #{r['date'].to_s} for #{code}"
	       #  if ((old_price - price) / price < -0.01)
        #          last_days = (rec['date']-r['date']).to_i

        #          if last_days>1
			     #     ts = "#{wid},\'#{code.to_s}\',date(\'#{Time.now.to_date.to_s}\'),#{last_days},#{rec['price']}"
			     #     sa.push(ts)
			     #     wid += 1
		      #    end

		      #    break
	       #   end
        #  end

    end

    # w_list=Daily_records.find(:all, :conditions=>" date = date(\'#{old_day.to_s}\')", :order=>"id asc")
    # w_list.each do |rec|
    #     code = rec['code']
    # 	r1=today_list.find{|x| x['code']==code}
    # 	if r1==nil

    # 		    	 	last_days = 2
		  #    	         ts = "#{wid},\'#{code.to_s}\',date(\'#{Time.now.to_date.to_s}\'),#{last_days},#{rec['close']}"
				#          sa.push(ts)
				#          wid += 1

    # 	end
    # end

   insert_data('daily_minlist_records',sa)
   


 end

#monitor_run3
#p get_trade_data_from_sina('600036')
#generate_nday_data 4

#add_today_data

# a=Daily_records.new
# p Time.now.to_date-5
# p Time.now.to_date
# p a.get_days_between(Time.now.to_date-5,Time.now.to_date)

def print_help
    puts "This Tool is used to monitor daily data from sina.com and give which to buy."
    puts "-d period(sec) topN    ---  searching for today's candidate "
    puts "-o period(sec) topN sort_roe  ---  Monitor yesterday performance" 
    puts "-u                     ---  fetch data from sina after 3:00,update database." 
    puts "-h                     ---  This help"    
end

#main program begin here...
if ARGV.length != 0
 
    ARGV.each do |ele|       
        if  ele == '-h'          
          print_help
          exit 
        end 
  
	    if ele == '-d'
	      period = ARGV[ARGV.index(ele)+1].to_i
	      topN = ARGV[ARGV.index(ele)+2].to_i    
	      # puts "Using directory : "+dir  
	      monitor_run3(period,topN)
	    end

	    if ele == '-o'
	      period = ARGV[ARGV.index(ele)+1].to_i
	      topN = ARGV[ARGV.index(ele)+2].to_i    
	      sort_roe = ARGV[ARGV.index(ele)+3].to_i    
	      # puts "Using directory : "+dir  
	      monitor_run4(period,topN,sort_roe)
	    end

	    if ele == '-u'
	      # period = ARGV[ARGV.index(ele)+1].to_i
	      # topN = ARGV[ARGV.index(ele)+2].to_i    
	      # sort_roe = ARGV[ARGV.index(ele)+3].to_i    
	      # puts "Using directory : "+dir  
	      add_today_data
	    end
    end
end