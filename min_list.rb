require "shared_setup"
require 'time'
require 'active_record'
require 'common'
require 'open-uri'


def analyze_min_list(sa)
  

 sa.sort_by!{|h| h[:last_days]}

    s_last_days=[]
    s_roe_passed=[]

    sa.each do |h|
      
      last_days = h[:last_days]
      #last_days = (h[:last_days]/7).ceil*7
      last_days = (h[:last_days]/28).ceil*28 if last_days>=238
      h2 = s_last_days.find{|x| x[:last_days] == last_days}
      if h2==nil
        h2=Hash.new
        h2[:last_days] = last_days
        h2[:counter]=1
        h2[:ave_roe_passed] = h[:roe_passed]
        h2[:ave_roe_next] = h[:roe_next]
        
        s_last_days.push(h2)
      else        
        h2[:ave_roe_passed] = (h2[:ave_roe_passed]*h2[:counter]+ h[:roe_passed])/(h2[:counter]+1) 
        h2[:ave_roe_next] = (h2[:ave_roe_next]*h2[:counter]+ h[:roe_next])/(h2[:counter]+1) 
        h2[:counter] +=1
      end 

      roe_passed = (h[:roe_passed]).ceil+200 if h[:roe_passed]>=12
      roe_passed = (h[:roe_passed]*10).ceil if h[:roe_passed]<12 
      #roe_passed = (h[:roe_passed]/20.0).ceil*20 if h[:roe_passed]>20
      #roe_passed = 0 if h[:roe_passed]<0
      h3 = s_roe_passed.find{|x| x[:roe_passed] == roe_passed}
      if h3==nil
        h3=Hash.new
        h3[:counter]=1
        h3[:roe_passed] = roe_passed
        h3[:ave_last_days] = h[:last_days]
        h3[:ave_roe_next] = h[:roe_next]
        
        s_roe_passed.push(h3)
      else        
        h3[:ave_roe_next] = (h3[:ave_roe_next]*h3[:counter]+ h[:roe_next])/(h3[:counter]+1) 
        h3[:ave_last_days] = (h3[:ave_last_days]*h3[:counter]+ h[:last_days])/(h3[:counter]+1) 
     
        h3[:counter] +=1
      end 


    end

    puts "last_days analysis"
    s_last_days.each do |h|
      puts "last_days=#{h[:last_days]} : counter=#{h[:counter]} : ave_roe_next=#{(h[:ave_roe_next]*100).floor/100.0}% : ave_roe_passed=#{(h[:ave_roe_passed]*100).floor/100.0}%"
    end
    
    s_roe_passed.sort_by!{|h| h[:roe_passed]}
     puts "roe_passed analysis"
     s_roe_passed.each do |h|
      puts "roe_passed=#{h[:roe_passed]} : counter=#{h[:counter]} : ave_roe_next=#{(h[:ave_roe_next]*100).floor/100.0}% : ave_last_days=#{(h[:ave_last_days]).floor}"
    end

end

#the following is for weekly min list
def analyze_weekly_min_list(num)
   roe = 0.0
  sa=[]

  day_list=Weekly_records.new.get_date_list
  len = day_list.length


  day_list[0..num-1].each_with_index do |day,i|
      day= day_list[len-num+i]
      old_day = day_list[len-num+i-1]
      elder_day = day_list[len-num+i-2]
      min_list = Weekly_minlist_records.get_min_list_for_day(elder_day,2)
      next if min_list==nil
      puts "analyze #{day.to_s} ... "
     
      w_list1 = Weekly_records.find(:all, :conditions=>" date = date(\'#{day.to_s}\')", :order=>"id asc")
      w_list2 = Weekly_records.find(:all, :conditions=>" date = date(\'#{old_day.to_s}\')", :order=>"id asc")
      w_list3 = Weekly_records.find(:all, :conditions=>" date = date(\'#{elder_day.to_s}\')", :order=>"id asc")

      

      min_list.each do |min|

        code=min['code']
        if ((r1=w_list1.find {|rec| rec['code'] == code})!=nil) and
        ((r2 = w_list2.find {|rec| rec['code'] == code})!=nil) and 
        ((r3 = w_list3.find {|rec| rec['code'] == code})!=nil)

           roe1 = ((r1['close'] - r2['close'])/r2['close']*100)
           roe2 = ((r2['close'] - r3['close'])/r3['close']*100)

           h=Hash.new 
           h[:last_days] = min['last_days']
           h[:roe_passed]= roe2
           h[:roe_next]=roe1

           sa.push(h)
           #p h
        end
      end
    end

    analyze_min_list(sa)
