$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  

require 'common'


def check_value(vl)
end

def check_growth_stock_list(vl)
end

def check_stock_list()
  puts "检查高股权回报的价值股列表。。。"
   File.open('value_list.txt') do |file|       
        file.each_line do |line|
          code = line.strip
          puts "#{format_code(code)}"
          #show_roe_list(code,1)
        end
    end

   puts "检查高利润增长率成长股列表。。。"
     File.open('growth_list.txt') do |file|       
        file.each_line do |line|
          code = line.strip
          puts "#{format_code(code)}"
          #show_roe_list(code,1)
        end
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
    'gb_spy',
    'gb_simo',
    'gb_qiwi',
    'hk02208',
    'hk00700']
  sa = get_list_data_from_sina(cl_list)
  
  sa.each do |h|
    puts "#{h[:name]} 收盘价=#{h[:close]} 涨幅=#{(h[:ratio]*100).to_i/100.0}%"
  end

end


# 分析企业的财务数据
def show_roe_list(code,years=20)
  rvn = get_revenue_from_ntes(code)
  #puts "get_revenue_from_ntes"
  asset = get_assets_from_ntes(code)
  #puts "get_assets_from_ntes"
  cash = get_cash_from_ntes(code)

  cash_list = cash[26]


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
  pe = ((total_mv*10000/frvn)*100).to_i/100.0
  pb = ((total_mv*10000/fas)*100).to_i/100.0
  real_roe = (ave_roe/pb*100).to_i/100.0
  ten_year_roe = ((((1+real_roe/100)**10)-1)*10000).to_i/100.0
  total_ten_year_roe = (ten_year_roe/100)*pe
  puts "pb = #{pb}, pe = #{pe}, 一年预期回报率=#{real_roe}%, 10年预期资产回报率=#{ten_year_roe}%"
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

 end #func
