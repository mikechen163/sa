#显示过去若干天，topN,roe>given_roe, 流通市值> given_free_mv,按照sortby_method排序的结果
def show_stock_price_change(days,topN=30,given_roe=10,gl_roe=0,sortby_method=0,all_data=true)
  load_name_into_database if Names.count == 0 
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
  
  rec = nil
  fr_list = Daily_records.select("code, date, close").where(date: "#{start_date.to_s}")

  #puts fr_list.class
  #puts fr_list[0]['close']

  hr = Hash.new
  fr_list.to_a.each do |rec|
    code = rec['code'] 
    #puts "#{format_code(code)}  #{rec['close']}"
    hr[code] = rec
  end

  all = get_all_stock_price_from_sina(Names.get_code_list)
  all.delete_if {|h| h[:volume] == 0.0}

  all.each do |h|
    code = h[:code]
    rec = nil
    #fr = fr_list.find {|rec| rec['code'] == code}
    fr = hr[code]
    if fr != nil
      rec = fr
    else
      if (all_data == true)
        #p "#{h[:code]}"
        print "."
        #fr2_list = Weekly_records.where(code: "#{code}")
        rec = Weekly_records.select("date, close").where( "date <= '#{start_date}' and code = '#{code}'").last
        #date_list = fr2_list.collect{|rec| rec['date']}
        #ind = date_list.find_index {|date| date <= start_date}
        #rec = fr2_list[ind] if ind != nil
        #rec = fr2_list.reverse.find {|rec| rec['date'] <= start_date }
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
  
  return  sa 

end # of show_stock_price_change

def get_hash_for_date(start_date)
  fr_list = Daily_records.select("code, close").where(date: "#{start_date.to_s}")

  hr = Hash.new
  fr_list.to_a.each do |rec|
    code = rec['code'] 
    hr[code] = rec['close']
  end

  return hr
end

def get_hr_roe(code,price,h,start_date,final)
  if h[code] == nil
    return 0.0 if final == :quick
    rec = Weekly_records.select("close").where( "date <= '#{start_date}' and code = '#{code}'").last
    return 0.0 if rec == nil
    close = rec['close'] 
    roe = ( price - close)/close*100
    return roe
  end

  roe = ( price - h[code])/h[code]*100
  return roe
end


def get_stock_basic_info
  h=Hash.new

  File.open('basicinfo.txt') do |file|
    file.each_line do |line|
       na = line.split ','
       code = na[0].strip
       if h[code] == nil
         h[code] = na
       else
         if na[2] > h[code][2] 
           h[code] = na
         end
       end
    end
  end
  return h
end


