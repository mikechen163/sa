require 'common'



class Stock
  def initialize(rec,cause)
    @code=rec['code']
    @add_date = rec['date']
    @add_price = rec['close']
    @cause = cause
    @last_week_price = @add_price
   
    @first_new_high = 0.0
    @first_nh_date = rec['date']
    @first_nh_roe = 0.0
    @bottom_price = 0.0
    @bottom_date = rec['date']
    #@low_position = search_low_positon(@code,@add_date) 


    @peak_price = 0.0
    @peak_date = rec['date']

    @stop_trade = false

    @state = :undef
    @state = :new_high if cause==:new_high

    @buy_state = :empty_position
    @sell_reason=:unknown
    @sell_date = @add_date
    #@buy_price = @add_price
    #@buy_date = @add_date
    #@buy_amount =0
    @last_add_price=0.0
  	@last_add_date = @add_date
  	@last_add_amount = 0
  	@add_position_times=0
  	@total_amount = 0
  	@jump_sell_position = 0
  	@jump_sell_price = 0.0

  	@quick_jump_roe = 1.0
  	@quick_jump_mode =false

  	@add_position_times +=1

    @show_log = false

    
    @last_update_day = 0

    @support_price = 1000
    @base_price = rec['ma60']
    @drop_from_peak_times=0
    @last_jump_price=0.0
    
  end

  def set_log_state(new_state)
  	@show_log = new_state
  end

  def get_code
  	return @code
  end

  def get_add_position_times
  	return @add_position_times
  end

  def get_state
  	return @state
  end

  def get_amount
  	return @total_amount
  end

  def get_jump_sell_postion
  	return @jump_sell_position
  end

   def get_buy_price
  	return @last_add_price
  end

  def get_buy_date
  	return @last_add_date
  end


  def get_buy_state
  	return @buy_state
  end

   def is_bear_coming?(rec)
  	return true if (@last_week_price < rec['ma20']) and (rec['close'] < rec['ma20'])
  	return false
  end



  def buy(price,amount,day,cause)
    #@buy_price = price
    #@buy_date = day
    #@buy_amount =amount
    @total_amount += amount
    @last_add_price = price
    @last_add_date = day

   #  @quick_jump_roe = 1.0
  	# @quick_jump_mode =false
  	# @jump_sell_position = 0
  	# @jump_sell_price =0.0
  	# @jump_sell_date = day

  	@add_position_times =0
  	@cause = cause

  	@buy_state = :bought
  	@drop_happened = false

  	@peak_price = 0.0
  	@drop_from_peak_times=0
  	@last_jump_price = 0.0
  end

  def sell(amount,reason,day)
  	#@state = :sold

  	if @total_amount >= amount
  	  @total_amount -= amount
    else
      @total_amount = 0
    end

    @buy_state = :sold
    @sell_date = day

    @sell_reason = reason
    @sell_reason = :quick_jump_sell if reason==:"quick jump over 40%"
  end

  def add_position(price,amount,day)

  	@last_add_price = price
  	@last_add_date = day
  	@total_amount += amount

  	@add_position_times +=1

  	@quick_jump_roe = 1.0
  	@quick_jump_mode =false
  	@jump_sell_position = 0

  	@buy_state = :add_position
  	@cause = :add_position
  	@drop_happened = false

  end

  def update_peak(day,price,open)

  	#puts "#{price},#{@peak_price},#{open}  #{format_roe(@quick_jump_roe)}" if @code == '002091'
  	 if price>@peak_price
        
       old_price = @peak_price
       old_price = open

       if old_price!=0.0
	       roe = ((price - old_price)/old_price*100)

	       if (roe>=8)
		       puts "#{format_code(@code)} : quickly jump : current #{day.to_s} #{price} , jump over #{format_roe(roe)} !! " if  @show_log
		       @quick_jump_mode = true
		      
		       if open>=(@last_jump_price*0.5)
		         @quick_jump_roe = @quick_jump_roe*(1+roe/100) 
		       end
		       @last_jump_price = price

		       #puts "quick jump roe : #{format_code(@code)} on #{day.to_s} , #{format_roe(@quick_jump_roe)}"
	       end
       end

       # if @quick_jump_mode
       # 	 @quick_jump_roe = @quick_jump_roe*(1+roe) 
       # end

    	@peak_price = price
    	@peak_date = day
     else
     #  price = @peak_price
     #  old_price = rec['close']
     #  roe = ((price - old_price)/old_price*100)
  	  # puts "#{format_code(@code)} : peak #{@peak_date} ,#{@peak_price}, current #{day.to_s} #{price} , drop over #{format_roe(roe)} !! " if (roe>=15) and  @show_log
      
      #@state = :heavy_drop if rec['ma5'] < rec['ma60']
    end

  end

  def update_status(day,rec)
  	#puts "#{@code} update status..."

  	return if @last_update_day == day

  	if rec == nil
  		@stop_trade = true
  		puts "#{format_code(@code)} on #{day.to_s} not trade." if @show_log
  		return 
  	end
  	price = rec['close']
  	#old_price = @low_position['close']
  	#roe = ((price - old_price)/old_price*100)
    #puts "#{format_code(@code)} : low position #{@low_position['date']} ,#{@low_position['close']}, current #{day} #{price} , roe = #{format_roe(roe)} " if @show_log
    
    #old_price = @first_new_high
    #p old_price
  	#roe = ((price - old_price)/old_price*100)
  	#puts "#{format_code(@code)} : first new_high #{@first_nh_date} ,#{@first_new_high}, current #{day.to_s} #{price} , roe = #{format_roe(roe)} " if @show_log
    
    self.update_peak(day,price,rec['open'])

    # if (rec['new_high'] == rec['close']) and (rec['new_high_date'] = rec['date'])
    # 		  price = rec['close']
    #            old_price = @last_week_price
    #            roe = ((price - old_price)/old_price*100)
    # 		# puts "#{format_code(@code)} : new high after heavy_drop #{day.to_s} #{price} , grow #{format_roe(roe)} " if @show_log
    # 		# #return true #if roe <= 10
    # 		@state = :new_high if (roe > 5) and (@state!=:bought)
    # 		#@price_before_new_high = @last_week_price
    # end
    @state = :run_on_ma5 if rec['close'] > rec['ma5'] 
    @state = :drop_below_ma5 if (rec['close'] < rec['ma5']) and (rec['close'] > rec['ma60'])
    @state = :drop_below_ma10 if rec['close'] < rec['ma10'] and (rec['close'] > rec['ma60'])
    @state = :drop_below_ma20 if rec['close'] < rec['ma20'] and (rec['close'] > rec['ma60'])
    @state = :drop_below_ma60 if rec['close'] < rec['ma60']

   
   case @state
    when :drop_below_ma5,:drop_below_ma10,:drop_below_ma20,:drop_below_ma60
    	 @quick_jump_mode = false
	     @quick_jump_roe = 1
	    
	when :run_on_ma5
	else
	 puts "unknown state #{@state.to_s} for #{format_code(@code)} on #{day.to_s} in update_status()"
		
   end

 
    # if price<rec['ma10']
    # 	@state = :drop_below_ma10
    # end

    @last_week_price = rec['close']
    @last_update_day = day
  end	

  def should_buy?(day,rec) 
  	return false if rec==nil

    #puts "#{format_code(@code)} on #{day.to_s} at price #{rec['close']} ,#{@state.to_s},#{rec['ma5']},#{rec['ma10']}" if @buy_state==:sold

  	case @state
    when :run_on_ma5
    	# if   (@buy_state==:sold) and (rec['close'] > rec['ma5']) and (@last_week_price<rec['ma5'])#and ((day-@jump_sell_date).to_i > 60) #and (@sell_reason==:quick_jump_sell)
     #    	#if @sell_reason == :quick_jump_sell
     #          puts "found #{format_code(@code)} on #{day.to_s} at price #{rec['close']} to buy again"

     #          return true #if ((day-@sell_date).to_i > 60)
     #    	#else
     #    	  #return true
     #        #end
     #    end

      price = rec['close']
      if (price > rec['ma5']) and (rec['ma5'] > rec['ma10']) and @drop_happened
      	return true
      end

    #when :drop_below_ma5
    when :drop_below_ma10,:drop_below_ma20,:drop_below_ma5
     #    if (rec['new_high'] == rec['close']) and (rec['new_high_date'] = rec['date'])
    	# 	  price = rec['close']
     #          old_price = @last_week_price
     #          roe = ((price - old_price)/old_price*100)
    	# 	puts "#{format_code(@code)} : new high after heavy_drop #{day.to_s} #{price} , grow #{format_roe(roe)} " if @show_log
    		
     #        return false if (price<@jump_sell_price) or ((day-@jump_sell_date).to_i < 30)

    	# 	return true #if roe <= 10
    	# end
        

        #if (price<@jump_sell_price) or ((day-@jump_sell_date).to_i > 30)
        #puts "#{format_code(@code)} on #{day.to_s} at price #{rec['close']} ,#{@state.to_s},#{rec['ma5']},#{rec['ma10']}" if @buy_state==:sold

        # if   (@buy_state==:sold) and (rec['close'] > rec['ma5'])#and ((day-@jump_sell_date).to_i > 60) #and (@sell_reason==:quick_jump_sell)
        # 	#if @sell_reason == :quick_jump_sell
        #       puts "found #{format_code(@code)} on #{day.to_s} at price #{rec['close']} to buy again"

        #       return true #if ((day-@sell_date).to_i > 60)
        # 	#else
        # 	  #return true
        #     #end
        # end

     #    price = rec['close']
     #    old_price = @base_price
	    # roe = ((price - old_price)/old_price*100) 

	    # # if price<@support_price
     # #      	@support_price = price
     # #    end

	    # if (roe >= 20) and (roe<=100) and (rec['ma5']<rec['ma10'])
     #      if price<@support_price
     #      	@support_price = price
     #      end

     #      @drop_happened = true
	    # end

	    # if (rec['ma5']-rec['ma20'])/rec['ma20'] < 0.1
	    # 	@drop_happened = true
	    # end

    #when :drop_below_ma20
    when :drop_below_ma60
    	# if (rec['new_high'] == rec['close']) and (rec['new_high_date'] = rec['date'])
    	# 	  price = rec['close']
     #           old_price = @last_week_price
     #           roe = ((price - old_price)/old_price*100)
    	# 	# puts "#{format_code(@code)} : new high after heavy_drop #{day.to_s} #{price} , grow #{format_roe(roe)} " if @show_log
    	# 	# #return true #if roe <= 10
    	# 	#@state = :new_high if roe > 5
    	# 	#@price_before_new_high = @last_week_price
    	# 	return true
    	# end

    	# if (rec['ma5'] > rec['ma10']) and (@buy_state==:sold) and (rec['close'] > rec['ma5'])
    	# #if  (rec['close'] > rec['ma5'])
    	# 	 puts "found price > ma5 under ma60  #{format_code(@code)} on #{day.to_s} at price #{rec['close']} "

    	# 	return true
    	# end

    	@drop_happened = true

    	#return true

    
    else
       puts "unknown state #{@state.to_s} for #{format_code(@code)} on #{day.to_s} in should_buy?()"
    end

   return false
 end #should_buy?

  def should_add_position?(day,rec) 
  	return false if rec==nil

    price = rec['close']
	old_price = @last_add_price
	roe = ((price - old_price)/old_price*100) 
    
    #puts  "in should_add_position #{format_code(@code)} on #{day.to_s} ,state =  #{@state.to_s}, price=#{rec['close']},ma5=#{rec['ma5']},ma10=#{rec['ma10']}" if @code=='002185'
  	case @state
    when :run_on_ma5
    	puts "#{format_code(@code)} on #{day.to_s} ,state =  #{@state.to_s}, drop_happened,price=#{rec['close']},ma5=#{rec['ma5']},ma10=#{rec['ma10']}" if @drop_happened
    	if (roe >= 25) and (@add_position_times<2) and (rec['ma5']>rec['ma10']) and (@buy_state==:bought) and (rec['close'] > rec['ma5']) and @drop_happened
     		return true 
     	 end
    when :drop_below_ma5
    when :drop_below_ma10,:drop_below_ma20
    	 price = rec['close']
         old_price = @last_add_price
         roe = ((price - old_price)/old_price*100) 	

        if (roe >= 25) and (@add_position_times<2) and  (@buy_state==:bought)  
          @drop_happened = true
        end

     	 # if (roe >= 25) and (@add_position_times<2) and (rec['ma5']>rec['ma10']) and (@buy_state==:bought) and (rec['close'] > rec['ma5']) 
     		# return true
     	 # end
    
      when :drop_below_ma60
      when :new_high
    else
       puts "unknown state #{@state.to_s} for #{format_code(@code)} on #{day.to_s} in should_add_position?()"
  	return false
 
    end

  end



  def should_sell?(day,rec) 
  	return :hold if rec==nil

  	case @buy_state
   
    when :bought,:add_position
         price = rec['close']
         old_price = @last_add_price
         roe = ((price - old_price)/old_price*100) 	

        
         # if (roe<5) and (@cause==:new_high)
         # 	return :"roe < 5 after new high "
         # end

         # if (roe<5) and (@cause==:drop_after_new_high)
         # 	return :"roe < 5 after drop state"
         # end

         # old_price = @last_add_price
         # roe = ((price - old_price)/old_price*100) 	
         # if (roe<-8) and (@cause==:drop_after_new_high)
         # 	return :"roe < -8 after adding position"
         # end          

         if (roe<10) and ((day-@last_add_date).to_i > 31 )
         	return :"roe < 10 in 1 month"
         end

         # if (roe<30) and ((day-@last_add_date).to_i > 91 ) and (@add_position_times==0)
         # 	return :"roe < 30 in 3 month"
         # end

         #  if (roe<60) and ((day-@last_add_date).to_i > 181 )
         # 	return :"roe < 60 in 6 month"
         # end

         # if (rec['ma5'] < rec['ma20'])/rec['ma20'] < -0.02
         #   return :"ma5 < ma20        "
         # end

          #  if (rec['ma5'] < rec['ma20']) and ((day-@last_add_date).to_i > 31 ) 
          #   return :"ma5 < ma20        "
          # end

          #  if (rec['close'] - rec['open'])/rec['open'] > 0.15 
          #   return :"jump over 15%        "
          # end

         if @quick_jump_mode
         	if (@quick_jump_roe >= 1.4) #and ((rec['high']-rec['close'])/rec['high']*100>8)

         		return :"quick jump over 40%"
         		@jump_sell_position = @total_amount
         		@jump_sell_price = price
         		@jump_sell_date = day
         	end
         end

         # old_price = rec['high']
         # roe = ((old_price - price)/old_price*100) 

         # if (roe>=10) #and (@quick_jump_roe>1.2)
         # 	@drop_from_peak_times+=1
         # end

         # if @drop_from_peak_times ==2
         # 	return :"2nd drop from peak over 10%"
         # end


         # if @add_position_times>0
         # 	 old_price = @last_add_price
         #     roe = ((price - old_price)/old_price*100) 	

         #     #if rec['ma5'] < rec['ma20']
         #     if (rec['ma5'] - rec['ma20'])/rec['ma20'] < -0.02
         #     	return :"ma5 < ma20 after add_position"
         #     end

         #      if roe <= -10
         #     	return :"price drop over 10% after add_position"
         #     end

         # end

         return :hold
    when :sold
    when :empty_position
    else
      puts "unknown #{format_code(rec['code'])} buy_state #{@buy_state.to_s} on #{day.to_s} in should_sell?()"
    end
  	return :hold

  end #should_sell?

  def search_low_positon(code,day)
  	 # p code, day
  	 w_list = Weekly_records.find(:all, :conditions=>"code = \'#{code}\'", :order=>"id asc")

  	 #p w_list.length

  	 ind = w_list.find_index{|rec| rec['date'] == day}
  	 # p w_list[ind]['date'] 

  	 new_high_date=w_list[ind]['new_high_date']
  	 i=1
  	 while (ind>i) and (new_high_date - w_list[ind-i]['new_high_date']).to_i < 155
  	 	new_high_date = w_list[ind-i]['new_high_date']
  	 	i+=1
  	 end
  	 
     if ind!=i
	  	 new_date = w_list[ind-i+1]['date']
	  	 price = w_list[ind-i+1]['close']
	  	 puts "#{format_code(code)} #{day.to_s} first new new_high_date = #{new_date},price = #{price}" if @show_log
	  	 @first_new_high = price
	  	 @first_nh_date=new_date
	  	  old_price = w_list[ind-i]['close']
	  	 @first_nh_roe = ((price - old_price)/old_price*100)

	  	  if @first_nh_roe >20
	  	    puts "#{format_code(code)} #{day.to_s} first new new_high_date = #{new_date},price = #{price} roe=#{format_roe(@first_nh_roe)} !!" if @show_log
	  	  end
         low_price = price
     else
     	 low_price = w_list[ind]['close']
     	 i=1
     end
     #i=1
  	 while (low_price >= w_list[ind-i]['close']) or (low_price >= w_list[ind-i-1]['close']) #or (w_list[ind-i]['close'] > w_list[ind-i]['open'])
  	 	low_price = w_list[ind-i]['close']
  	 	i+=1
  	 end

  	 @bottom_date = w_list[ind-i+1]['date']
  	 @bottom_price = w_list[ind-i+1]['close']

    return w_list[ind-i+1]

  end

end