end

def show_last_minlist(topn,least_days)

  roe = 0.0
  sa=[]

  day_list=Weekly_records.new.get_date_list
  len = day_list.length
  day= day_list[len-1]
  old_day = day_list[len-2]
  min_list = Weekly_minlist_records.get_min_list_for_day(old_day,least_days)
 
  w_list1 = Weekly_records.find(:all, :conditions=>" date = date(\'#{day.to_s}\')", :order=>"id asc")
  w_list2 = Weekly_records.find(:all, :conditions=>" date = date(\'#{old_day.to_s}\')", :order=>"id asc")


  min_list.each do |min|

    code=min['code']
    if ((r1=w_list1.find {|rec| rec['code'] == code})!=nil) and
    ((r2 = w_list2.find {|rec| rec['code'] == code})!=nil)
       price = r1['close']
       old_price = r2['close']
       roe = ((price - old_price)/old_price*100)

       h=Hash.new 
       h[:code] =code
       h[:price]=price
       h[:min_price]=min['price']
       h[:date] = day
       h[:min_date] = min['date']
       h[:last_days]= min['last_days']
      # h[:sort_key]= min['last_days']

      roe = 100 if roe <=0
      roe +=50 if roe<=1

       h[:roe]=roe

       #h[:sort_key]=  h[:sort_key]+35 if  h[:sort_key]<=63
       

       sa.push(h)
       #p h
    end
  end

    #p sa.length
    sa.sort_by!{|h| h[:roe]}
    #sa.reverse!
    
    ind = (topn-1)<(sa.length-1) ? (topn-1) : (sa.length-1)
    
    #p ind

    sa[0..ind].each do |h|
     # p h
      puts "#{Names.get_name(h[:code])}(#{h[:code]}) on #{h[:date].to_s}, last #{h[:last_days]} days at price #{h[:price]}, min price #{h[:min_price]} on #{h[:min_date]} #{(h[:roe]*100).floor/100.0}% high compared to last price" 
    end

end

def find_min_list(code,least_days=7,dr)

    w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"date asc")
    len=w_list.length
    return nil if len == 0

    min_list=[]
    min = w_list[len-1]['close'] 
    min_date = w_list[len-1]['date']
  

    w_list[0..len-2].reverse.each do |rec|
      if ( rec['close'] - min) / min < -0.01
      #if ( rec['close'] < min) 

        h= Hash.new
       
        h[:last_days] = (min_date - rec['date']).to_i 
        #h[:last_days] = dr.get_days_between(rec['date'],min_date)
        h[:date]  = min_date
        h[:price] = min

        min_list.push(h)

        min = rec['close']
        min_date = rec['date']

      end
     end

     min_list.delete_if {|x| x[:last_days] < least_days}
        
     return min_list if min_list.length!=0
     
     return nil
end


def update_all_minlist(least_days=7)

  sa=[]
  wid=1
  line = 0
  dr = Daily_records.new
  #last_day = Weekly_records.last['date']

 # if wid == 1
 #         ts = "delete from weekly_minlist_records"
 #         sa.push(ts)
 #         wid += 1
 #         line+=1 

 # end

  Names.get_code_list.each do |code|
    puts "generating minimum list : #{code}"
    #p Time.now
    min_list=find_min_list(code,least_days,dr)
    #p Time.now
    #sleep(5)

    if min_list!=nil
       min_list.each do |rec|
             week_num = Weekly_records.get_week_num(code,rec[:date])
             #p week_num
             ts = "#{wid},\'#{code.to_s}\',date(\'#{rec[:date]}\'),#{week_num},#{rec[:last_days]},#{rec[:price]}"
             sa.push(ts)
             wid += 1
             line += 1
       end
    end
    
    #p wid
   #break if wid > 10
   if line > 1000
     insert_data("weekly_minlist_records",sa) 
     sa = []
     line = 0
   end

  end #end of Names.get_code_list
 #sa.each {|x| p x}
 insert_data("weekly_minlist_records",sa) if line!=0

