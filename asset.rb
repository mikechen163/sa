
require "common"
# To change this template, choose Tools | Templates
# and open the template in the editor.

# def format_big_num(num)
#   tn=num.floor

#   tail=((num.remainder(1)*100).floor/100.0).to_s
#   len=tail.length
#   str=tail[1..len-1]
#   while tn>0
#    str.insert(0,','+(tn%1000).to_s)
   
#    tn = tn/1000
#   end
#   len = str.length
#   return str[1..len-1]
# end

class Asset
  def initialize
    @current_money  = 10000000.0
    @portfilo = []
    @log = []
    @logon=true
    #@log_file = logfile
    @reserve = 0.0
  end

  def set_log_off
    @logon=false
  end

  def clear_log
    @log = []
  end

  def get_gmv(pl_list)
    gmv = @portfilo.inject(0.0) do  |mem, var| 
      t = pl_list.find {|x| x[:code] == var[:code]}
      mem + var[:amount]*t[:price]
    end

    return gmv+@current_money   
  end



  def get_code_list
    return @portfilo.collect {|x| x[:code]}
  end

  def reserve(ratio,total_money=0.0)
    if ratio == 0.0
      @current_money += @reserve
      @reserve = 0.0
    else
      if @reserve==0.0
        @reserve = total_money*ratio
        @current_money -= @reserve
      end
    end
  end

  def get_code_list
    return @portfilo.collect {|x| x[:code]}
  end

  def get_price(code)
    h =@portfilo.find {|x| x[:code] == code}
    return h[:price]
  end


  def get_date(code)
    h =@portfilo.find {|x| x[:code] == code}
    return h[:date]
  end

  def get_amount(code)
     h =@portfilo.find {|x| x[:code] == code}
    return h[:amount]
  end 

  def set_check_flag(code,flag)
     h =@portfilo.find {|x| x[:code] == code}
     h[:checked] = flag
    # p "ssssssssss"
    # p h
  end 

  def get_check_flag(code,flag)
      h =@portfilo.find {|x| x[:code] == code}
    return h[:checked]
  end 

  def get_checked_code_list
    sa=[]
    @portfilo.each do |x|
      sa.push(x[:code]) if x[:checked] 
    end

    #p sa
    return sa

  end

  # def get_checked_flag(code)
  #   h =@portfilo.find {|x| x[:code] == code}
  #   return h[:checked]
  # end

  # def set_checked_flag(code,flag)
  #   h =@portfilo.find {|x| x[:code] == code}
  #   h[:checked]= flag
  # end

  def sell_all(date,pl_list)
    #return if pl_list.length == 0
    #show_log
    #p @portfilo.length
    #show_portfilo

    tl = @portfilo.collect {|x| x}
    tl.each do |h|

     # 0.upto(@portfilo.length-1) do |i|

     #  h = @portfilo[i-1]
    #@portfilo.each_with_index do |h,i|
      #p i
      #code = h[:code]
      #puts "ssssssssss"
      #p h
      t = pl_list.find {|x| x[:code] == h[:code]}
        price = t[:price]

      sell(h[:code],date,price,h[:amount])
     end

    #show_log
     #p @portfilo
  end

  def show_portfilo(day,pl_list)
    gmv=0.0
    @portfilo.each do |h|
      h2 = pl_list.find {|h3| h3[:code] == h[:code]}
      code = h[:code]
      #puts "#{Names.get_name(code)}(#{code}) (roe:#{((h2[:price]-h[:price])/h[:price]*100).floor}%) buy on #{h[:date].to_s} at price:#{h[:price]},new price=#{h2[:price]},total #{h[:amount]}"
      printf "%s (roe:%s),buy on %s,at price:%s,new price:%s on %s,amount=%s,value=%s\r\n", format_code(code), format_roe((h2[:price]-h[:price])/h[:price]*100),h[:date].to_s,format_price(h[:price]),format_price(h2[:price]),day.to_s,format_big_num(h[:amount],true),format_big_num( h[:amount]*h2[:price])
      gmv += h[:amount]*h2[:price]
    end
    #gmv = @portfilo.inject(0) { |mem, var|  mem + var[:amount]*var[:price]  }
    puts "#{day.to_s} total asset: stock = #{format_big_num(gmv)} , money = #{format_big_num(@current_money)} , total = #{format_big_num(gmv+ @current_money)} , ratio = #{(((gmv+ @current_money)/100000.0).floor)/100.0}"
  end

  def get_current_money
    return @current_money
  end

  def buy(code,date,price,amount,name)

    gv = price*amount
    if gv > @current_money
      #puts "not enough money for to buy#{code}  #{price} #{amount} at #{date}"
      return
    end

    return if amount==0

    h = @portfilo.find {|x| x[:code] == code}
    if h
       old_value =  h[:amount]* h[:price]
       h[:amount] += amount
       h[:price] = (old_value.to_f+price*amount)/h[:amount]
       # h[:checked] = false
    else
       h=Hash.new
       h[:name] = name
       h[:code] = code
       h[:amount] = amount
       h[:price] = price
       h[:date] = date
       h[:checked] = false
       #h[:checked] = false
       @portfilo.push(h)
    end

    @current_money -= gv
    log('buy ',code,amount,price,date,name,0,"") if @logon
  end



  def sell(code,date,price,amount,name,roe,reason)
    h = @portfilo.find {|x| x[:code] == code}
    if h
      if h[:amount] >= amount

         h[:amount] -= amount

         @current_money += amount*price
        
        log('sell',code,amount,price,date,name,roe,reason) if @logon
      end

      #puts "sssssssssss"
      #p h[:amount]
      if h[:amount] == 0
        #p @portfilo.length
        @portfilo.delete_if {|h| h[:code] == code}
        #p @portfilo.length
      end
    end
  end


 def log(act,code,amount,price,date,name,roe,reason)
     h=Hash.new
     h[:name] = name
     h[:code] = code
     h[:act] = act
     h[:date] = date.to_s
     h[:am] = amount
     h[:price] = price
     h[:roe] = roe
     h[:reason] = reason
     @log.push(h)
     #@log_file.p(h)
  end

  def show_log
    @log.each do |h|
      p h
    end
  end

end