def show_us_stock_analysis(dir,topN,mode,roe)
  #puts "#{dir}"
  # 
  beta_hash = get_hash_for_us
  h_us = get_last_record_from_monitor(:us)
  h_hk = get_last_record_from_monitor(:hk)
  h_cn = get_last_record_from_monitor(:cn)

  #basicinfo = get_stock_basic_info

  ta = []
  filecount = 1
  hkstock = false

  market = :us 
  Dir.glob("#{dir}\/*.*").each do |afile|
     
    puts "processing #{filecount} files ..." if filecount % 500 == 0
    filecount += 1
    File.open(afile) do |file|
       #lineno = 1
       line = file.gets

       #first_date = 

       h =Hash.new
       na = line.split(',')

       if na.size > 1 

         code = h[:code] = na[0]

         market = :us
         market = :hk if h[:code][0..1] == 'hk'
         market = :cn if (h[:code][0..1] == 'sh') and  (h[:code][0..1] == 'sz')
       else
         market = :cn 
         na = line.split(' ')
         if na[0][0] == '6'
           code = "sh" + na[0]
         else
           code = "sz" + na[0]
         end

       end

       case market
         when :hk

         na = h_hk[code] if h_hk[code] != nil

         h[:close] = na[6].to_f
         h[:ratio] = na[8].to_f
         h[:high52w] = na[15].to_f
         h[:low52w] = na[16].to_f
         h[:date] = Date.parse(na[19])
         #h[:beta] = na[17].to_f # because after 2017-08-04, sina doesn't return beta for stock
         h[:beta] = 0.0
         h[:pe] = na[13].to_f
         h[:total_mv] = na[17].to_f * 100000000
         h[:name] = na[1]

         #next if h[:total_mv] < 500000000
         #h[:name] = na[1]
         #puts "#{h[:code]} #{h[:name]} #{h[:date]} #{h[:beta]} "
         #
         
         # if basicinfo[code] != nil
         #   h[:close] = basicinfo[code][3].to_f
         #   h[:ratio] = basicinfo[code][4].to_f
         #   h[:date]  = Date.parse(basicinfo[code][2])
         #  # h[:beta] = basicinfo[code][6].to_f
         #  # h[:pe]   = basicinfo[code][7].to_f
         #  # h[:eps]  = basicinfo[code][8].to_f
         #   mv = basicinfo[code][5]
         #   xx = mv[-1]
         #   mv = mv.to_f
         #   case xx
         #     when 'T'
         #      h[:total_mv] = mv*10000
         #     when 'B'
         #      h[:total_mv] = mv*10
         #     when 'M'
         #      h[:total_mv] = mv/100.0
         #     else
         #      h[:total_mv] = 0.0
         #   end
         # end
         
         
       when :us

         #puts code
         #puts h_us[code]

         na = h_us[code] if h_us[code] != nil
      
         h[:close] = na[2].to_f
         h[:ratio] = na[3].to_f
         h[:high52w] = na[8].to_f
         h[:low52w] = na[9].to_f
         h[:date] = Date.parse(na[19])
         #h[:beta] = na[17].to_f # because after 2017-08-04, sina doesn't return beta for stock
         h[:beta] = beta_hash[h[:code].to_sym]
         h[:beta] = 0.0 if h[:beta] == nil
         h[:pe] = na[16].to_f
         h[:total_mv] = na[13].to_f
         h[:name] = na[1]
         #next if h[:total_mv] < 500000000
         #h[:name] = na[1]
         #puts "#{h[:code]} #{h[:name]} #{h[:date]} #{h[:beta]} "
       when :cn
         na = h_cn[code] #if h_cn[code] != nil
         if na != nil

           h[:code] = code[2..-1]
           h[:close] = na[5].to_f
           h[:ratio] = na[11].to_f
           h[:high52w] = 0.0
           h[:low52w] = 0.0
           h[:date] = Date.parse(na[12])
           #h[:beta] = na[17].to_f # because after 2017-08-04, sina doesn't return beta for stock
           h[:beta] = 0.0
           h[:pe] = 0.0
           h[:total_mv] = na[9].to_f * 100000000
           h[:name] = na[1]
         else
           puts "no daily records for #{code}"
           next if code == 'sz000300' 
           next if code[0..4] == 'sz159' 
           next if code[0..4] == 'sz399' 

           #puts [code[2..-1]]
           h = get_list_data_from_sina([code[2..-1]])[0]
           #puts h.to_s
           h[:total_mv] = h[:total_mv] * 100000000 
           h[:date] = Date.parse h[:date]
           #puts h.to_s
         end

         line = file.gets 
         #puts line[0..9]
         line = file.gets  while line[0..1] != '20'
         #puts line

       else
         puts "unknown market #{market.to_s}"
       end

        #h[:name] = na[1]

       d1y = h[:date] - 360
       d6m = h[:date] - 180
       d3m = h[:date] - 90
       d1m = h[:date] - 30
       
       #lineno += 1
       d1y_flag = false
       d6m_flag = false
       d3m_flag = false
       d1m_flag = false

       h[:r1y] = h[:r6m] = h[:r3m] = h[:r1m] = 0.0   

       #puts code
       file.each_line do |line|
        
         #puts line
         na = line.split(' ')
         nd = Date.parse(na[0])
    
         na[4] = na[4].to_f/na[-1].to_f if market == :cn
         if (not d1y_flag) and (nd >= d1y)
           d1y_flag = true
           h[:r1y] = - (na[4].to_f - h[:close])/na[4].to_f * 100 if na[4].to_f > 0.0 
         end

         if (not d6m_flag) and (nd >= d6m)
           d6m_flag = true
            h[:r6m] = - (na[4].to_f - h[:close])/na[4].to_f * 100 if na[4].to_f > 0.0
         end

         if (not d3m_flag) and (nd >= d3m)
           d3m_flag = true
            h[:r3m] = - (na[4].to_f - h[:close])/na[4].to_f * 100 if na[4].to_f > 0.0
         end

         if (not d1m_flag) and (nd >= d1m)
           d1m_flag = true
           h[:r1m] = - (na[4].to_f - h[:close])/na[4].to_f * 100 if na[4].to_f > 0.0
         end         
       end # of each_line
      
       ta.push(h)

    end
  end

  ta.sort_by!{|h| h[:total_mv]}
  ta.reverse!

  case mode
    
    when 0
    when 1
      ta.delete_if {|h| h[:r1y] <= roe}
    when 2
      ta.delete_if {|h| h[:r6m] <= roe}
    when 3
      ta.delete_if {|h| h[:r3m] <= roe}
    when 4
      ta.delete_if {|h| h[:r1m] <= roe}
     

    when 11
      ta.delete_if {|h|  h[:r1y] > roe}
    when 12
      ta.delete_if {|h| h[:r6m] > roe}
    when 13
      ta.delete_if {|h|  h[:r3m] > roe}
    when 14
      ta.delete_if {|h| h[:r1m] > roe}
    else
      puts "mode 0 : sorting by 流通市值"
      puts "mode 1 : sorting by 一年涨幅大于#{roe}%"
      puts "mode 2 : sorting by 6个月涨幅大于#{roe}%"
      puts "mode 3 : sorting by 3个月涨幅大于#{roe}%"
      puts "mode 4 : sorting by 1个月涨幅大于#{roe}%"

      puts "mode 11 : sorting by 一年涨幅小于#{roe}%"
      puts "mode 12 : sorting by 6个月涨幅小于#{roe}%"
      puts "mode 13 : sorting by 3个月涨幅小于#{roe}%"
      puts "mode 14 : sorting by 1个月涨幅小于#{roe}%"
    
  end

  topN = ta.length  if topN > ta.length 

  if market == :cn
    puts "-------------------------------------------------------------------------------------------------------------"
    puts "TICK     名称               价格   涨跌幅  一年   六个月  三个月  一个月 流通市值"
    puts "-------------------------------------------------------------------------------------------------------------"

  else
    puts "-------------------------------------------------------------------------------------------------------------"
    puts "TICK     名称               价格   涨跌幅  PE   beta    一年   六个月  三个月  一个月 流通市值  high52w low52w"
    puts "-------------------------------------------------------------------------------------------------------------"
  end
  ta[0..(topN - 1)].each do |h|
     #nv = h[:total_mv]
     nv = (h[:total_mv]/100000000*100 ).to_i/100.0 #if not hkstock

    #puts h.to_s
     if market == :cn
       puts "#{normalize_name(h[:code],8)} #{normalize_name(h[:name],16)} #{format_price(h[:close])} #{format_roe(h[:ratio])} \
#{format_roe(h[:r1y])} #{format_roe(h[:r6m])} #{format_roe(h[:r3m])} #{format_roe(h[:r1m])}\
 #{format_price(nv)}亿"
     else
       puts "#{normalize_name(h[:code],8)} #{normalize_name(h[:name],16)} #{format_price(h[:close])} #{format_roe(h[:ratio])} \
#{format_price(h[:pe])}#{format_price(h[:beta])} #{format_roe(h[:r1y])} #{format_roe(h[:r6m])} #{format_roe(h[:r3m])} #{format_roe(h[:r1m])}\
 #{format_price(nv)}亿  #{format_price(h[:high52w])} #{format_price(h[:low52w])}"
    end
  end
  puts "total #{topN} records"

