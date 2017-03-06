$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
 
require "shared_setup"
require "common"
require 'time'
require 'min_list'
require 'asset'
require 'simrun'


def import_base_data(dir,import_daily_record=false,etf=false,update_mode_flag=false)
  fn = 1 
  mid = 1
  #wid = 605276;
  wid=1
  did = 1
  name_list =[]


   dcount = Daily_records.count 
  if dcount != 0
    did = dcount +1
    p "did = #{did}, #{Daily_records.last['id']+1}"
  end

  wcount = Weekly_records.count 
  if wcount != 0
    wid = wcount +1
    p "wid = #{wid}, #{Weekly_records.last['id']+1}"
  end

   mcount = Monthly_records.count 
  if mcount != 0
    mid = mcount +1
    p "mid = #{mid}, #{Monthly_records.last['id']+1}"
  end


  #start_day = Time.new(2009,12,02,0,0,0).to_date
  
  fq_file = File.new("refuquan.txt",'w')


  Dir.glob("#{dir}\/*.txt").sort.each do |afile|
    #puts "processing file #{afile}"

    # ind1=afile.index("SH000300")
    # ind2=afile.index("SZ399905")
    # next if (ind1==nil) and (ind2 == nil)

    puts "processing file #{afile}"

    pos = afile.index('S')
    market=afile[pos..(pos+1)]  #SH SZ
    fcode = afile[(pos+2)..(pos+7)]

    #puts market
    #puts fcode
    if update_mode_flag
      #last_daily_day = Date.parse(Daily_records.where(:code =>"#{fcode}").last['date'])
      #last_monthly_day = Date.parse(Monthly_records.where(:code =>"#{fcode}").last['date'])
      rec = Weekly_records.where(:code =>"#{fcode}").last
      if rec != nil
        last_weekly_day = rec['date']
      else
        last_weekly_day = Date.new(2000,1,1)
      end
      #p "#{fcode} : #{last_daily_day.to_s} #{last_weekly_day.to_s} #{last_monthly_day.to_s}"
      #p last_weekly_day
    else
      last_weekly_day = Date.new(2000,1,1)
    end

   
   
   need_update_week = false
   update_week_id = nil
    
    week_open = 0
         week_high = 0
          week_low = 0
           week_close = 0
            week_volume = 0
             week_amount = 0 

    month_open = 0
         month_high = 0
          month_low = 0
           month_close = 0
            month_volume = 0
             month_amount = 0 
    
   week_list = []
   month_list = []
   line_list = []    

  week = 1
  month = 1
  first_record = true;

  week_t = 0
  month_t = 0

  have_data = false

  week_day = ""
  month_day = ""

  format_from_sina=false
  qf=1.0
  qf_got= false
  previous_qf = 1.0
    

    #enc = 'utf-8'
    File.open(afile,:encoding =>'gbk' ) do |file|
     # File.open(afile) do |file|

     
      file.each_line do |line|
        #puts line
        t = line[2]

        next if t==nil

        if format_from_sina == false
          if line.index('SINA') != nil 
            format_from_sina = true 
          end
        end

        if format_from_sina and (not qf_got)
          # tcode = fcode
          # tcode = '399300' if fcode == '000300'
          # qf = get_fuquan_factor_from_sina(tcode)
          file.rewind
          file.set_encoding('utf-8')
          line = file.readline
          qf = line.scan(/[0-9]+\.[0-9]+/)[0].to_f
          #p qf
          qf_got = true
        end

       
        
        if (t>='0') and (t <= '9') and (not format_from_sina) # the first line
          #code_name = line[7..10].strip
          #puts code_name.encoding

          flag = line[7..8].strip.length


          if flag==2
            if line[7]=='*'
              code_name = line[7..11].strip + " "
            else
              flag = line[7..9].strip.length

              if flag == 2
                code_name = line[7..8].strip + "    " 
              else
                code_name = line[7..10].strip
              end
            end

            code_name+="  " if code_name.length==3

            if line[7]=='S'
              code_name = line[7..9].strip+"   "
            end

            if line[7..8]=='ST'
              code_name = line[7..10].strip+"  "
            end

            if line[7..8]=='XD'
              code_name = line[7..10].strip+"  "
            end


            if line[7..9]=='GQY'
              code_name = line[7..11].strip+' '
            end
            if line[7..9]=='TCL'
              code_name="TCL     "
            end

            code_name+=' ' if (fcode=='000011') or (fcode=='000017') or (fcode=='000018')
          else
            flag = line[7..9].strip.length
            if flag==1
              code_name = "#{line[7]}#{line[10]}#{line[11]}"+"  "
            else
              code_name = "#{line[7]}#{line[9]}#{line[11]}"+"  "
            end
          end

          code_name = "#{line[7]}#{line[12]}"+"    " if (fcode=='000528')
          
          
          ts = "#{fn},\'#{fcode.to_s}\',\'#{code_name.to_s}\',\'#{market.to_s}\'"
          #insert_data('name',ts)
          
          name_list.push(ts)

          #puts ts
          fn +=1
        end


        if (t=='/')  or (format_from_sina and (line[4] == '-')) #non blank line ,has data 

             if (not format_from_sina)
               have_data = true
              day=line[6..9]+'-'+line[0..1]+'-'+line[3..4]       

            
              td,open,high,low,close,volume,amount = line.split(/\t/)
        
              day_num = Time.new(line[6..9].to_i,line[0..1].to_i,line[3..4].to_i,0,0,0).to_date
            else

               #have_data = true
              
              day,open,high,close,low,volume,amount,dfq = line.split(/ /)
               day_num = Date.parse(day)

               if (day_num == last_weekly_day) 
                previous_qf = dfq
               end
              
               next if (day_num <= last_weekly_day) and (update_mode_flag) 

               if (day_num > last_weekly_day) and ((previous_qf != dfq)) and update_mode_flag
                  rec = Weekly_records.where(:code =>"000300").first
                  start_date = '2007-01-01' 
                  start_date = rec['date'].to_s if rec !=nil
                  fq_file.puts "#{fcode} #{start_date}"
                  p "#{fcode} need re-fuquan from #{start_date}."
                  next 
               end


               have_data = true

               #p line
               #p qf

              open = (((open.to_f/qf)*100).round)/100.0
               close = (((close.to_f/qf)*100).round)/100.0
                high = (((high.to_f/qf)*100).round)/100.0
                 low = (((low.to_f/qf)*100).round)/100.0
                 volume = volume.to_f
                   amount = amount.to_f
                 
                 #p day
              #day_num = Date.parse(day)

            end

            if first_record # first record, doing initializing job

              #start_day = day_num
              first_record = false

              week_t = day_num.cweek
              month_t  = day_num.month

              if (week_t != last_weekly_day.cweek) or (not update_mode_flag)
              
                #no special actions need to be taken down
                week_open = open.to_f
                week_high = high.to_f
                week_low = low.to_f
                week_close = close.to_f
                week_volume = volume.to_f
                week_amount = amount.to_f

                week_day = day
                month_day = day

                week = 1
                if update_mode_flag
                  rec = Weekly_records.where(:code =>"#{fcode}").last
                  if rec != nil
                    week = rec['week_num'].to_i + 1 
                  end
                end
                #p "update new week ,week = #{week}"
              else # update_mode and week_t==last_week_day.cweek

                 rec = Weekly_records.where(:code =>"#{fcode}").last

                 week_high = rec.high
                 week_low  = rec.low
                 week_high = high.to_f if rec.high < high.to_f
                 week_low = low.to_f if rec.low > low.to_f
                 week_close = close.to_f
                 week_open = rec.open
                 week_volume = rec.volume + volume.to_f
                 week_amount = rec.amount + amount.to_f

                 week_day = day
                 month_day = day

                 week = rec['week_num'].to_i 
                 #p "update in same week,week = #{week}"

                 need_update_week = true
                 update_week_id = rec.id

              end

            else 


              #puts "week_t : #{week_t}"
              #puts "cweek  : #{day_num.cweek}"

              if week_t != day_num.cweek # new week, save last week data , init new week data

                if need_update_week

                  rec = Weekly_records.where(:code =>"#{fcode}").last
                  rec.high = week_high
                  rec.low = week_low
                  rec.close = week_close
                  rec.volume = week_volume
                  rec.amount = week_amount
                  rec.date = week_day
                  #rec.new_high_date = week_day
                  #rec.new_low_date = week_day

                  rec.save

                  need_update_week = false
                else
                  ts = "#{wid},\'#{fcode.to_s}\',date(\'#{week_day}\'),#{week},#{week_open},#{week_high},#{week_low},#{week_close},#{week_volume},#{week_amount},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,date(\'#{week_day}\'),date(\'#{week_day}\')"
                  #puts ts
                  week_list.push(ts)
                  wid += 1
                end

                week_day = day

                week_open = open.to_f
                week_high = high.to_f
                week_low = low.to_f
                week_close = close.to_f
                week_volume = volume.to_f
                week_amount = amount.to_f

                week += 1
                week_t = day_num.cweek
              else
                 
                 
                 week_high = high.to_f if week_high < high.to_f
                 week_low = low.to_f if week_low > low.to_f
                 week_close = close.to_f
                 week_volume += volume.to_f
                 week_amount += amount.to_f

                 week_day = day
                 month_day = day
               end

          

              if month_t != day_num.month # new month save last month data , init new month data


                ts = "#{mid},\'#{fcode.to_s}\',date(\'#{month_day}\'),#{month},#{month_open},#{month_high},#{month_low},#{month_close},#{month_volume},#{month_amount},0,0,0,0,0,0,0"
                #puts ts
                month_list.push(ts)
                mid += 1

                month_day = day


                month_open = open.to_f
                month_high = high.to_f
                month_low = low.to_f
                month_close = close.to_f
                month_volume = volume.to_f
                month_amount = amount.to_f

                month += 1
                month_t = day_num.month
              else
                 month_high = high.to_f if month_high < high.to_f
                 month_low = low.to_f if month_low > low.to_f
                 month_close = close.to_f
                 month_volume += volume.to_f
                 month_amount += amount.to_f
               end


            end

          
          if import_daily_record 
            if amount.to_f!=0.0
              ts = "#{did},\'#{fcode.to_s}\',date(\'#{day}\'),#{open},#{high},#{low},#{close},#{volume},#{amount},#{week},#{month}"
              #puts ts
              line_list.push(ts)
              did += 1
            end
          end

        end

      end # each line
    end  # each do file

  if have_data # some blank file have no data
     insert_data('daily_records',line_list)  if import_daily_record and (not etf)

     ts = "#{wid},\'#{fcode.to_s}\',date(\'#{week_day}\'),#{week},#{week_open},#{week_high},#{week_low},#{week_close},#{week_volume},#{week_amount},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,date(\'#{week_day}\'),date(\'#{week_day}\')"
     #puts ts
     week_list.push(ts)
     wid += 1
     if etf
       insert_data('weekly_etf_records',week_list)
     else 
       insert_data('weekly_records',week_list)
     end

     ts = "#{mid},\'#{fcode.to_s}\',date(\'#{month_day}\'),#{month},#{month_open},#{month_high},#{month_low},#{month_close},#{month_volume},#{month_amount},0,0,0,0,0,0,0"
     #puts ts
     month_list.push(ts)
     mid += 1

     insert_data('monthly_records',month_list) if (not etf)
   end 

    #break
  end

  if etf
    insert_data('etf_name',name_list)
  else
    insert_data('name',name_list)
  end
   
  fq_file.close

  load_name_into_database if Names.last == nil 

