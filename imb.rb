$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
 
require "shared_setup"




# main 
begin

fn = 1 
mid = 1
name_list =[]

line_list = []

Dir.glob("data_2\/*.txt").each do |afile|
    puts "processing file #{afile}"


    market=afile[7..8]  #SH SZ
    fcode = afile[9..14]
    #puts market

    File.open(afile,:encoding => 'gbk') do |file|

      #line_buf = []
      file.each_line do |line|
        #puts line
        t = line[0..5].to_i
       
        
        if t > 12 # the first line
          code_name = line[7..10]
          #puts code_name.encoding
          
          ts = "#{fn},\'#{fcode.to_s}\',\'#{code_name.to_s}\',\'#{market.to_s}\'"
          #insert_data('name',ts)
          
          name_list.push(ts)

          #puts ts
          fn +=1
        end


        if (t!=0) and (t < 13) #non blank line
           #puts line
            day=line[6..9]+'-'+line[0..1]+'-'+line[3..4]       

            td,open,high,low,close,volume,amount = line.split(/\t/)
           

          

            ts = "#{mid},\'#{fcode.to_s}\',date(\'#{day}\'),#{open},#{high},#{low},#{close},#{volume},#{amount},1,1"
            #puts ts
            line_list.push(ts)
            mid += 1
        end

      end # each line
    end  # each do file

   #insert_data('daily_records',line_list)
   line_list = []

    #break
end

insert_data('name',name_list)


rescue => detail

   print "An error occurred: ",$!, "\n"

if show_detail?
  puts detail.message
  print detail.backtrace.join("\n")
end

end