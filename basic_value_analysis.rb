$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  

require 'common'


def check_value(vl)
end

def check_growth_stock_list(vl)
end

def get_code_from_line(line)
  re = line.scan (/[0-9]+/)
  re.each do |number|
    if number.size == 6 
      return number if (number[0] == '6') or (number[0] == '0') or (number[0] == '3')
    end
  end
  return nil
end

def check_track_list(fname)
   all = []
  puts "检查跟踪股列表。。。"
   File.open(fname) do |file|       
        file.each_line do |line|
           code = get_code_from_line(line)
          #puts "#{format_code(code)}"
          #show_roe_list(code,1)
          h = evalate_equity(code)
          all.push(h) if h != nil
        end
    end

   all.delete_if {|h| h[:pe] < 0}
   all.sort_by!{|h| h[:ave_roe]}
   all.reverse!
   puts
   puts "名称      代码  财报年度  pb     pe    peg  净资产回报率 预期回报率  利润增长率 收入增长率 净资产增长率 总市值 "
   all.each do |h|
     #puts "#{format_code(h[:code])} [#{h[:year]}] pb = #{h[:pb]}, pe = #{h[:pe]}, 净资产回报率 = #{(h[:ave_roe]*100).to_i/100.0}% 预期回报率=#{h[:real_roe]}%, 10年期回报率=#{h[:ten_year_roe]}%"
     #puts "#{format_code(h[:code])} [#{h[:year]}] pb =#{format_price(h[:pb],2)}, pe =#{format_price(h[:pe])} 利润增长率 =#{format_roe(h[:revenue_inc_ratio])} peg=#{(h[:peg]*100).to_i/100.0} 收入增长率=#{h[:income_inc_ratio]}% 净资产回报率 = #{(h[:ave_roe]*100).to_i/100.0}% 预期回报率=#{h[:real_roe]}%,净资产增长率=#{h[:net_asset_inc_ratio]}%"
     puts "#{format_code(h[:code])} [#{h[:year]}] #{format_price(h[:pb],2)} #{format_price(h[:pe])} #{format_price(h[:peg])}  #{format_roe(h[:ave_roe])}     #{format_roe(h[:real_roe])}\
     #{format_roe(h[:revenue_inc_ratio])}    #{format_roe(h[:income_inc_ratio])}     #{format_roe(h[:net_asset_inc_ratio])}     #{h[:total_mv].round(2)}亿"
  
   end
end

def check_stock_list()

  all = []
  puts "检查高股权回报的价值股列表。。。"
   File.open('value_list.txt') do |file|       
        file.each_line do |line|
          code = line.strip
          #puts "#{format_code(code)}"
          #show_roe_list(code,1)
          h = evalate_equity(code)
          all.push(h)
        end
    end

   all.sort_by!{|h| h[:real_roe]}
   all.reverse!
   puts
   all.each do |h|
     puts "#{format_code(h[:code])} [#{h[:year]}] pb = #{h[:pb]}, pe = #{h[:pe]}, 净资产回报率 = #{(h[:ave_roe]*100).to_i/100.0}% 预期回报率=#{h[:real_roe]}%, 10年期回报率=#{h[:ten_year_roe]}%"
   end


   
    all = []
   puts
   puts "检查高利润增长率成长股列表。。。"
     File.open('growth_list.txt') do |file|       
        file.each_line do |line|
          code = line.strip
          #puts "#{format_code(code)}"
          #show_roe_list(code,1)
          h = evalate_equity(code)
          all.push(h)
        end
    end
   all.sort_by!{|h| h[:peg]}
   #all.reverse!
   puts
   all.each do |h|
     puts "#{format_code(h[:code])} [#{h[:year]}] pb =#{format_price(h[:pb],2)}, pe =#{format_price(h[:pe])} 利润增长率 =#{format_roe(h[:revenue_inc_ratio])} peg=#{(h[:peg]*100).to_i/100.0} 收入增长率=#{h[:income_inc_ratio]}% 净资产增长率=#{h[:net_asset_inc_ratio]}%"
   end


end

def scan_for_chance
  puts "scanning..."

  puts "－－－－－－－－－资产配置分析－－－－－－－－－－－"
  puts "股权市场总体估值分析。。。"
  puts "检查债券市场。。。"
  puts "检查房地产reits市场。。。"
  puts "检查原油市场。。。"
  puts "检查黄金市场。。。"
  puts "检查外汇市场。。。"

  puts "－－－－－－－－－投资机会分析－－－－－－－－－－－"
  check_stock_list
  #puts "检查高股权回报的价值股列表。。。"
  #puts "检查高利润增长率成长股列表。。。"
  puts "检查周期股跟踪列表。。。"
  puts "检查困境股跟踪表。。。"

  puts "－－－－－－－－－投机机会分析－－－－－－－－－－－"
  puts "检查趋势交易机会"

  puts "－－－－－－－－－风险分析－－－－－－－－－－－"
  puts "检查系统性风险状态。 隐形 显性"
  puts ""

