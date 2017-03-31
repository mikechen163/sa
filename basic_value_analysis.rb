


def check_value_list(vl)
end

def check_growth_stock_list(vl)
end

def check_stock_list()
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
  puts "检查高股权回报的价值股列表。。。"
  puts "检查高利润增长率成长股列表。。。"
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