end


def analysis_daily_records(dir,rate_min=5,rate_max=8,vol_rate = 50)

  #dr = Daily_records.new
  #first_time = true

  wid=1

  date_list = get_day_list_from_file(dir)

  #p date_list

  #return
  first_line = true
   
  Dir.glob("#{dir}\/*.txt").each do |afile|
      #puts "scanning file #{afile}..."

     

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

      sa_len=0

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
                h[:high] = high.to_f
                h[:volume] = volume.to_f
                h[:amount] = amount.to_f
                h[:stop_trade]=stop_trade_flag
                h[:ma5] = close.to_f
                h[:ma10] = close.to_f
                #if stop_trade_flag
                  #puts "#{day_num} not in trade"
                #end
                #counter +=1
                #h[:last_days]=0



                sa.push(h)
                sa_len +=1
              end

              last_day = day_num
            
          end

        end # each line
        #break
      end  # each do file

      #return

      #puts "come!"
    #first_line = true
    if have_data and (sa.length>2) # some blank file have no data
       len=sa.length

       sa.each_with_index do |h,i|
        if i>2
          old_price= sa[i-2][:price]
          price = sa[i-1][:price]
          roe = ((price - old_price)/old_price*100)

          old_vol= sa[i-2][:volume]
          vol = sa[i-1][:volume]
          vol_r = ((vol - old_vol)/old_vol*100)

          ma5=ma10=price

          
          if i>=5
            ma5 = (sa[i-4][:price]+sa[i-3][:price]+sa[i-2][:price]+sa[i-1][:price]+sa[i-5][:price])/5
          end

          if i>=10
            ma10 = (sa[i-9][:price]+sa[i-8][:price]+sa[i-7][:price]+sa[i-6][:price]+sa[i-5][:price]+sa[i-4][:price]+sa[i-3][:price]+sa[i-2][:price]+sa[i-1][:price]+sa[i-10][:price])/10
          end


          #if (roe>=rate_min) and (roe<=rate_max) and (vol_r > vol_rate)
          if (ma5>ma10) and (price > ma10) and (price<ma5) and (roe < 0)

            old_price= sa[i-1][:price]
            price = sa[i][:price]
            roe_c = ((price - old_price)/old_price*100)

            price = sa[i][:high]
            roe_h = ((price - old_price)/old_price*100)
            
            if first_line 
              puts  "name,date,month,week,close,high"
              first_line = false
            end

            puts "#{format_code(fcode)},#{sa[i][:date]},#{sa[i][:date].month+(sa[i][:date].year-2009)*12},#{sa[i][:date].cweek+(sa[i][:date].year-2009)*52},#{format_roe(roe_c)},#{format_roe(roe_h)}"

          end

        end
       end
       


     end # have data

      #break
   end #dir.glob

