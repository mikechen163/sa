#require 'rupy'
#require 'csv'
 require 'json'
 require 'pp'
 require 'time'



class Tushare

  def initialize()
  
  	#@ts=Rupy.import("tushare")


  end

  # def pandas_to_arr(r)
  #    s=r.to_csv.to_s
  #    return CSV.parse(s)
  # end

  #  def get_h_data(code,start_date,end_date)
  #    r = @ts.get_h_data(code,start_date,end_date)
  #    return pandas_to_arr(r)
  # end

  #  def get_history_data(code,start_date,end_date,kcode='D')
  #    r = @ts.get_hist_data(code,start_date,end_date,kcode)
  #    return pandas_to_arr(r)
  # end
  # 
  def get_all_hist_data()


     end_date = Time.now.to_s[0..9]
     start_date = (Date.parse(end_date)-60).to_s

     s = %Q{import tushare as ts;
import types;

wf=open('cache.txt','w');

for line in open('name.txt','r'):
  code = line[5:11]
  wf.write(code)
  r=ts.get_hist_data(code,'#{start_date}','#{end_date}','W'); 
  if type(r) != types.NoneType: 
    x=r.to_json(date_format='iso',orient='index')  
    wf.write( r)

wf.close;
        }
     ns = `python -c "#{s}"`
     # pos=ns.index('{')
     #  return [] if pos == nil
     # return JSON.parse(ns[pos..ns.length-1])
     p ns

  end

  def get_h_data(code,start_date,end_date)
     #s = "import tushare as ts; r=ts.get_h_data('#{code}','#{start_date}','#{end_date}').to_json(date_format='iso',orient='index');print r"
      s = %Q{import tushare as ts;
import types;
r=ts.get_h_data('#{code}','#{start_date}','#{end_date}'); 
x=''
if type(r) != types.NoneType: 
  x=r.to_json(date_format='iso',orient='index')  
print x
        }
     ns = `python -c "#{s}"`
     pos=ns.index('{')
      return [] if pos == nil
     #print ns[pos..ns.length-1]
     return JSON.parse(ns[pos..ns.length-1])
  end

   def get_history_data(code,start_date,end_date,kcode='D')
     #r = @ts.get_hist_data(code,start_date,end_date,kcode)
  
     begin
       s = %Q{import tushare as ts;
import types;
r=ts.get_hist_data('#{code}','#{start_date}','#{end_date}','#{kcode}'); 
x=''
if type(r) != types.NoneType: 
  x=r.to_json(date_format='iso',orient='index')  
print x
        }

        #p s
       ns = `python -c "#{s}"`
     #pp ns
        pos=ns.index('{')
        #p pos
       return [] if pos == nil
       return JSON.parse(ns[pos..ns.length-1])
     ensure
     end
   end

  # def arr_to_hash(ta)

  #   ha=[]
  #   header = ta[0]
  #   len = ta.length
  #   ta[1..len-1].each do |na|
  #     tt=header.each_with_index.map {|x,i| [x,na[i]]}
  #     h = Hash[tt]
  #     ha.push(h)
  #   end

     #return ha
  # end

end

if $0 == __FILE__


t=Tushare.new
 h=t.get_h_data('600000','2016-06-30','2016-06-30')
 h.each {|line| p line}

# h=t.get_history_data('600919','2015-12-04',Time.now.to_s[0..9],'W')
# #p h.size
# #h.sortby!{|h| h.keys}
# h.each {|line| p line}

#t.get_all_hist_data
# Rupy.start
#  if ARGV.length != 0
 
#     ARGV.each do |ele|       
#      # if  ele == '-h'          
#      #  print_help
#      #  exit 
#      # end 

#      if ele == '-h'
#       code = ARGV[ARGV.index(ele)+1]
#       start_date = ARGV[ARGV.index(ele)+2]
#       end_date = ARGV[ARGV.index(ele)+3]

#       t=Tushare.new
#       ta=t.get_h_data(code,start_date,end_date)

#       ha = arr_to_hash(ta)
#       ha.each {|h| p h}

#     end
#    end
# end

# Rupy.stop
# 
# 
# json = File.read('daily_data.txt')
# obj = JSON.parse(json)

#  obj.keys.sort.each{|x| p x}
end