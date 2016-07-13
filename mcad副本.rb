$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
 
require "shared_setup"
require 'time'
require 'active_record'

class Daily_records < ActiveRecord::Base
  def self.table_name() "daily_records" end

  def self.get_date_by_week(code,week)
    rec = self.find(:first,:conditions=>" code = \'#{code}\' and week_num = #{week}")

    return rec['date'] if rec
    return nil
  end
end

class Weekly_records < ActiveRecord::Base
  def self.table_name() "weekly_records" end
end

class Weekly_mcad_records < ActiveRecord::Base
  def self.table_name() "weekly_mcad_records" end
end

class Monthly_records < ActiveRecord::Base
  def self.table_name() "monthly_records" end
end

class Names < ActiveRecord::Base
  def self.table_name() "name" end

  def self.get_code_list_for_yahoo

    name_list = []
    self.all.each do |rec|
      appendix = 'SZ'
      appendix = 'SS' if rec['market'] == 'SH'
      #puts appendix
      s = rec['code']+'.'+appendix
      #puts s
      name_list.push( s)
    end

    return name_list

     #return  (Time.now.to_date - s['date']).to_i - 1
  end


  def self.get_code_list

    name_list = []
    self.all.each do |rec|
    
      name_list.push(rec['code'])
    end

    return name_list

     #return  (Time.now.to_date - s['date']).to_i - 1
  end

end

#check if there exist buy point?
# diff across dea, and both below 0
def check_result(l,code)

  old_diff = 0
  old_dea = 0
  old_macd = 0
  elder_diff = -100
  first = true

  l.each do |rec|
    if first
       first = false
    else
       if rec[1] > old_diff

          if (old_dea > old_diff) and (rec[1] > rec[2]) # is this is a cross, diff cross dea ?
            if old_diff < 0
              # found a success record!!!!
              date = Daily_records.get_date_by_week(code,rec[0])
              if date!= nil 
                 puts "Found Cross  point, #{code} at #{date.to_s}" #if date.year >= 2014
              end 

            end
          end

          if elder_diff > old_diff # old_diff is smallest one 

             if old_diff < 0
             # found a success record!!!!
               date = Daily_records.get_date_by_week(code,rec[0])
               if date!= nil 
                  puts "Found Valley point, #{code} at #{date.to_s}" #if date.year >= 2014
               end 
              end

          end

       end 

    end

     elder_diff = old_diff

     old_diff = rec[1]
      old_dea = rec[2]
       old_mcad = rec[3]
        
  end
end


 # code = '600036'
 # date = Daily_records.get_date_by_week(code,3)
 # puts "Found buying point, #{code} at #{date.to_s}" if date!= nil

def na(x)
  return 1.upto(x).inject(0) { |result, element| result + element }
end


$mcad_short = 12
$mcad_long = 26
$mcad_m    = 9

t=2.0/($mcad_long+1)

def get_calc_para(num,t)
  tl = 1.upto(num).collect do |x|
    1.upto(x-1).inject(1) { |result, element| result*(1-t) }
  end

  return tl.reverse
end
#$t_long = (1.upto($mcad_long)).collect{|x| x.to_f/na($mcad_long)}

tl = 1.upto($mcad_long).collect do |x|
  1.upto(x-1).inject(1) { |result, element| result*(1-t) }
end

p tl

$t_long=tl.reverse

p $t_long.length

exit
#$t_short = (1.upto($mcad_short)).collect{|x| x.to_f/na($mcad_short)}
#$t_long = (1.upto($mcad_long)).collect{|x| x.to_f/na($mcad_long)}

#$t_m = (1.upto($mcad_m)).collect{|x| x.to_f/na($mcad_m)}

#p $t_long

# cal ema, input l is array with values, size <= 26
def ema_old(l)
  #nl = l[0..n]

  #p l
  tl = $t_m
  len = l.length
  tl = $t_short if len == $mcad_short
  tl = $t_long if len == $mcad_long

  #p l if len == $mcad_m 

  re = l.each_with_index.inject(0) { |mem, (var,i)| mem + var*tl[i]  }
  #Sp re
  return re
end

def ema(l)
  #nl = l[0..n]

  #p l
  tl = $t_m
  len = l.length
  tl = $t_short if len == $mcad_short
  tl = $t_long if len == $mcad_long

  #p l if len == $mcad_m 

  re = l.each_with_index.inject(0) { |mem, (var,i)| mem + var*tl[i]  }
  #Sp re
  return re
end

# l=[1,2,3,4,5,6]

# l2 = l.each_with_index.collect{|x,i| x*$t_long[i]}

# p l
# p $t_long
# p l2

# p l2.inject(0) { |mem, var| mem + var  }

# p ema(l,5)

def cal_mcad


  #create table

  # sa = [
  #    "BEGIN TRANSACTION",
  #  "DROP TABLE weekly_mcad_records",
  #         "create table  weekly_mcad_records ( id integer primary key,
  #               code                        varchar(6),    
  #               week_num                     integer,  
  #               diff                       float,  
  #               dea                       float,  
  #               mcad                       float
  #               )"

  #    ]

  #    sa.push("COMMIT")
     
  #     sa.each { |statement|
  #        # Tables doesn't necessarily already exist
  #        begin; ActiveRecord::Base.connection.execute(statement); rescue ActiveRecord::StatementInvalid; end
  #     } 

  #     sa = []

  # start analysis
      wid = 1
    Names.get_code_list.each do |code|
       week_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"id asc").collect{|row| row['close']}
       
      #week_list = 1.upto(50).collect{|x| x} 
       #p week_list
       len= week_list.length

       diff_list = []

       result_list = []

       if len >=$mcad_long
            $mcad_long.upto(len) do |i|
            t1 = ema(week_list[(i-$mcad_short)..i-1])
            #p t1
            t2 = ema(week_list[(i-$mcad_long )..i-1])
            #p t2

            diff_list.push (t1-t2)
           end

          #p diff_list
           #diff_list = 1.upto(50).collect{|x| x} 
           len = diff_list.length
           if len >= $mcad_m

               ($mcad_m).upto(len) do |i|
               diff = diff_list[i-1]
               dea = ema(diff_list[(i-$mcad_m)..i-1])
               mcad = 2*(diff-dea)

               result_list.push([i+$mcad_long-1,diff,dea,mcad])

               end

               #p result_list
               check_result(result_list,code)
           end
           
       end 
       break;
    end
end

cal_mcad