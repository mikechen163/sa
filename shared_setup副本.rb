# Be sure to change the mysql_connection details and create a database for the example

$: << File.dirname(__FILE__) + '/../lib'

require 'sqlite3'
require 'active_record'
#require 'logger'
#  class Logger
#    def format_message(severity, timestamp, msg, progname) "#{msg}\n" end
#  end


#$flog = File.new("ar.log","w+") if $flog == nil

#ActiveRecord::Base.logger = Logger.new($flog)
ActiveRecord::Base.establish_connection(
  :adapter  => "sqlite3", 
  :host     => "localhost", 
  #~ :username => "root", 
  #~ :password => "", 
  :database => "db1503.db"
)

def insert_data(table,sl)

   

  sa = [ 
          "BEGIN TRANSACTION"]

       sl.each do |s|  

          ts= "insert into #{table} values (#{s})" 

          #puts ts

         sa.push(ts)
       end

     

      sa.push("COMMIT")
     
      sa.each { |statement|
         # Tables doesn't necessarily already exist
         begin; ActiveRecord::Base.connection.execute(statement); rescue ActiveRecord::StatementInvalid; end
      } 

end


# create sys_table
# sa = [ 
#           "BEGIN TRANSACTION",
#           "DROP TABLE daily_records",
#           "create table  daily_records ( id integer primary key,
#                 code                        varchar(6),    
#                 date                       DATE,  
#                 open                       float,  
#                 high                       float,  
#                 low                       float,  
#                 close                       float,  
#                 volume                     float,
#                 amount                     float,
#                 week_num                   integer,
#                 month_num                  integer

#                 )",

#           "DROP TABLE weekly_records",
#           "create table  weekly_records ( id integer primary key,
#                 code                        varchar(6),    
#                 week_num                     integer,  
#                 open                       float,  
#                 high                       float,  
#                 low                       float,  
#                 close                       float,  
#                 volume                     float,
#                 amount                     float

#                 )",

#            "DROP TABLE monthly_records",
#           "create table  monthly_records ( id integer primary key,
#                 code                        varchar(6),    
#                 month_num                   integer,  
#                 open                       float,
#                 high                       float,  
#                 low                       float,  
#                 close                       float,  
#                 volume                     float,
#                 amount                     float

#                 )",

#           "DROP TABLE name",
#           "create table  name ( id integer primary key,
#                 code                        varchar(6),    
#                 name                        varchar(20),
#                 market                      varchar(2)

#                )"

#    ]

     

#       sa.push("COMMIT")
     
#       sa.each { |statement|
#          # Tables doesn't necessarily already exist
#          begin; ActiveRecord::Base.connection.execute(statement); rescue ActiveRecord::StatementInvalid; end
#       } 

  

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
