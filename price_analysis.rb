#显示过去若干天，topN,roe>given_roe, 流通市值> given_free_mv,按照sortby_method排序的结果
def show_stock_price_change(days,topN=30,given_roe=10,gl_roe=0,sortby_method=0,all_data=true)
  load_name_into_database if Names.count != 0 
  #puts "#{days} #{topN} #{given_roe} #{gl_roe} #{sortby_method}"
  #
  end_date = Time.now.to_date
  
  date_list = Daily_records.new.get_date_list
  start_date = date_list.reverse.find {|date| date <= (end_date - days)}

  sortby_method = 0 if (sortby_method > 4) or (sortby_method < 0)
  sbs = ['按流通市值降序','按流通市值升序','按涨幅降序','按涨幅升序','按代码排序']

  if gl_roe == 0
    p "Show last #{days.to_s} days on #{start_date}, price change greater than #{given_roe.to_s}% , topN = #{topN} ，sortby = #{sbs[sortby_method]} "
   else
    p "Show last #{days.to_s} days on #{start_date}, price change little than #{given_roe.to_s}% , topN = #{topN} ，sortby = #{sbs[sortby_method]} "
  end


  sa=[]
  all = get_all_stock_price_from_sina(Names.get_code_list)
  all.delete_if {|h| h[:volume] == 0.0}

  rec = nil
  fr_list = Daily_records.where(date: "#{start_date.to_s}")
  all.each do |h|
    code = h[:code]
    rec = nil
    fr = fr_list.find {|rec| rec['code'] == code}
    if fr != nil
      rec = fr
    else
      if (all_data == true)
        #p "#{h[:code]}"
        print "."
        fr2_list = Daily_records.where(code: "#{code}")
        rec = fr2_list.reverse.find {|rec| rec['date'] <= start_date }
      end
    end
    
    #found
    if rec != nil
       roe = ( h[:close] - rec['close'])/rec['close']*100
       #p roe
      if gl_roe == 0
        if roe >= given_roe
          h[:new_roe] = roe
           h[:old_price] = rec['close']
           h[:old_date] = rec['date']
          sa.push(h)
        end
      else
        if roe <= -given_roe
          h[:new_roe] = roe
           h[:old_price] = rec['close']
           h[:old_date] = rec['date']
          sa.push(h)
        end
      end
    end

   #p "#{h[:code]}"

  end

  case sortby_method
    
    when 0
      sa.sort_by!{|h| h[:total_mv]}
      sa.reverse!
    when 1
      sa.sort_by!{|h| h[:total_mv]}
    when 2 
      sa.sort_by!{|h| h[:new_roe]}
      sa.reverse!
    when 3 
      sa.sort_by!{|h| h[:new_roe]}
    when 4 
      sa.sort_by!{|h| h[:code]}
    else
      p "unknown sort method #{sortby_method}"
  end
    
  return if sa.length == 0

  topN = sa.length - 1 if topN > (sa.length - 1 )
  
  puts
  sa[0..topN].each do |h|
     puts "#{format_code(h[:code])} #{format_price(h[:close])}, 涨幅=#{format_roe(h[:new_roe])}, on #{(h[:old_date])} at #{format_price(h[:old_price])}, 流通市值=#{format_price(h[:total_mv])}亿 " 
  end

  ave_ratio = (sa[0..topN].collect{|h| h[:new_roe]}.inject(:+)/topN*100).to_i/100.0
  puts "总共#{topN}支股票 平均涨幅 = #{ave_ratio}% on #{Time.now.strftime("%y-%m-%d %H:%M:%S")}"
  
  

end # of show_stock_price_change

#分析给定目录下的所有股票日数据
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