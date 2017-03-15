no = 1
Dir.glob("dhk_0315\/*.txt").sort.each do |afile|
    #puts afile
    ind = afile.index('/')
    if (afile[ind+1] == '3') or  (afile[ind+1] == '7')
        File.open(afile,:encoding =>'gbk' ) do |file|
            i = 0
            file.each_line do |line|
                nz = line.encode('utf-8','gbk')
                #puts nz
                if i == 0
                  na = nz.split(' ')
                  if na[0][0] == '0'
                    puts "#{no}| #{na[0]}|#{na[1]}|HK"
                    no += 1
                  end
                  i += 1
                end
            end
        end
   end
end

# Dir.glob("dhk_0315\/31*.txt").sort.each do |afile|
#     File.open(afile,:encoding =>'gbk' ) do |file|
#         file.each_line do |line|
#             nz = line.encode('utf-8','gbk')
#             if line[0] == '0'
#               na = nz.split(' ')
#               puts "#{na[0]} #{na[1]}"
#             end
#         end
#     end
# end
