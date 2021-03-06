$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
 
require "shared_setup"
require "common"
require 'time'
require 'min_list'
require 'asset'
require 'simrun'
require 'basic_value_analysis'
require 'price_analysis'


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
       insert_data('weekly_records',week_list) #if not import_daily_record
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


def print_help
    puts "This Tool is used to import data from stock software like ZhaoShangZhengquan"
    puts "-d dir        ---  Using given  dir as data store directory  "
    puts "-b            ---  import daily records, default only import weekly records and monthly records."
    #puts "-g dir        ---  generating min_list for daily_records"
    #puts "-c code least_days        ---  display minlist for code" 
    #puts "-r dir        ---  analysis daily data for min list" 
    #puts "-p least_days pri_day   ---  show lastest min list" 
    puts
    puts "-ppp code1 code2 ... coden   ---  show stock price from sina" 
    puts "-ppp2 TopN 0 ---  show topN performace stock from sina, sorting by 成交金额" 
    puts "-ppp2 TopN 1 ---  show topN performace stock from sina, sorting by 成交金额 升序" 
    puts "-ppp2 TopN 2 ---  show topN performace stock from sina, sorting by 成交量" 
    puts "-ppp2 TopN 3 ---  show topN performace stock from sina, sorting by 成交量 升序" 
    puts "-ppp2 TopN 4 ---  show topN performace stock from sina, sorting by 换手率" 
    puts "-ppp2 TopN 5 ---  show topN performace stock from sina, sorting by 换手率 升序" 
    puts "-ppp2 TopN 6 ---  show topN performace stock from sina, sorting by 涨幅" 
    puts "-ppp2 TopN 7 ---  show topN performace stock from sina, sorting by 跌幅" 
    puts "-ppp2 TopN 8 ---  show topN performace stock from sina, sorting by 流通市值" 
    puts "-ppp2 TopN 9 ---  show topN performace stock from sina, sorting by 流通市值 升序" 

    puts "-ppp2 TopN 13 ratio ---  show topN performace stock from sina, sorting by 换手率 升序, 涨幅大于ratio%" 
    puts "-ppp2 TopN 14 ratio ---  show topN performace stock from sina, sorting by 流通市值, 跌幅大于ratio%" 
    puts "-ppp2 TopN 15 ratio ---  show topN performace stock from sina, sorting by 成交额, 跌幅大于ratio%" 
    puts "-ppp2 TopN 16 ratio ---  show topN performace stock from sina, sorting by 成交额, 涨幅大于ratio%" 
    puts "-ppp2 TopN 17 ratio ---  show topN performace stock from sina, sorting by 流通市值，涨幅大于ratio%" 
    puts "-ppp2 TopN 18 ratio ---  show topN performace stock from sina, sorting by 流通市值 升序，涨幅大于ratio" 
    puts "-ppp2 TopN 19 ratio ---  show topN performace stock from sina, sorting by 换手率，涨幅大于ratio" 

    puts "-ttp  days topN roe gl sortby --- 过滤器，显示过去若干天，topN，收益率大于roe 按照流通值排序的结果"    
    puts "-ttpq days topN roe gl sortby --- 过滤器，显示过去若干天，topN，收益率大于roe 按照流通值排序的结果,简单模式"    
    puts "-ttq  topN mode[10-16] roe    --- 过滤器，显示过去3个月 ，topN，收益率大于roe 按照流通值排序的结果,简单模式"    



    puts
    puts "-sb  [code]       --- 显示基本的股票股本数据" 
    puts "-sball            --- 下载A股股权数据到数据库" 
    puts "-sbhkall          --- 下载港股股权数据" 
    puts "-loadfile [filename] [tablename] --- 装载文件到数据表"  
    puts "-gcl [filename] [section]        --- 下载全部A股交易代码  [agu bgu etf cyb all]"  
    puts "-gcl_hk [filename]               --- 下载全部港股交易代码 "   
    puts "-gcl_us [filename]               --- 下载全部美股交易代码  "   
    puts "-apd [filename] [index_code]     --- 添加指数代码到下载的股票名称文件中"   

    puts
    puts "-sidx             --- 显示指数数据"   
    puts "-sfc              --- 显示投资机会"  
    puts "-stc [filename]   --- 显示指定文件的跟踪情况"   
    puts "-scc [code]       --- 显示指定股票的跟踪情况"   
    puts "-mon [force_flag] --- 下载每日交易数据"   
    puts "-ana ［filename］ [offset] [roe]  --- 分析每日自动下载的数据，给出过去offset天，股价变化大于roe的列表" 

    puts "-ddus ［dir］ [offset] [limit] --- 从nasdaq网站下载美股交易数据到指定目录 offset = 1m 3m 6m 1y 18m 2y 5y"  
    puts "-ddhk ［dir］ [offset] [limit]  --- 从sina网站下载港股交易数据指定目录 offset = days"  
    puts "-dload［dir］[market] [offset] [limit] --- 下载港股美股历史数据[上面两个命令的合并版本] market = us/hk/etf offset = days"  
    puts "-update [dir]     --- 更新指定目录下的港股 美股数据到最新日期"  
    puts "-usa ［dir］ [topN] [mode] [roe]           --- 分析指定目录下载的数据，给出统计信息"   
    puts "-ofa ［dir］ [topN] [offset] [roe] [mode]  --- 分析指定目录下载的数据，计算offset的roe mode = 0,1,2 11,12"   
      
     
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
       exit
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

     if ele == '-ths'

      clear_table('name')
      load_name_into_database('name.txt') if Names.count == 0 

       ts_list = []

      
      fn = 1
      fnm = 1
      
       File.open('name.txt') do |file|
            file.each_line do |line|
              na = line.split('|')
              code = na[1].strip
              name = na[2].strip
              market = na[3].strip

        #puts code
        if (code == '000300') #or (code[0..2] == '399' ) or (code[0..2] == '159' ) or (code[0..1] == '03' )
          next 
        end

        # if (code[0] == '3') or (code[0] == '6') or (code[0] == '0')
        # 
        #puts code

          begin
            arr = get_history_data_from_ths(code)
          rescue
            begin
              arr = get_history_data_from_ths(code)
            rescue
              begin
                arr = get_history_data_from_ths(code)
              rescue
                next
              end
            end
          end


          #next if name == nil

          puts "#{code} #{name} total #{arr.size} weekly records"

          week = 1 
          ts_list = []
          arr.each do |h|
            ts = "#{fn},\'#{code.to_s}\',date(\'#{trans_date(h[:date])}\'),#{week},#{h[:open]},#{h[:high]},#{h[:low]},#{h[:close]},#{h[:volume]},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,date(\'#{trans_date(h[:date])}\'),date(\'#{trans_date(h[:date])}\')"
            ts_list.push(ts)
            
            fn += 1
            week += 1 
          end
          insert_data('weekly_records',ts_list) if ts_list.length!=0

           # now for month
           begin
            arr = get_history_data_from_ths(code,'month')
          rescue
            begin
              arr = get_history_data_from_ths(code,'month')
            rescue
              begin
                arr = get_history_data_from_ths(code,'month')
              rescue
                next
              end
            end
          end


          #next if name == nil

          puts "#{code} #{name} total #{arr.size} month records"

          month = 1 
          ts_list = []
          arr.each do |h|
            ts = "#{fnm},\'#{code.to_s}\',date(\'#{trans_date(h[:date])}\'),#{month},#{h[:open]},#{h[:high]},#{h[:low]},#{h[:close]},#{h[:volume]},0,0,0,0,0,0,0,0"
            
            ts_list.push(ts)
            
            fnm += 1
            month += 1 
          end
          insert_data('monthly_records',ts_list) if ts_list.length!=0

        end #line
      end # file

      #insert_data('weekly_records',ts_list) if ts_list.length!=0

     
       exit
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
      given_ratio = ARGV[ARGV.index(ele)+3].to_i
      given_ratio = 3 if 0 == given_ratio 
      get_topN_from_sina(topN,sortby,given_ratio)
      exit
   end  
 

    if ele == '-ppp3'
      topN = ARGV[ARGV.index(ele)+1].to_i
      sortby = ARGV[ARGV.index(ele)+2].to_i
      given_ratio = ARGV[ARGV.index(ele)+3].to_i
      given_ratio = 3 if 0 == given_ratio 
      get_topN_from_sina(topN,sortby,given_ratio,:hk)
      exit
   end  

    if ele == '-ppp4'
      topN = ARGV[ARGV.index(ele)+1].to_i
      sortby = ARGV[ARGV.index(ele)+2].to_i
      given_ratio = ARGV[ARGV.index(ele)+3].to_i
      given_ratio = 3 if 0 == given_ratio 
      get_topN_from_sina(topN,sortby,given_ratio,:us)
      exit
   end  

    if ele == '-ppp5'
      topN = ARGV[ARGV.index(ele)+1].to_i
      sortby = ARGV[ARGV.index(ele)+2].to_i
      given_ratio = ARGV[ARGV.index(ele)+3].to_i
      given_ratio = 3 if 0 == given_ratio 
      get_topN_from_sina(topN,sortby,given_ratio,:us_etf)
      exit
   end  

    if ele == '-ppp12'
       filename = ARGV[ARGV.index(ele)+1]
      
       begin
       File.open(filename, "r+") do |file|
        get_topN_from_sina(10000,8,3,:china,file)
       end
       rescue
         File.open(filename, "w") do |file|
         get_topN_from_sina(10000,8,3,:china,file)
        end
       end
      exit
   end 
    if ele == '-ppp13'
       filename = ARGV[ARGV.index(ele)+1]
      
      begin
       File.open(filename, "r+") do |file|
        get_topN_from_sina(10000,8,3,:hk,file)
      end
      rescue
         File.open(filename, "w") do |file|
        get_topN_from_sina(10000,8,3,:hk,file)
      end
      end
      exit
   end 
   if ele == '-ppp14'
       filename = ARGV[ARGV.index(ele)+1]
      
       begin
       File.open(filename, "r+") do |file|
        get_topN_from_sina(10000,8,3,:us,file)
      end
    rescue
       File.open(filename, "w") do |file|
        get_topN_from_sina(10000,8,3,:us,file)
      end
    end
      exit
   end  
   if ele == '-ppp15'
       filename = ARGV[ARGV.index(ele)+1]
      
       begin
       File.open(filename, "r+") do |file|
        get_topN_from_sina(10000,0,3,:us_etf,file)
      end
    rescue
       File.open(filename, "w") do |file|
        get_topN_from_sina(10000,0,3,:us_etf,file)
      end

    end
      exit
   end   

   #  if ele == '-ppp3'
   #    #a_start = ARGV.index(ele)+1
   #    #a_end   = ARGV.length-1
   #    #codelist=ARGV[a_start..a_end] 
   #    ta=get_data_from_sina('aapl')
   #    #ta.each {|cl| p cl}
   #    exit
   # end

    if ele == '-ppp6'
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

      if (Stock_Basic_Info.count == 0)
        fn = 1
      else
        fn = Stock_Basic_Info.last.id + 1
      end

     # Names.get_code_list.each do |code|

    File.open('name.txt') do |file|
            file.each_line do |line|
              na = line.split('|')
              code = na[1].strip

        #puts code
        if (code == '000300') or (code[0..2] == '399' ) or (code[0..2] == '159' ) or (code[0..1] == '03' )
          next 
        end

        # if (code[0] == '3') or (code[0] == '6') or (code[0] == '0')
        # 
        #puts code

          name,t = get_stockinfo_data_from_ntes(code)

          next if name == nil

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

   if ele == '-sbhkall'
      # code = ARGV[ARGV.index(ele)+1]
      # t = get_stockinfo_data_from_ntes(code)
      # puts "#{format_code(code)} 总股本=#{t[0]}亿股, 流通A股=#{t[1]}亿股, 限售A股=#{t[2]}亿股, B股=#{t[3]}亿股, H股=#{t[4]}亿股"
      # 加载股票信息到数据库
      ts_list = []
      if (Stock_Basic_Info.count == 0)
        fn = 1
      else
        fn = Stock_Basic_Info.last.id + 1
      end
    
       #cl = []
       File.open('hk_name.txt') do |file|
            file.each_line do |line|
              na = line.split('|')
              code = na[1].strip
        
              name,t = get_stockinfo_data_from_sina(code)

              if t>0

                  puts "loading #{name}(#{code}) 总股本=#{t}股"
                  market = 'HK'
                  ts = "#{fn},\'#{code.to_s}\',\'#{name}\',\'#{market}\',\'#{t}\',\'#{t}\',\'#{t}\',\'#{t}\',\'#{t}\'"
                  ts_list.push(ts)  
                  fn += 1
                end

                #break

            end
       end
       #puts "total #{cl.length} stocks"

      insert_data('stock_basic_info',ts_list) if ts_list.length!=0
      exit
   end  

   if ele == '-loadfile'
      filename = ARGV[ARGV.index(ele)+1]
      table = ARGV[ARGV.index(ele)+2]
      
      ts_list = []

      if (Stock_Basic_Info.count == 0)
        fn = 1
      else
        fn = Stock_Basic_Info.last.id + 1
      end
    
       #cl = []
       File.open(filename) do |file|
            file.each_line do |line|
              #puts line
              na = line.split('|')
              len = na.length
                   ts = na[1..len-1].inject("#{fn},") {|res,x| res << "\'#{x.to_s}\',"}
                   ts = ts[0..(ts.length-2)]
                   #puts ts
                  ts_list.push(ts)  
                  fn += 1
              
                #break

            end
       end
       #puts "total #{cl.length} stocks"

      insert_data(table,ts_list) if ts_list.length!=0
      exit
   end  

    if ele == '-apd' 
      filename = ARGV[ARGV.index(ele)+1]  
      filename = 'name.txt' if filename == nil
      index_code = ARGV[ARGV.index(ele)+2]
      append_index_to_codefile(filename,index_code)
      exit
    end

    if ele == '-gcl_us' 
      
      fetch_flag = ARGV[ARGV.index(ele)+1]  
      if fetch_flag != nil
        fetch_file_from_nasdaq
      end

      generate_stock_and_etf_file()
      exit
   end



    if ele == '-gcl_hk' 
      
      #filename = 'name_all.txt'
      filename = ARGV[ARGV.index(ele)+1]  
      filename = 'hk_name.txt' if filename == nil

      fetch_all_code_list_hk(filename)
      exit
   end

    if ele == '-gcl' 
      
      #filename = 'name_all.txt'
      filename = ARGV[ARGV.index(ele)+1]  
      filename = 'name_all.txt' if filename == nil
      flag = ARGV[ARGV.index(ele)+2]

      if flag == nil 
        File.open(filename, "w") do |file|
           fetch_all_code_list(file,:agu)
        end
      else
          File.open(filename, "w") do |file|
           fetch_all_code_list(file,flag.to_sym)
          end
      end

      if  (flag == nil) or  (flag.to_sym == :agu ) 
       append_index_to_codefile(filename , '000300')
       append_index_to_codefile(filename , '399905')
       append_index_to_codefile(filename , '159915')
       append_index_to_codefile(filename , '159919')
      end

     exit
    end 

    if ele == '-fhy' 
      
      #filename = 'name_all.txt'
      filename = ARGV[ARGV.index(ele)+1]  
      filename = 'classify.txt' if filename == nil
      #flag = ARGV[ARGV.index(ele)+2]

      
        File.open(filename, "w") do |file|
           fetch_all_hy(file)
        end
      

     exit
    end 

   if ele == '-ttp' 
     days = ARGV[ARGV.index(ele)+1].to_i
     topN = ARGV[ARGV.index(ele)+2].to_i
     roe_diff = ARGV[ARGV.index(ele)+3].to_i
     gl_roe = ARGV[ARGV.index(ele)+4].to_i
     sortby_mv = ARGV[ARGV.index(ele)+5].to_i

     #p "Show last #{days.to_s} days, price change over #{roe_diff.to_s}% , topN = #{topN} "

     show_stock_price_change(days,topN,roe_diff,gl_roe,sortby_mv)

     exit
    end 

    if ele == '-ttpq' 
     days = ARGV[ARGV.index(ele)+1].to_i
     topN = ARGV[ARGV.index(ele)+2].to_i
     roe_diff = ARGV[ARGV.index(ele)+3].to_i
     gl_roe = ARGV[ARGV.index(ele)+4].to_i
     sortby_mv = ARGV[ARGV.index(ele)+5].to_i

     #p "Show last #{days.to_s} days, price change over #{roe_diff.to_s}% , topN = #{topN} "

     show_stock_price_change(days,topN,roe_diff,gl_roe,sortby_mv,false)

     exit
    end 

     if ele == '-usa' 
    
     dir  = ARGV[ARGV.index(ele)+1]
     topN = ARGV[ARGV.index(ele)+2].to_i
     mode = ARGV[ARGV.index(ele)+3].to_i
     #offset  = ARGV[ARGV.index(ele)+4].to_i
     roe  = ARGV[ARGV.index(ele)+4].to_i
     
     show_us_stock_analysis(dir,topN,mode,roe)
    

     exit
    end 

    if ele == '-ttq' 
    
     topN = ARGV[ARGV.index(ele)+1].to_i
     mode = ARGV[ARGV.index(ele)+2].to_i
     roe  = ARGV[ARGV.index(ele)+3].to_i
     final  = ARGV[ARGV.index(ele)+4].to_i
     
     if final == 0
      show_stock_statiscs(topN,mode,roe,:quick)
     else
      show_stock_statiscs(topN,mode,roe,:comp)
     end

     exit
    end 


   if ele == '-sidx'   
     show_globl_index
     exit
    end 

   if ele == '-sfc'   
     scan_for_chance
     exit
    end 


   if ele == '-stc'   
     fname = ARGV[ARGV.index(ele)+1]
     check_track_list(fname)
     exit
    end 

    if ele == '-ctl'   
     #fname = ARGV[ARGV.index(ele)+1]
     check_stock_list
     exit
    end 

    if ele == '-ana'   
     fname = ARGV[ARGV.index(ele)+1]
     offset = ARGV[ARGV.index(ele)+2].to_i
     roe = ARGV[ARGV.index(ele)+3].to_i
     analysis_stock_log_data(fname,offset,roe)
     exit
    end 


    if ele == '-ofa'   
     dir = ARGV[ARGV.index(ele)+1]
     topN = ARGV[ARGV.index(ele)+2].to_i
     offset = ARGV[ARGV.index(ele)+3].to_i
     roe = ARGV[ARGV.index(ele)+4].to_i
     mode = ARGV[ARGV.index(ele)+5].to_i
     show_offset_stock_analysis(dir,topN,offset,roe,mode)
     exit
    end 

    

    if ele == '-ddus'   
     dir = ARGV[ARGV.index(ele)+1]
     offset = ARGV[ARGV.index(ele)+2]
     limit = ARGV[ARGV.index(ele)+3].to_i
     limit = 10 if limit == nil
    
     download_us_data(dir,offset,limit)
     exit
    end 

  if ele == '-ddhk'   
     dir = ARGV[ARGV.index(ele)+1]
     offset = ARGV[ARGV.index(ele)+2].to_i
     limit = ARGV[ARGV.index(ele)+3].to_i
     limit = 10 if limit == nil
    
     download_hk_data(dir,offset,limit)
     exit
    end 

    if ele == '-dload'   
     dir = ARGV[ARGV.index(ele)+1]
     market = ARGV[ARGV.index(ele)+2]
     offset = ARGV[ARGV.index(ele)+3].to_i
     limit = ARGV[ARGV.index(ele)+4].to_i
     limit = 10 if limit == 0
    
     download_oversea_data(dir,market.to_sym, offset,limit)
     exit
    end 

    if ele == '-update'   
     dir = ARGV[ARGV.index(ele)+1]
     
     update_oversea_data(dir)
     exit
    end 

    if ele == '-scc'   
     code = ARGV[ARGV.index(ele)+1]

     years = ARGV[ARGV.index(ele)+2].to_i
     years = 20 if years == 0
 
     evalate_equity(code)
     puts
     show_roe_list(code,years)
     exit
    end 

     #just for a test function
    if ele == '-ccc'   
     puts "Fetching China A stock daily records..."
           File.open('cc.csv', "r+") do |file|
             get_topN_from_sina(10000,8,3,:china,file)
           end
     exit
    end 


    if ele == '-mon'  

      force_flag = false
      xx = ARGV[ARGV.index(ele)+1].to_i
      force_flag = true if xx == 1


      reset_flag1 = false
      reset_flag2 = false
      old_wday = 0

      
      while (true)

        t = Time.now.gmtime

        date = t.getlocal.to_date

        t2 = Time.new(date.year,date.month,date.day,17,0,0,"+08:00").gmtime
        t3 = Time.new(date.year,date.month,date.day,7,0,0,"+08:00").gmtime

        puts t.getlocal.to_s
        #puts t2.getlocal.to_s
        #puts t3.getlocal.to_s
 
        if (t.getlocal.wday != old_wday)
          reset_flag1 = false
          reset_flag2 = false
          old_wday = t.getlocal.wday 
        end


        if force_flag  or ((t.getlocal.wday >=1) and (t.getlocal.wday <=5) and  (t> t2 ) and (not reset_flag1))

           puts "Fetching China A stock daily records..."
           File.open('cn.csv', "r+") do |file|
             get_topN_from_sina(10000,8,3,:china,file)
           end
           
           puts
           puts "Fetching HONGKONG stock daily records..."
           File.open('hk.csv', "r+") do |file|
            get_topN_from_sina(10000,8,3,:hk,file)
           end

           reset_flag1 = true 
         
       end

         if force_flag  or ((t.getlocal.wday >=2) and (t.getlocal.wday <=6) and  (t> t3 ) and (not reset_flag2))
           puts
           puts "Fetching US stock daily records..."
           File.open('us.csv', "r+") do |file|
            get_topN_from_sina(3000,8,3,:us,file)
           end 

           puts
           puts "Fetching US ETF daily records..."
           File.open('us_etf.csv', "r+") do |file|
            get_topN_from_sina(10000,0,3,:us_etf,file)
           end 

            reset_flag2 = true 
         end

        force_flag = false
        sleep(60)
      end

     exit
    end 
   



   end
end

#if ARGV.length == 0
#  puts "Please give a data directory"
#  puts "Usage :import -d [directory] "
#  exit 
#end

print_help