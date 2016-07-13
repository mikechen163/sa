$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
 
require "shared_setup"
require "common"


name_list = []
dir="data_0430"
fn = 1

Dir.glob("#{dir}\/*.txt").each do |afile|
    puts "processing file #{afile}"


    pos = afile.index('S')
    market=afile[pos..(pos+1)]  #SH SZ
    fcode = afile[(pos+2)..(pos+7)]
    

    File.open(afile,:encoding => 'gbk') do |file|

     
      file.each_line do |line|
        #puts line
        t = line[2]
       
        
        if (t>='0') and (t <= '9')  # the first line

          flag = line[7..8].strip.length


          if flag==2
          	if line[7]=='*'
          	  code_name = line[7..11].strip	+ " "
            else
              flag = line[7..9].strip.length
              #p line[7..9]
              #p flag

              if flag == 2
                code_name = line[7..8].strip + "    " 
              else
                code_name = line[7..10].strip
              end
            end

            #p code_name

            code_name+="  " if code_name.length==3

            if line[7]=='S'
            	code_name = line[7..9].strip+"   "
            end

            if line[7..8]=='ST'
              code_name = line[7..10].strip+"  "
            end


            if line[7..9]=='GQY'
            	code_name = line[7..11].strip+' '
            end
            if line[7..9]=='TCL'
            	code_name="TCL     "
            end

            code_name+=' ' if (fcode=='000011') or (fcode=='000017') or (fcode=='000018')
          else
          	flag = line[7..9].strip.length
          	if flag==1
          	  code_name = "#{line[7]}#{line[10]}#{line[11]}"+"  "
            else
              code_name = "#{line[7]}#{line[9]}#{line[11]}"+"  "
            end
          end

          code_name = "#{line[7]}#{line[12]}"+"    " if (fcode=='000528')



          #puts code_name+"ppp"

           if fn == 1
            ts = "delete from name"
            name_list.push(ts)
            fn += 1
          end
          
          ts = "#{fn},\'#{fcode.to_s}\',\'#{code_name.to_s}\',\'#{market.to_s}\'"
          #insert_data('name',ts)
          
          name_list.push(ts)

         fn +=1
        end

     end
  end

end

insert_data('name',name_list)