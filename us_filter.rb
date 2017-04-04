 File.open('us_name.txt') do |file|
            file.each_line do |line|
                ws = line.split(',')
              # if not ws[0].index('$')
              #   if not ws[0].index('.') 
              #       puts line
              #   else
              #       #puts "PPPP#{line}"
              #   end

              # end
              #
               if ws[0] =~ /[^A-Z]+/
                puts "PPPP#{line}"
               else
                puts line
               end
            end
end 
