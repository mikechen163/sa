def trans(fname)
  File.open(fname) do |file|
  	file.each_line do |line|
	  	#puts line
	  	#nl=line.to_s.gsub(/\s+/,',')
      nl=line.to_s.gsub('[',',')
      nl2=nl.to_s.gsub(']',',')
	  	nl3=nl2.to_s.gsub(':',',')
      nl4=nl3.to_s.gsub('on',',')
	  	puts nl4
    end
  end 
end


if ARGV.length != 0
 
    ARGV.each do |ele|       
        if  ele == '-h'          
          print_help
          exit 
        end

     if  ele == '-x'          
          fname = dir = ARGV[ARGV.index(ele)+1]
          trans(fname)
          exit 
        end

    end
end