end

def show_globl_index
  cl_list = [
    'sh000001',
    'sz399001',
    'sz399300',
    'sz399005',
    'sz399006',
    'int_sp500',
    'int_nasdaq',
    'int_dji',
    'int_hangseng',
    'int_nikkei',
    'int_ftse',
    'b_DAX',
    'b_UKX',
    'b_CAC',
    'b_NKY',
    'b_TWSE',
     'hf_GC',
     'hf_SI',
     'hf_CL',
     'hf_CAD',
     'DINIW',
     'EURUSD',
     'USDJPY',
     'USDCNY',
     'sh600519',
     'sh600276',
     'sz000333',
     'sz000651',
     'sz002415',
    'gb_goog',
    'gb_fb',
    'gb_amzn',
    'gb_aapl',
    'gb_nvda',
    'gb_tsla',
    'gb_ntes',
    'gb_tal',
    'hk00700'
  ]
  sa = get_list_data_from_sina(cl_list)
  
  sa.each do |h|
    puts "#{h[:name]} 收盘价=#{h[:close]} 涨幅=#{(h[:ratio]*10000).to_i/10000.0}%"
  end

end

def get_offset_roe(sa,day,close)

  qf = sa[sa.length-1][7]
  rec =  sa.find {|h| Time.parse(h[0]) > day }

  if rec != nil

    op = rec[3] / qf
    #puts "#{op} on #{rec[0]}"
    roe = (close - op) / op
    return roe
  end

  return 0.0
end

def evalate_equity(code,years=10)

  begin  
  rvn = get_revenue_from_ntes(code)
  rvn_list = rvn[rvn.length-7] 
  asset = get_assets_from_ntes(code)
  as_list = asset[asset.length-2]
  income_list = rvn[1] 

  #puts as_list


  main_idx = get_main_index_from_ntes(code)
  roe_quan = main_idx[19]

  if (years > rvn_list.length-1)
    years = rvn_list.length-1
  end

  years = 3 if (years < 3)

  roe_list = []
  income_inc_list =[]
  revenue_inc_list =[]
  net_asset_inc_list = []
  
    rvn_list.each_with_index do |rr,i|
      if (i>1) and (i<=years+1)
        ly = rvn_list[i-1].split(',').inject(:+).to_f 
        #puts i
        #puts as_list[i]
        asy = as_list[i].split(',').inject(:+).to_f
        roe = (ly/asy*10000).to_i.to_f/100
        roe = roe_quan[i-1].split(',').inject(:+).to_f
        roe_list.push(roe)

        asyn = as_list[i-1].split(',').inject(:+).to_f
        inc_asy = ((asyn-asy)/asy*10000).to_i.to_f/100
        net_asset_inc_list.push(inc_asy)

        icn = income_list[i].split(',').inject(:+).to_f
        ic = income_list[i-1].split(',').inject(:+).to_f
        icc = ((ic-icn)/icn*10000).to_i.to_f/100
        income_inc_list.push(icc)

        lyn = rvn_list[i].split(',').inject(:+).to_f
        ly = rvn_list[i-1].split(',').inject(:+).to_f 
        inc = ((ly-lyn)/lyn*10000).to_i.to_f/100
        revenue_inc_list.push(inc)
      end
    end
  

  ave_roe = roe_list[0..2].sum/3
  #ave_roe = roe_list[0..(years-1)].sum/years
  #ave_roe = roe_list[0..(years-1)].sum/(years-1) if years == (rvn_list.length-1)

  frvn = rvn_list[1].split(',').inject(:+).to_f
  fas =  as_list[1].split(',').inject(:+).to_f
  #total_mv = Stock_Basic_Info.get_stock_total_number(code)
  al = []
  al.push (code)
  close_price = get_list_data_from_sina(al)[0][:close]
  #puts close_price
  total_mv = Stock_Basic_Info.get_stock_total_number(code) * close_price
  #puts total_mv
  pe = ((total_mv*10000/frvn)*100).to_i/100.0
  pb = ((total_mv*10000/fas)*100).to_i/100.0
  real_roe = (ave_roe/pb*100).to_i/100.0
  ten_year_roe = ((((1+real_roe/100)**10)-1)*10000).to_i/100.0
  total_ten_year_roe = (ten_year_roe/100)*pe 

  h = Hash.new
  h[:code] = code
  h[:price] = close_price
  h[:total_mv] = total_mv
  h[:pb] = pb
  h[:pe] = pe
  h[:ave_roe] = ave_roe
  h[:real_roe] = real_roe
  h[:ten_year_roe] = ten_year_roe
  h[:year] = rvn[0][1][0..3]
 

  
  puts
  puts "#{format_code(code)} 年报 [#{rvn[0][1]}]"
  puts "过去3年平均净资产回报率 =#{(ave_roe*100).to_i/100.0}% #{roe_list.to_s}"
  #years = 3
  income_inc_ratio = calc_fh_inc(years,income_list[years].split(',').inject(:+).to_f,income_list[1].split(',').inject(:+).to_f)
  revenue_inc_ratio = calc_fh_inc(years,rvn_list[years].split(',').inject(:+).to_f,rvn_list[1].split(',').inject(:+).to_f)
  net_asset_inc_ratio = calc_fh_inc(years,as_list[years].split(',').inject(:+).to_f,as_list[1].split(',').inject(:+).to_f)
  puts "过去#{years}年收入复合增长率  =#{income_inc_ratio}% #{income_inc_list.to_s}"
  puts "过去#{years}年利润复合增长率  =#{revenue_inc_ratio}% #{revenue_inc_list.to_s}"
  puts "过去#{years}净资产复合增长率=#{net_asset_inc_ratio}% #{net_asset_inc_list.to_s}"


  today = Time.now.to_date 
  sa = get_h_data_from_sina(code,(today - 365).to_s,today.to_s )

  roe_7d = get_offset_roe(sa,today - 7, close_price)
  roe_1m = get_offset_roe(sa,today - 30, close_price)
  roe_3m = get_offset_roe(sa,today - 90, close_price)
  roe_6m = get_offset_roe(sa,today - 180, close_price)
  roe_12m = get_offset_roe(sa,today - 360, close_price)
  puts "价格 #{close_price} 一周涨幅 #{format_roe(roe_7d*100.round(2))}, 一个月涨幅 #{format_roe(roe_1m*100.round(2))}, 三个月涨幅 #{format_roe(roe_3m*100.round(2))}, 6个月涨幅 #{format_roe(roe_6m*100.round(2))}, 一年涨幅 #{format_roe(roe_12m*100.round(2))}"





  #puts "      过去#{years}年，收入复合增长率=#{income_inc_ratio}%,利润复合增长率=#{revenue_inc_ratio}%,\
  #净资产复合增长率=#{net_asset_inc_ratio}%, 净资产平均收益率=#{format_roe(ave_roe)}"

  #puts "#{format_code(code)} [#{rvn[0][1][0..3]}] pb = #{pb}, pe = #{pe}, 净资产回报率 = #{(ave_roe*100).to_i/100.0}% 一年期回报率=#{real_roe}%, 10年期回报率=#{ten_year_roe}%"
  
  h[:income_inc_ratio] = income_inc_ratio
  h[:revenue_inc_ratio] = revenue_inc_ratio
  h[:net_asset_inc_ratio] = net_asset_inc_ratio
  h[:peg] = 0.0 
  h[:peg] =  pe /revenue_inc_ratio  if revenue_inc_ratio > 0.0


  return h

  rescue
    return nil
  end