end # func

#
def show_offset_stock_analysis(dir,topN,offset,roe,mode = 1)
  #puts "#{dir}"
  # 
  #beta_hash = get_hash_for_us

  ta = []
  filecount = 1
  hkstock = false
  Dir.glob("#{dir}\/*.*").each do |afile|
     
    puts "processing #{filecount} files ..." if filecount % 500 == 0
    filecount += 1
    File.open(afile) do |file|
       #lineno = 1
       line = file.gets

       #first_date = 

       h =Hash.new
       na = line.split(',')

       h[:code] = na[0]
       hkstock = true if h[:code][0..1] == 'hk'
       if hkstock

         h[:close] = na[6].to_f
         h[:ratio] = na[8].to_f
         h[:high52w] = na[15].to_f
         h[:low52w] = na[16].to_f
         h[:date] = Date.parse(na[19])
         #h[:beta] = na[17].to_f # because after 2017-08-04, sina doesn't return beta for stock
         #h[:beta] = 0.0
         h[:pe] = na[13].to_f
         h[:total_mv] = na[17].to_f
         #next if h[:total_mv] < 500000000
         #h[:name] = na[1]
         #puts "#{h[:code]} #{h[:name]} #{h[:date]} #{h[:beta]} "
       else
      
         h[:close] = na[2].to_f
         h[:ratio] = na[3].to_f
         h[:high52w] = na[8].to_f
         h[:low52w] = na[9].to_f
         h[:date] = Date.parse(na[19])
         #h[:beta] = na[17].to_f # because after 2017-08-04, sina doesn't return beta for stock
         #h[:beta] = beta_hash[h[:code].to_sym]
         h[:beta] = 0.0 if h[:beta] == nil
         h[:pe] = na[16].to_f
         h[:total_mv] = na[13].to_f
         #next if h[:total_mv] < 500000000
         #h[:name] = na[1]
         #puts "#{h[:code]} #{h[:name]} #{h[:date]} #{h[:beta]} "
       end

        h[:name] = na[1]

       d1y = h[:date] - 360
       d6m = h[:date] - 180
       d3m = h[:date] - 90
       d1m = h[:date] - 30
       
       #lineno += 1
       d1y_flag = false
       d6m_flag = false
       d3m_flag = false
       d1m_flag = false

       h[:r1y] = h[:r6m] = h[:r3m] = h[:r1m] = 0.0   

       h[:r_off] = 0.0
       dr_off_flag = false
       dr_off = h[:date] - offset


       file.each_line do |line|
        
         na = line.split(' ')
         nd = Date.parse(na[0])

         if (not dr_off_flag) and (nd >= dr_off)
           dr_off_flag = true
           h[:r_off] = - (na[4].to_f - h[:close])/na[4].to_f * 100 if na[4].to_f > 0.0 
         end

         if (not d1y_flag) and (nd >= d1y)
           d1y_flag = true
           h[:r1y] = - (na[4].to_f - h[:close])/na[4].to_f * 100 if na[4].to_f > 0.0 
         end

         if (not d6m_flag) and (nd >= d6m)
           d6m_flag = true
            h[:r6m] = - (na[4].to_f - h[:close])/na[4].to_f * 100 if na[4].to_f > 0.0
         end

         if (not d3m_flag) and (nd >= d3m)
           d3m_flag = true
            h[:r3m] = - (na[4].to_f - h[:close])/na[4].to_f * 100 if na[4].to_f > 0.0
         end

         if (not d1m_flag) and (nd >= d1m)
           d1m_flag = true
           h[:r1m] = - (na[4].to_f - h[:close])/na[4].to_f * 100 if na[4].to_f > 0.0
         end         

        
       end # of each_line
      
       ta.push(h)

    end
  end

  ta.sort_by!{|h| h[:total_mv]}
  ta.reverse!

  case mode
    
    when 0
    when 1
      ta.delete_if {|h| h[:r_off] <= roe}
    when 2
      ta.delete_if {|h| h[:r_off] > roe}

    when 11
      ta.delete_if {|h| h[:r_off] <= roe}
       ta.delete_if {|h| h[:total_mv] < 1000000000}
       ta.sort_by!{|h| h[:r_off]}
       ta.reverse!
    when 12
      ta.delete_if {|h| h[:r_off] > roe}
      ta.sort_by!{|h| h[:r_off]}
  
    else
      puts "mode 0 : sorting by 流通市值"
      puts "mode 1 : sorting by 流通市值 涨幅大于#{roe}%"
      puts "mode 2 : sorting by 流通市值 涨幅小于#{roe}%"

      puts "mode 11 : sorting by 涨幅 大于#{roe}%"
      puts "mode 12 : sorting by 涨幅 小于#{roe}%"
    
  end

  topN = ta.length  if topN > ta.length 

  dd = (ta[0][:date] - offset).to_s
  puts dd 


  puts "-------------------------------------------------------------------------------------------------------------"
  puts "TICK     名称               价格   涨跌幅  PE   #{dd[0..6]}    一年  六个月  三个月  一个月 流通市值  high52w low52w"
  puts "-------------------------------------------------------------------------------------------------------------"
  ta[0..(topN - 1)].each do |h|
     nv = h[:total_mv]
     nv = (h[:total_mv]/100000000*100 ).to_i/100.0 if not hkstock

   
    puts "#{normalize_name(h[:code],8)} #{normalize_name(h[:name],16)} #{format_price(h[:close])} #{format_roe(h[:ratio])} \
#{format_price(h[:pe])} #{format_roe(h[:r_off])} #{format_roe(h[:r1y])} #{format_roe(h[:r6m])} #{format_roe(h[:r3m])} #{format_roe(h[:r1m])}\
 #{format_price(nv)}亿  #{format_price(h[:high52w])} #{format_price(h[:low52w])}"
  end
  puts "total #{topN} records"