end # update_all_minlist
 

# def get_day_list_from_file(dir)
#   cl_ist=["SH601988.txt","SH601398.txt","SH601328.txt"]

#   i=0
#   date_list=[nil,nil,nil]
#   cl_ist.each do |afile|
#     fname = "#{dir}\/#{afile}"

#     #p fname
    
#     date_list[i]=[]
#      File.open(fname,:encoding => 'gbk') do |file|       
#         file.each_line do |line|
#            t = line[2]
#            if t=='/' #non blank line ,has data 
#               day_num = Time.new(line[6..9].to_i,line[0..1].to_i,line[3..4].to_i,0,0,0).to_date
#               date_list[i].push(day_num)
#           end
#         end
#       end
#     i+=1
#   end

#   dl=[]
#   if (date_list[0].length!= date_list[1].length) or (date_list[1].length!= date_list[2].length)
#     puts "not same length for 3 code!!!"
#     return []
#   end


#      dl = date_list[0]+date_list[1]+date_list[2]
#     return dl.uniq
# end

#the following is for daily min list
def generating_daily_minlist(dir,least_days=2)

  dr = Daily_records.new
  #first_time = true

  wid=1

  date_list = get_day_list_from_file(dir)

  #p date_list

  #return
   
  Dir.glob("#{dir}\/*.txt").each do |afile|
      puts "generating min list file #{afile}"

     

      pos = afile.index('S')
      market=afile[pos..(pos+1)]  #SH SZ
      fcode = afile[(pos+2)..(pos+7)]

      sa = []  
      line_list=[]  
      lid=1
      have_data=false

      first_record = true;

      counter =1

      stop_trade_flag = false

      last_day = nil

      ind=0

      File.open(afile,:encoding => 'gbk') do |file|

       
        file.each_line do |line|
          #puts line
          t = line[2]
        

          if t=='/' #non blank line ,has data 

               have_data = true
              #day=line[6..9]+'-'+line[0..1]+'-'+line[3..4]       

            
              td,open,high,low,close,volume,amount = line.split(/\t/)
        
              day_num = Time.new(line[6..9].to_i,line[0..1].to_i,line[3..4].to_i,0,0,0).to_date

              #p amount.to_f
              if first_record
                first_record = false
                ind = date_list.index(day_num)
              else
                #ind = date_list.index(last_day)
                #p date_list[ind].to_s
                #p day_num.to_s
                ind+=1

                if date_list[ind] != day_num
                  stop_trade_flag = true

                  while date_list[ind] != day_num
                    ind+=1
                  end

                else
                  stop_trade_flag = false
                end

              end

              if amount.to_f!=0.0
                #p amount if day_num == (Time.now.to_date-1)
                h=Hash.new
               # h[:lid] = lid
                h[:code]=fcode
                h[:date]=day_num
                h[:price]=close.to_f
                h[:stop_trade]=stop_trade_flag
                #if stop_trade_flag
                  #puts "#{day_num} not in trade"
                #end
                #counter +=1
                #h[:last_days]=0

                sa.push(h)
              end

              last_day = day_num
            
          end

        end # each line
        #break
      end  # each do file

      #return

      #puts "come!"

    if have_data and (sa.length!=0) # some blank file have no data
       len=sa.length

        min_list=[]
        min = sa[len-1][:price] 
        min_date = sa[len-1][:date]
        min_stop_trade = false

       sa[0..len-2].reverse.each do |h2|
        if ( h2[:price] - min) / min < -0.01
        #if ( h2[:price] < min) 

          h= Hash.new
          h[:last_days] = (min_date - h2[:date]).to_i 
          #h[:last_days] = dr.get_days_between(h2[:date],min_date)
          h[:date]  = min_date
          h[:price] = min
          h[:code] = h2[:code]

          min_list.push(h) if not min_stop_trade

          min = h2[:price]
          min_date = h2[:date]
          min_stop_trade = h2[:stop_trade]

        end
       end

       min_list.delete_if {|x| x[:last_days] < least_days}

      
       line=0
       sa=[]

        if wid == 1
         ts = "delete from daily_minlist_records"
         sa.push(ts)
         wid += 1
         line+=1 

       end

       min_list.each do |h|
         ts = "#{wid},\'#{fcode.to_s}\',date(\'#{h[:date]}\'),#{h[:last_days]},#{h[:price]}"
         sa.push(ts)
         wid += 1
         line+=1


         if line > 1000
           insert_data("daily_minlist_records",sa) 
           sa = []
           line = 0
         end
       end
      insert_data("daily_minlist_records",sa) if line!=0


     end # have data

      #break
   end

