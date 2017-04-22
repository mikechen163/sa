这是一个A股的股票分析程序，功能包括：下载交易数据，计算ma macd ，根据量化算法计算股票，回归计算量化算法收益率等。

使用说明
20170421

1 使用 ruby import_data.rb -gcl agu.txt agu 命令，得到A股的全部可用代码。

2 使用 ruby update_weekly_records.rb －fu agu.txt data_dir 2012-01-01 2017-04-21 ，根据agu的命令列表，获取这段时间内的全部A股的全部复权数据。时间会很久，可能要10几个小时。

3 使用 ruby update_weekly_records.rb －ud data_dir 命令，更新 data_dir 目录下的所有股票数据到最新日期。

4执行 ruby create_sys_table.rb 创建一个空的数据库结构

5 执行ruby import_data.rb -b -d data_dir，倒入指定目录下的股票数据，到数据库. -b 选项是 倒入日数据

6 sqlite3 db_daily.db 
  .output name.txt
  select * from name;
  .output stdout
  这几条命令，把数据库中的name表数据倒出来，生成name.txt文件。这个文件包含数据库中的全部股票名称数据。

7 ruby import_data.rb -sball ，根据数据库，获取每个A股的股权数据，用于计算流通市值。
  ruby import_data.rb -loadfile stockinfo_hk.txt stock_basic_info 把香港的股权数据导入数据库

8 ruby update_weekly_records.rb -u 更新数据库中的周数据，添加ma macd等数据

-----

9 现在可以用 ruby import_data.rb -ppp2 1000 17 命令，查看A股的交易数据了。依赖文件 name.txt 
  ruby import_data.rb -ppp3 1000 17 港股 依赖文件hk_name.txt
  ruby import_data.rb -ppp4 1000 17 美股 依赖文件us_name.txt
  
10 用 ruby update_weekly_records.rb -z 57 52 ，计算模式57 过去52周的量化交易数据了

11 用 ruby update_weekly_records.rb -x 57 10 0 ，计算模式57 下周选择的10支股票

12 用 ruby update_weekly_records.rb -y 57 10 1 ，显示模式57 上周选择的10支股票的本周ROE数据

13 用 ruby import_data.rb -ttp 110 1000 20 命令，计算过去110天，涨幅大于20%的 前1000支股票，按照流通市值降序排列

14 用 ruby import_data.rb -mon 命令，自动下载每日 A股 港股 美股 交易数据 到文件，分别是 cn.csv hk.csv us.csv us_etf.csv，这个命令可以和screen结合使用，长期运行。