end # func

#显示过去30天 90天 180天 360天的统计数据
def show_stock_statiscs(topN = 100, sortby_method = 0, roe = 20, final = :quick)
  load_name_into_database if Names.count == 0 
  #puts "#{days} #{topN} #{given_roe} #{gl_roe} #{sortby_method}"
  #
  end_date = Time.now.to_date
  
  date_list = Daily_records.new.get_date_list
  start_date1 = date_list.reverse.find {|date| date <= (end_date - 30)}
  start_date2 = date_list.reverse.find {|date| date <= (end_date - 90)}
  start_date3 = date_list.reverse.find {|date| date <= (end_date - 180)}
  start_date4 = date_list.reverse.find {|date| date <= (end_date - 360)}

  # sortby_method = 0 if (sortby_method > 4) or (sortby_method < 0)
  # sbs = ['按流通市值降序','按流通市值升序','按涨幅降序','按涨幅升序','按代码排序']

  # if gl_roe == 0
  #   p "Show last #{days.to_s} days on #{start_date}, price change greater than #{given_roe.to_s}% , topN = #{topN} ，sortby = #{sbs[sortby_method]} "
  #  else
  #   p "Show last #{days.to_s} days on #{start_date}, price change little than #{given_roe.to_s}% , topN = #{topN} ，sortby = #{sbs[sortby_method]} "
  # end


  sa=[]
  all = get_all_stock_price_from_sina(Names.get_code_list)
  all.delete_if {|h| h[:volume] == 0.0}

  #puts "calculating roe ... "
  h1 = get_hash_for_date(start_date1)
  h2 = get_hash_for_date(start_date2)
  h3 = get_hash_for_date(start_date3)
  h4 = get_hash_for_date(start_date4)

  #i=1   
  all.each do |h|
   # if (final != :quick)
   #   puts "calculating #{format_code(h[:code])} ... " 
   # end

   h[:roe1] = get_hr_roe(h[:code],h[:close],h1,start_date1,final)
   h[:roe2] = get_hr_roe(h[:code],h[:close],h2,start_date2,final)
   h[:roe3] = get_hr_roe(h[:code],h[:close],h3,start_date3,final)
   h[:roe4] = get_hr_roe(h[:code],h[:close],h4,start_date4,final)

   if (final != :quick)
     puts "#{format_code(h[:code])} #{format_price(h[:close])} 一个月涨幅=#{format_roe(h[:roe1])} 三个月涨幅=#{format_roe(h[:roe2])} 半年涨幅=#{format_roe(h[:roe3])} 一年涨幅=#{format_roe(h[:roe4])}" 
   end

   sa.push h

   #i += 1

  end

  case sortby_method
    
    when 0
      sa.sort_by!{|h| h[:total_mv]}
      sa.reverse!
    when 1
      sa.sort_by!{|h| h[:total_mv]}
    when 2 
      sa.sort_by!{|h| h[:roe4]}
      sa.reverse!
    when 3 
      sa.sort_by!{|h| h[:roe3]}
      sa.reverse!
    when 4
      sa.sort_by!{|h| h[:roe2]}
      sa.reverse!
    when 5 
      sa.sort_by!{|h| h[:roe1]}
      sa.reverse!
    when 6 
      sa.sort_by!{|h| h[:code]}

    when 10
      sa.delete_if {|h| h[:roe4] <= roe}
      sa.sort_by!{|h| h[:total_mv]}
      sa.reverse!
    when 11
      sa.delete_if {|h| h[:roe4] >= - roe}
      sa.sort_by!{|h| h[:total_mv]}
      sa.reverse!
    when 12
      sa.delete_if {|h| h[:roe3] <= roe}
      sa.sort_by!{|h| h[:total_mv]}
      sa.reverse!
    when 13
      sa.delete_if {|h| h[:roe3] >= - roe}
      sa.sort_by!{|h| h[:total_mv]}
      sa.reverse!
    when 14
      sa.delete_if {|h| h[:roe2] <= roe}
      sa.sort_by!{|h| h[:total_mv]}
      sa.reverse!
    when 15
      sa.delete_if {|h| h[:roe2] >= - roe}
      sa.sort_by!{|h| h[:total_mv]}
      sa.reverse!
    when 16
      sa.delete_if {|h| h[:roe1] <= roe}
      sa.sort_by!{|h| h[:total_mv]}
      sa.reverse!
    when 17
      sa.delete_if {|h| h[:roe1] >= - roe}
      sa.sort_by!{|h| h[:total_mv]}
      sa.reverse!

    when 20
      sa.delete_if {|h| h[:roe1] <= roe}
      sa.delete_if {|h| (h[:roe1] - h[:roe2]) < -5 }
      sa.sort_by!{|h| h[:total_mv]}
      sa.reverse!



    else
      p "unknown sort method #{sortby_method}"
  end
    
  return if sa.length == 0

  topN = sa.length - 1 if topN > (sa.length - 1 )
  
  #puts
  puts "名称     代码     收盘价  一个月涨幅 三个月涨幅 半年涨幅 一年涨幅  流通市值 "
  sa[0..(topN - 1)].each do |h|
     #puts "代码  收盘价  一个月涨幅 三个月涨幅 半年涨幅 一年涨幅  流通市值 "
     puts "#{format_code(h[:code])} #{format_price(h[:close])},  #{format_roe(h[:roe1])}, \
  #{format_roe(h[:roe2])},   #{format_roe(h[:roe3])},  #{format_roe(h[:roe4])}  #{format_price(h[:total_mv])}亿 " 
     
  end

  ave_ratio1 = (sa[0..(topN - 1)].collect{|h| h[:roe1]}.inject(:+)/topN*100).to_i/100.0
  ave_ratio2 = (sa[0..(topN - 1)].collect{|h| h[:roe2]}.inject(:+)/topN*100).to_i/100.0
  ave_ratio3 = (sa[0..(topN - 1)].collect{|h| h[:roe3]}.inject(:+)/topN*100).to_i/100.0
  ave_ratio4 = (sa[0..(topN - 1)].collect{|h| h[:roe4]}.inject(:+)/topN*100).to_i/100.0
  puts "------------------------------------------------------------------------------"
  puts "总共#{topN}支股票   平均涨幅 = #{format_roe(ave_ratio1)}    #{format_roe(ave_ratio2)}    #{format_roe(ave_ratio3)}   #{format_roe(ave_ratio4)} on #{Time.now.strftime("%y-%m-%d %H:%M:%S")}"
  
  return  sa 