end

# 分析企业的财务数据
def show_roe_list(code,years=20)
  begin
  rvn = get_revenue_from_ntes(code)
  #puts "get_revenue_from_ntes"
  asset = get_assets_from_ntes(code)
  #puts "get_assets_from_ntes"
  cash = get_cash_from_ntes(code)

  cash_list = cash[26]

  main_idx = get_main_index_from_ntes(code)
  roe_quan = main_idx[19]

  as_list = asset[asset.length-2]
  rvn_list = rvn[rvn.length-7] 
  #rvn_list = main_idx[11] 
  eps_list = rvn[rvn.length-1] 
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
      roe = roe_quan[i-1].split(',').inject(:+).to_f
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

  years = 1 if (years < 1)

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
  puts "-------------------------------------估值分析------------------------------"

  frvn = rvn_list[1].split(',').inject(:+).to_f
  fas =  as_list[1].split(',').inject(:+).to_f
  #total_mv = Stock_Basic_Info.get_stock_total_number(code)
  al = []
  al.push (code)
  close_price = get_list_data_from_sina(al)[0][:close]
  #puts close_price
  total_mv = Stock_Basic_Info.get_stock_total_number(code) * close_price
  #puts total_mv
  
  eps = rvn_list[1].split(',').inject(:+).to_f/Stock_Basic_Info.get_stock_total_number(code)/10000
  pe = ((total_mv*10000/frvn)*100).to_i/100.0
  pb = ((total_mv*10000/fas)*100).to_i/100.0
  real_roe = (ave_roe/pb*100).to_i/100.0
  ten_year_roe = ((((1+real_roe/100)**10)-1)*10000).to_i/100.0
  total_ten_year_roe = (ten_year_roe/100)*pe
  puts "pb = #{pb}, pe = #{pe}, eps = #{eps_list[1]} 一年预期回报率=#{real_roe}%, 10年预期资产回报率=#{ten_year_roe}%"
  #puts pb




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
  #eps_list = rvn[rvn.length-1]

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


  puts ""
  puts "-------------------------------------现金流量分析------------------------------"  

  puts "经营活动现金流分析:"
  cash_income_list = cash[15]
  cash_tax_list = cash[23]   
  cash_list.each_with_index do |rr,i|
    if (i>1) and (i<=years+1)
     # puts "#{i} #{rvn_list[i]} #{rvn_list[i-1]}"
       icn = cash_list[i].split(',').inject(:+).to_f
       ic = cash_list[i-1].split(',').inject(:+).to_f
       icc = ((ic-icn)/icn*10000).to_i.to_f/100

       cicn = cash_income_list[i].split(',').inject(:+).to_f
       cic = cash_income_list[i-1].split(',').inject(:+).to_f
       cicc = ((cic-cicn)/cicn*10000).to_i.to_f/100
       total_ic = income_list[i-1].split(',').inject(:+).to_f


       ly = rvn_list[i-1].split(',').inject(:+).to_f 

       # cticn = cash_tax_list[i].split(',').inject(:+).to_f
       # ctic = cash_tax_list[i-1].split(',').inject(:+).to_f
       # cticc = ((ctic-cticn)/cticn*10000).to_i.to_f/100

       cratio = ((ic)/cic*10000).to_i.to_f/100
       lr_cash_ratio = ((ic)/ly*10000).to_i.to_f/100
       ltr_cash_ratio = ((cic)/total_ic*10000).to_i.to_f/100
      
      puts "#{rvn[0][i-1]} 运营现金流入[#{cash_income_list[i-1]}万,增长=#{cicc}%], 净现金流入[#{cash_list[i-1]}万,增长=#{icc}%], 净现金流入比例＝#{cratio}%, 净现金:利润=#{lr_cash_ratio}%,  流入现金:营收=#{ltr_cash_ratio}%"
      #puts "#{rvn[0][i-1]} 运营现金流入[#{cash_income_list[i-1]}万,增长=#{cicc}%], 净现金流入[#{cash_list[i-1]}万,增长=#{icc}%], 净现金流入比例＝#{cratio}%"
    end
  end

   puts "过去#{years}年，现金复合增长率=#{calc_fh_inc(years,cash_income_list[years].split(',').inject(:+).to_f,\
  cash_income_list[1].split(',').inject(:+).to_f)}%,\
  净现金流复合增长率=#{calc_fh_inc(years,cash_list[years].split(',').inject(:+).to_f,\
  cash_list[1].split(',').inject(:+).to_f)}%"

   puts
   puts "投资和筹资、分红现金分析"
   cash_invest_list = cash[42]
   cash_new_debt_list = cash[49]
   cash_payback_debt_list = cash[50]
   cash_divide_list = cash[51]
   cash_stock_opr_list = cash[55]
   cash_running_list = cash[59]
   cash_final_list = cash[61]
   s1 = 0.0
   s2 = 0.0
   s3 = 0.0
   s4 = 0.0
   s5 = 0.0
   cash_list.each_with_index do |rr,i|
    if (i>1) and (i<=years+1)
     # puts "#{i} #{rvn_list[i]} #{rvn_list[i-1]}"
       cinl = - cash_invest_list[i-1].split(',').inject(:+).to_f
       csol = cash_stock_opr_list[i-1].split(',').inject(:+).to_f
       cdl = cash_divide_list[i-1].split(',').inject(:+).to_f
       cndl = cash_new_debt_list[i-1].split(',').inject(:+).to_f
       cpdl = cash_payback_debt_list[i-1].split(',').inject(:+).to_f
       cfl = cash_final_list[i-1].split(',').inject(:+).to_f
       crl = cash_running_list[i-1].split(',').inject(:+).to_f
       ic = cash_list[i-1].split(',').inject(:+).to_f
       asyn = as_list[i-1].split(',').inject(:+).to_f
       
    

       cfratio = ((cfl)/asyn*10000).to_i.to_f/100
       ctratio = 0.0
       ctratio = ((ic)/cndl*10000).to_i.to_f/100 if cndl > 0.0
      
       s1 = s1 + cinl
       s2 = s2 + cdl
       s3 = s3 + cndl
       s4 = s4 + cpdl


      puts "#{rvn[0][i-1]} 投资现金流出[#{cash_invest_list[i-1]}万], 筹资[#{cash_new_debt_list[i-1]}万],还款[#{cash_payback_debt_list[i-1]}万], 分红[#{cash_divide_list[i-1]}万], 期末现金变化[#{cash_running_list[i-1]}万], 期末现金:净资产＝#{cfratio}%, 运营现金:借款＝#{ctratio}% "
    end
  end



  return roe_list

  rescue
  end

 end #func
