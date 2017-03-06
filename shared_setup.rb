# Be sure to change the mysql_connection details and create a database for the example

$: << File.dirname(__FILE__) + '/../lib'

require 'sqlite3'
#require 'mysql2'
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
  :database => "db0303.db"
  
  # :adapter  => "mysql2",
  # :encoding => "utf8",
  # :pool  => "5",
  # :username  => "root",
  # :password  => "",
  # :socket => "/tmp/mysql.sock",
  # :database => "stockdata"
)


def insert_data(table,sl)

   

  sa = [ 
          "BEGIN TRANSACTION"]

       sl.each do |s|  

          if (s[0]>='0') and (s[0]<='9')
            ts= "insert into #{table} values (#{s})" 
          else
            ts=s.to_s
          end

          #puts ts

         sa.push(ts)
       end

     

      sa.push("COMMIT")
     
      sa.each { |statement|
         # Tables doesn't necessarily already exist
         begin; ActiveRecord::Base.connection.execute(statement); rescue ActiveRecord::StatementInvalid; end
      } 

end

def update_data(table,sl)

  sa = [ 
          "BEGIN TRANSACTION"]

       sl.each do |s|  

          ts= "update #{table} set #{s}  " 

          #puts ts

         sa.push(ts)
       end

     

      sa.push("COMMIT")
     
      sa.each { |statement|
         # Tables doesn't necessarily already exist
         begin; ActiveRecord::Base.connection.execute(statement); rescue ActiveRecord::StatementInvalid; end
      } 

end