end # of show_stock_price_change

# 分析 监控程序纪录的日志信息
def  analysis_stock_log_data(fname,offset,roe)
  #puts fname
  
  dl = []
  sl = {}
  first_record = true
  lineno = 0

  file_format = :us
  File.open(fname, ) do |file|
            
        file.each_line do |line|    
              lineno += 1
              na = line.split(',')
              code = na[0]
              next if code == 'code'

              if code[0..1] == 'hk'
                file_format = :hk

                close = na[6].to_f
                date = na[19]
                beta = 1
                pe = na[13].to_f
                total_mv = na[17].to_f
                name = na[1] 
              else

                close = na[2].to_f
                date = na[19]
                beta = na[17].to_f
                pe = na[16].to_f
                total_mv = na[13].to_f
                name = na[1]
              end

              #first record
              if ((file_format == :us) and  (code == 'AAPL')) or ((file_format == :hk) and  (code == 'hk00700'))
                first_record = false if dl.length > 0 
                
                len = dl.length
                sl.each_pair do |k,v|
                  if v[:cl].length < len
                    #puts "#{k} #{v}"
                    t = v[:cl][-1]
                    v[:cl].push(t)
                    #puts "#{k} #{v}"
                  end
                end

                #puts sl.size

                sl.each_pair do |k,v|
                  #puts "#{k},#{v}"
                end


                puts "Processing line:#{lineno}, date = #{date}"  
                dl.push(date) 

                 if first_record and (not sl.has_key? (code.to_sym))
                     #puts code

                     h=Hash.new
                     h[:name] = name
                     # h[:pe] = pe
                     # h[:beta] = beta
                     # h[:total_mv] = total_mv
                     h[:cl] = [] 
                     sl[code.to_sym] = h
                 end
                    
                 #sl[code.to_sym].push(close) 
                 if sl.has_key? (code.to_sym)
                     h = sl[code.to_sym]
                     #h[:name] = name
                     h[:pe] = pe
                     h[:beta] = beta
                     h[:total_mv] = total_mv
                     h[:cl].push(close) 
                 end
                
                
              else
                if date == dl[-1] #aapl is the first record, so other stock should have same date with aapl
                   if first_record and (not sl.has_key? (code.to_sym))
                     #sl[code.to_sym] = []


                     h=Hash.new
                     h[:name] = name
                     # h[:pe] = pe
                     # h[:beta] = beta
                     # h[:total_mv] = total_mv
                     h[:cl] = [] 
                     sl[code.to_sym] = h
                   end
                    
                   #sl[code.to_sym].push(close) if sl.has_key? (code.to_sym)
                   if sl.has_key? (code.to_sym)
                     h = sl[code.to_sym]
                     #h[:name] = name
                     h[:pe] = pe
                     h[:beta] = beta
                     h[:total_mv] = total_mv
                     h[:cl].push(close) 
                 end

                else
                  #puts dl
                  #puts "ERROR HAPPED!! #{code} date is #{date}, system date is #{dl[-1]} , skip ...."
                  #puts line
                  #exit 
                end
              end

              #puts "#{code}, #{date},#{close}"
        end
  end # end of file processing

  # add last record
   len = dl.length
    sl.each_pair do |k,v|
      if v[:cl].length < len
        #puts "#{k} #{v}"
        t = v[:cl][-1]
        v[:cl].push(t)
        #puts "#{k} #{v}"
      end
    end

  #dl.each {|d| puts d}

  # sl.each_pair do |k,v|
  #   puts "#{k},#{v.length}"
  # end
  
  rl = {}

  start_pos = get_index_by_offset(dl,offset)
  # puts start_pos
  # puts dl[start_pos]
  # 
  tl = []

  sl.each_pair do |k,v|
    n_roe = (v[:cl][-1] - v[:cl][start_pos])/v[:cl][start_pos] * 100 
    if n_roe >= roe
      h = v
      h[:id] = k
      h[:close] = v[:cl][-1]
      h[:roe] = n_roe 
      tl.push(h)  
    end
  end 


   tl.sort_by!{|h| h[:total_mv]}
   tl.reverse!
   puts "------------------------------------------------------------------------"
   puts "过去 #{offset} 天， 股价变化大于 #{roe}% 的公司列表，按流通市值降序排列 #{dl[-1]}"
   puts "------------------------------------------------------------------------"
   #puts
   if file_format == :us
     puts "TICK    名称         收盘价    PE    beta    roe  流通市值"
     tl.each do |h|
      nv = (h[:total_mv]/100000000*100 ).to_i/100.0

      puts "#{normalize_name(h[:id].to_s,5)} #{h[:name]} #{format_price(h[:close])} #{format_price(h[:pe])} #{format_price(h[:beta])} #{format_roe(h[:roe])} #{nv}亿"
     end
   else
      puts "TICK       名称        收盘价    PE     roe  流通市值"
     tl.each do |h|
      nv = (h[:total_mv])

      puts "#{normalize_name(h[:id].to_s,8)} #{h[:name]} #{format_price(h[:close])} #{format_price(h[:pe])}  #{format_roe(h[:roe])} #{nv}亿"
     end

   end


end

def get_index_by_offset(dl,offset)
  last_d = Date.parse(dl[-1])
  
   dl.each_with_index do |d,i|
    if (last_d - Date.parse(d)).to_i <= offset
       return i
    end
   end
end

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