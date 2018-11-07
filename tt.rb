filename = 'test.txt'  

  File.open(filename, "r+") do |file|
          #file.rewind
          lineno = 1
          begin
             #line = file.readline
             file.each_line do |line|
                puts "line #{lineno} : #{line}"
                lineno += 1
             end

          rescue
            puts "empty file"
          end
          
          file.seek(0, IO::SEEK_END)
          file.puts "append#{lineno}"
end 


def cal(x ,n )
  t1 = Math.log x
  t2 = t1 / n
   t3 = Math.exp t2
  t4 = t3 -1
  end