end # analysis_daily_recoreds







def print_help
    puts "This Tool is used to import data from stock software like ZhaoShangZhengquan"
    puts "-d dir        ---  Using given  dir as data store directory  "
    puts "-b            ---  import daily records, default only import weekly records and monthly records."
    puts "-g dir        ---  generating min_list for daily_records"
    puts "-c code least_days        ---  display minlist for code" 
    puts "-r dir        ---  analysis daily data for min list" 
    puts "-p least_days pri_day   ---  show lastest min list" 

    puts "-ppp code1 code2 ... coden   ---  show stock price from sina" 
    puts "-ppp2 TopN 0     ---  show topN performace stock from sina, sorting by 成交金额" 
    puts "-ppp2 TopN 10     ---  show topN performace stock from sina, sorting by 成交金额 升序" 
    puts "-ppp2 TopN 1     ---  show topN performace stock from sina, sorting by 成交量" 
    puts "-ppp2 TopN 11     ---  show topN performace stock from sina, sorting by 成交量 升序" 
    puts "-ppp2 TopN 6     ---  show topN performace stock from sina, sorting by 换手率" 
    puts "-ppp2 TopN 7     ---  show topN performace stock from sina, sorting by 换手率 升序" 
    puts "-ppp2 TopN 2     ---  show topN performace stock from sina, sorting by 涨幅" 
    puts "-ppp2 TopN 3     ---  show topN performace stock from sina, sorting by 跌幅" 
    puts "-ppp2 TopN 12     ---  show topN performace stock from sina, sorting by 流通市值" 
    puts "-ppp2 TopN 13     ---  show topN performace stock from sina, sorting by 流通市值 升序" 

    puts "-ppp2 TopN 4     ---  show topN performace stock from sina, sorting by amount,but ratio > 3 " 

    puts "-sb code --- 显示基本的股票股本数据"    

    puts "-h            ---  This help"    
