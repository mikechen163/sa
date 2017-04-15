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