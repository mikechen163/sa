$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
 
require "shared_setup"


# create sys_table
sa = [ 
          "BEGIN TRANSACTION",
          "DROP TABLE daily_records",
          "create table  daily_records ( id integer primary key,
                code                        varchar(6),    
                date                       DATE,  
                open                       float,  
                high                       float,  
                low                       float,  
                close                       float,  
                volume                     float,
                amount                     float,
                week_num                   integer,
                month_num                  integer


                )",

          "DROP TABLE lastest_records",
          "create table  lastest_records ( id integer primary key,
                code                        varchar(6),    
                date                       DATE,  
                open                       float,  
                high                       float,  
                low                       float,  
                close                       float,  
                volume                     float,
                amount                     float
                )",

          "DROP TABLE daily_minlist_records",
          "create table  daily_minlist_records ( id integer primary key,
                code                        varchar(6),    
                date                         DATE,  
                last_days                    integer,
                price                        float

               )",

          "DROP TABLE weekly_records",
          "create table  weekly_records ( id integer primary key,
                code                        varchar(6),  
                date                         DATE,  
                week_num                     integer,  
                open                       float,  
                high                       float,  
                low                       float,  
                close                       float,  
                volume                     float,
                amount                     float,
                ma5                        float,
                ma10                        float,
                ma20                        float,
                ma60                        float,
                ma20_3m_before              float,
                ma60_3m_before              float,
                ma60_6m_before              float,
                ma5_vol                     float,
                ma10_vol                    float,       
                diff                        float,
                dea                         float,
                macd                        float,
                market_state                integer,
                days_in_state               integer,
                support_price               float,
                new_high                    float,
                new_low                     float,
                new_high_date               DATE,
                new_low_date                DATE

                )",

          "DROP TABLE weekly_etf_records",
          "create table  weekly_etf_records ( id integer primary key,
                code                        varchar(6),  
                date                         DATE,  
                week_num                     integer,  
                open                       float,  
                high                       float,  
                low                       float,  
                close                       float,  
                volume                     float,
                amount                     float,
                ma5                        float,
                ma10                        float,
                ma20                        float,
                ma60                        float,
                ma20_3m_before              float,
                ma60_3m_before              float,
                ma60_6m_before              float,
                ma5_vol                     float,
                ma10_vol                    float,  
                diff                        float,
                dea                         float,
                macd                        float,
                market_state                integer,
                days_in_state               integer,
                support_price               float,
                new_high                    float,
                new_low                     float,
                new_high_date               DATE,
                new_low_date                DATE

                )",

          "DROP TABLE weekly_minlist_records",
          "create table  weekly_minlist_records ( id integer primary key,
                code                        varchar(6),    
                date                         DATE,  
                week_num                     integer,
                last_days                    integer,
                price                        float

               )",
 

           "DROP TABLE monthly_records",
          "create table  monthly_records ( id integer primary key,
                code                        varchar(6), 
                date                         DATE,   
                month_num                   integer,  
                open                       float,
                high                       float,  
                low                       float,  
                close                       float,  
                volume                     float,
                amount                     float,
                 ma5                        float,
                 ma10                        float,
                 ma20                        float,
                 ma60                        float,
                 diff                        float,
                dea                         float,
                macd                        float
               
                )",

          "DROP TABLE name",
          "create table  name ( id integer primary key,
                code                        varchar(6),    
                name                        varchar(20),
                market                      varchar(2)

               )",

          
          "DROP TABLE etf_name",
          "create table  etf_name ( id integer primary key,
                code                        varchar(6),    
                name                        varchar(20),
                market                      varchar(2)

               )"

   ]

     

      sa.push("COMMIT")
     
      sa.each { |statement|
         # Tables doesn't necessarily already exist
         begin; ActiveRecord::Base.connection.execute(statement); rescue ActiveRecord::StatementInvalid; end
      } 

  
    # make a test.
   	# sa = [ "BEGIN TRANSACTION"]

       
    #    pss = "insert into daily_records values (1,'600036',date('2014-02-02'),12,13,11.5,12.5,100000.0,1200000,1,1 )" 
    #    sa.push(pss.to_s)
    #    pss = "insert into daily_records values (2,'600136',date('2014-02-02'),12,13,11.5,12.5,100000.0,1200000 ,1,1)" 
    #    sa.push(pss.to_s)

    #    pss = "insert into weekly_records values (1,'600036',1,12,13,11.5,12.5,100000.0,1200000 )" 
    #    sa.push(pss.to_s)
    #    pss = "insert into monthly_records values (1,'600036',1,12,13,11.5,12.5,100000.0,1200000 )" 
    #    sa.push(pss.to_s)

    #    pss = "insert into name values (1,'600036','招商银行','SH' )" 
    #    sa.push(pss.to_s)

    #   sa.push("COMMIT")
     
    #   sa.each { |statement|
    #      # Tables doesn't necessarily already exist
    #      begin; ActiveRecord::Base.connection.execute(statement); rescue ActiveRecord::StatementInvalid; end
    #   } 