end


dir = ""

import_daily_record = false
update_mode_flag = false

etf=false

if ARGV.length != 0
 
    ARGV.each do |ele|       
        if  ele == '-h'          
          print_help
          exit 
        end 
  
    if ele == '-d'
      dir = ARGV[ARGV.index(ele)+1]
      puts "Using directory : "+dir  
  
    end

    if ele == '-e'
      dir = ARGV[ARGV.index(ele)+1]
      puts "Using directory : "+dir  
      etf=true
    end


    if ele == '-b'
      import_daily_record = true
  
    end  

    if ele == '-u'
      update_mode_flag = true
  
    end  

    if ele == '-g'
      dir = ARGV[ARGV.index(ele)+1]
      generating_daily_minlist(dir,2)
      exit
   end  

   if ele == '-c'
    code = ARGV[ARGV.index(ele)+1].to_s
      least_days = ARGV[ARGV.index(ele)+2].to_i
      display_minlist_for_code(code,least_days)
      exit
   end  

    if ele == '-r'
      dir = ARGV[ARGV.index(ele)+1].to_s
      min = ARGV[ARGV.index(ele)+2].to_i
      max = ARGV[ARGV.index(ele)+3].to_i
      vol_rate = ARGV[ARGV.index(ele)+4].to_i
      #analyze_daily_minlist(dir)
      analysis_daily_records(dir,min,max,vol_rate)
      exit
   end  

  if ele == '-p'
      least_days = ARGV[ARGV.index(ele)+1].to_i
      pri_days = ARGV[ARGV.index(ele)+2].to_i
      show_last_daily_minlist2(1000,least_days,pri_days)
      exit
   end  

    if ele == '-t'
      num_of_records = ARGV[ARGV.index(ele)+1].to_i
      show_trade = ARGV[ARGV.index(ele)+2].to_i
       #puts code
     
      a=Asset.new
      run_class=Daily_records.new
      test_trade(a,run_class, num_of_records,show_trade)
      exit
   end  


  if ele == '-ppp'
      a_start = ARGV.index(ele)+1
      a_end   = ARGV.length-1
      codelist=ARGV[a_start..a_end] 
      ta=get_list_data_from_sina(codelist)
      ta.each {|cl| p cl}
      exit
   end  

    if ele == '-ppp2'
      topN = ARGV[ARGV.index(ele)+1].to_i
      sortby = ARGV[ARGV.index(ele)+2].to_i
      get_topN_from_sina(topN,sortby)
      exit
   end  

    if ele == '-ppp3'
      #a_start = ARGV.index(ele)+1
      #a_end   = ARGV.length-1
      #codelist=ARGV[a_start..a_end] 
      ta=get_data_from_sina('aapl')
      #ta.each {|cl| p cl}
      exit
   end

    if ele == '-ppp4'
      code = ARGV.index(ele)+1
      ta=get_history_data_from_nasdaq(code)
      exit
   end    

   if ele == '-sb'
      code = ARGV[ARGV.index(ele)+1]
      name, t = get_stockinfo_data_from_ntes(code)
      puts "#{name}(#{code}) 总股本=#{t[0]}亿股, 流通A股=#{t[1]}亿股, 限售A股=#{t[2]}亿股, B股=#{t[3]}亿股, H股=#{t[4]}亿股"
      exit
   end  

   if ele == '-sball'
      # code = ARGV[ARGV.index(ele)+1]
      # t = get_stockinfo_data_from_ntes(code)
      # puts "#{format_code(code)} 总股本=#{t[0]}亿股, 流通A股=#{t[1]}亿股, 限售A股=#{t[2]}亿股, B股=#{t[3]}亿股, H股=#{t[4]}亿股"
      # 加载股票信息到数据库
      ts_list = []
      fn = 1
      Names.get_code_list.each do |code|
        #puts code
        if (code == '000300') or (code[0..2] == '399' ) or (code[0..2] == '159' )
          next 
        end

        if (code[0] == '3') or (code[0] == '6') or (code[0] == '0')
          name,t = get_stockinfo_data_from_ntes(code)

          puts "loading #{name}(#{code}) 总股本=#{t[0]}亿股, 流通A股=#{t[1]}亿股, 限售A股=#{t[2]}亿股, B股=#{t[3]}亿股, H股=#{t[4]}亿股"

          market = 'SZ'
          market = 'SH' if code[0]=='6' 
          ts = "#{fn},\'#{code.to_s}\',\'#{name}\',\'#{market}\',\'#{t[0]}\',\'#{t[1]}\',\'#{t[2]}\',\'#{t[3]}\',\'#{t[4]}\'"

          ts_list.push(ts)
          
          fn += 1
        end
      end

      insert_data('stock_basic_info',ts_list) if ts_list.length!=0
      exit
   end  
   



   end
end

if ARGV.length == 0
  puts "Please give a data directory"
  puts "Usage :import -d [directory] "
  exit 
end

# main 
begin
  import_base_data(dir,import_daily_record,etf,update_mode_flag)
rescue => detail
   print "An error occurred: ",$!, "\n"
#if show_detail?
  puts detail.message
  print detail.backtrace.join("\n")
  puts
#end
end