end


def analyze_daily_minlist(dir)

  sa = []

  p "#{dir}"

  Dir.glob("#{dir}\/*.txt").each do |afile|
      puts "analyze min list file #{afile}"

      pos = afile.index('S')
      code = afile[(pos+2)..(pos+7)]

      old_day=elder_day = Time.now.to_date
      old_price=elder_price=0.0

      min_list=Daily_minlist_records.get_min_list(code,2)
      next if min_list==nil

      File.open(afile,:encoding => 'gbk') do |file|
  
        file.each_line do |line|
          #puts line
          t = line[2]
          if t=='/' #non blank line ,has data 
              td,open,high,low,close,volume,amount = line.split(/\t/)
              day= Time.new(line[6..9].to_i,line[0..1].to_i,line[3..4].to_i,0,0,0).to_date

              close=close.to_f

              min=min_list.find{|rec| rec['date'] == elder_day}
              if min!=nil

                 roe1 = ((close - old_price)/old_price*100)
                 roe2 = ((old_price - elder_price)/elder_price*100)

                 h=Hash.new 
                 h[:last_days] = min['last_days']
                 h[:roe_passed]= roe2
                 h[:roe_next]=roe1

                 sa.push(h)
              end
              elder_day = old_day
              old_day = day

              elder_price = old_price
              old_price = close

          end #'/'
        end # each line
      end  # each do file

      #break
   end# dir

    analyze_min_list(sa)

end #def

# used to analysis daily trade,to be finished!!!!
def analyze_daily_trade(dir)

  sa = []

  p "#{dir}"

  Dir.glob("#{dir}\/*.txt").each do |afile|
      puts "analyze min list file #{afile}"

      pos = afile.index('S')
      code = afile[(pos+2)..(pos+7)]

      old_day=elder_day = Time.now.to_date
      old_price=elder_price=0.0

      #min_list=Daily_minlist_records.get_min_list(code,2)
      #next if min_list==nil

      File.open(afile,:encoding => 'gbk') do |file|
  
        file.each_line do |line|
          #puts line
          t = line[2]
          if t=='/' #non blank line ,has data 
              td,open,high,low,close,volume,amount = line.split(/\t/)
              #day= Time.new(line[6..9].to_i,line[0..1].to_i,line[3..4].to_i,0,0,0).to_date

              close=close.to_f

              #min=min_list.find{|rec| rec['date'] == elder_day}
              if (elder_price >=0.99*old_price) and (0.99*close>=old_price)

                 roe1 = ((close - old_price)/old_price*100)
                 roe2 = ((old_price - elder_price)/elder_price*100)
                 
                 if roe1 >1
                   h=Hash.new 
                   h[:last_days] = min['last_days']
                   h[:roe_passed]= roe2
                   h[:roe_next]=roe1

                 sa.push(h)
                 end
              end
              # elder_day = old_day
              # old_day = day

              elder_price = old_price
              old_price = close

          end #'/'
        end # each line
      end  # each do file

      #break
   end# dir

    analyze_min_list(sa)

end #def  

def display_minlist_for_code(code,least_days=56)

   min_list = Daily_minlist_records.get_min_list(code,least_days)

     min_list.each do |rec|
     # p h
      puts "#{Names.get_name(rec['code'])}(#{rec['code']}) on #{rec['date'].to_s}, last #{rec['last_days']} days at price #{rec['price']}"
    end
end

def show_last_daily_minlist(topn,least_days,pri=0)

  roe = 0.0
  sa=[]

  #day_list=Daily_records.new.get_date_list
  week_date_list=Weekly_records.new.get_date_list
  len=week_date_list.length

  
  #day_list=1.upto(100).collect{|i| week_date_list[len-i]}
  nd=week_date_list[len-1]
  day_list=[]
  i=1
  while i<100
   day_list.push(nd)
   nd=previous_work_day(nd)
   i+=1
  end

  day_list.reverse!
  len = day_list.length
  day= day_list[len-1-pri]
  old_day = day_list[len-2-pri]
  p old_day.to_s
  min_list = Daily_minlist_records.get_min_list_for_day(old_day,least_days)
  
 
  w_list1 = Daily_records.find(:all, :conditions=>" date = date(\'#{day.to_s}\')", :order=>"id asc")
  w_list2 = Daily_records.find(:all, :conditions=>" date = date(\'#{old_day.to_s}\')", :order=>"id asc")


  min_list.each do |min|

    code=min['code']
    if ((r1=w_list1.find {|rec| rec['code'] == code})!=nil) and
    ((r2 = w_list2.find {|rec| rec['code'] == code})!=nil)
      price = r1['close']
      old_price = r2['close']
      roe = ((price - old_price)/old_price*100)

       h=Hash.new 
       h[:code] =code
       h[:price]=price
       h[:min_price]=min['price']
       h[:date] = day
       h[:min_date] = min['date']
       h[:last_days]= min['last_days']
      # h[:sort_key]= min['last_days']

      roe = 100 if roe <=0
      roe +=10 if roe<=1

       h[:roe]=roe

       #h[:sort_key]=  h[:sort_key]+35 if  h[:sort_key]<=63
       

       sa.push(h)
       #p h
    end
  end

    #p sa.length
    sa.sort_by!{|h| h[:roe]}
    #sa.reverse!
    
    ind = (topn-1)<(sa.length-1) ? (topn-1) : (sa.length-1)
    
    #p ind

    sa[0..ind].each do |h|
     # p h
      puts "#{Names.get_name(h[:code])}(#{h[:code]}) on #{h[:date].to_s}, last #{h[:last_days]} days at price #{h[:price]}, min price #{h[:min_price]} on #{h[:min_date]} #{(h[:roe]*100).floor/100.0}% high compared to last price" 
    end

end



def show_last_daily_minlist2(topn,least_days,pri=0)

  roe = 0.0
  sa=[]

  #day_list=Daily_records.new.get_date_list
  week_date_list=Weekly_records.new.get_date_list
  len=week_date_list.length

  
  #day_list=1.upto(100).collect{|i| week_date_list[len-i]}
  nd=week_date_list[len-1]
  day_list=[]
  i=1
  while i<pri+2
   day_list.push(nd)
   nd=previous_work_day(nd)
   i+=1
  end

  day_list.reverse!
  len = day_list.length
 
  0.upto(pri) do |dd|
    #p dd
    puts "-----------------------------------------------------------------------------------------------------------"
    day= day_list[len-1-dd]
    old_day = day_list[len-2-dd]
    #p old_day.to_s
    min_list = Daily_minlist_records.get_min_list_for_day(old_day,least_days)
    #p min_list
    
   
    # w_list1 = Daily_records.find(:all, :conditions=>" date = date(\'#{day.to_s}\')", :order=>"id asc")
    # w_list2 = Daily_records.find(:all, :conditions=>" date = date(\'#{old_day.to_s}\')", :order=>"id asc")

     sa=[]
     min_list.each do |min|

      code=min['code']
   
          open,high,close,low=get_price_from_sina(code)
         price = close
         old_price = min['price']
         roe = ((price - old_price)/old_price*100)
        

         h=Hash.new 
         h[:code] =code
         h[:price]=price
         h[:min_price]=min['price']
         h[:date] = day
         h[:min_date] = min['date']
         h[:last_days]= min['last_days']
        # h[:sort_key]= min['last_days']

         roe = 100 if roe <=0
         roe +=10 if roe<=1

         h[:roe]=roe

         sa.push(h)
     
      end

      #p sa.length
      sa.sort_by!{|h| h[:last_days]}
      sa.reverse!
      
      ind = (topn-1)<(sa.length-1) ? (topn-1) : (sa.length-1)
      
      #p ind

      sa[0..ind].each do |h|
       # p h
        puts "#{Names.get_name(h[:code])}(#{h[:code]}) on #{h[:date].to_s}, last #{h[:last_days]} days at price #{h[:price]}, min price #{h[:min_price]} on #{h[:min_date]} #{(h[:roe]*100).floor/100.0}% high compared to last price" 
      end
  end
end