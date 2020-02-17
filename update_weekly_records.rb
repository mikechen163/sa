$LOAD_PATH.unshift(File.dirname(__FILE__)) unless $LOAD_PATH.include?(File.dirname(__FILE__))  
 

require "shared_setup"
require 'time'
require 'active_record'
require 'common'
require 'asset'
require 'min_list'
require 'simrun'

require 'tushare_interface'
require 'json'

require 'basic_value_analysis'

# def find_number_of_record(l,date)

#   #p date
#    tl = l.reverse
#    pos= 1
#   tl.each do |day|
#      return pos if day<= date 
#      pos += 1
#    end
# end

# def update_weekly_records()

#   # start analysis
     

#     Names.get_code_list.each do |code|

#        #code = '300104'
#        puts "Updating weekly data : #{code}"
       
#        sa = []
#        state_list = []
#        # check last (n+2) records. n = 18
#        w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"id asc")

#        len= w_list.length 
#        next if len < 60+12

#        week_list =  w_list.collect{|row| row['close']} 
#        open_list =  w_list.collect{|row| row['open']} 
#        id_list   =  w_list.collect{|row| row['id']}  
#        date_list   =  w_list.collect{|row| row['date']} 
#        #p week_list.length

#        #p week_list

#        ma5_list = ma(week_list,5)
#        ma10_list = ma(week_list,10)
#        ma20_list = ma(week_list,20)
#        ma60_list = ma(week_list,60)

#        diff_list = make_diff_list(week_list,26,12)
#        dea_list,macd_list = make_dea_macd_list(week_list,26,12,9,diff_list)

#        #p ma60_list.length

#        support_price = 0
#        min = 0
       

#        week_list.each_with_index do |price,i|

#          ma5=0.0 
#          ma5=ma5_list[i-4] if i>=4
#          ma10=0.0 
#          ma10=ma10_list[i-9] if i>=9
#          ma20=0.0 
#          ma20=ma20_list[i-19] if i>=19
#          ma60=0.0 
#          ma60=ma60_list[i-59] if i>=59
#          diff=0.0 
#          diff=diff_list[i-25] if i>=25
#          dea=0.0 
#          dea=dea_list[i-33] if i>=33
#          macd=0.0
#          macd=macd_list[i-33] if i>=33

#          m_state = 0 # default is bear market

#          # 0   : bear market , don't buy stock
#          # 128 : bull market , shake in low price. best buying point
#          # 129 : bull market , new high , pay attention to urgent grow 
#          # 130 : bull market , but now in shake mode, so box operation is best

#          if i>=(59+13-1)  # there exist ma60

#            #p i
#            #p ma60[i-59]
#            #p ma60[i-59-12]
#             m_state = state_list[i-1]
#             case m_state
#             when 0 
#               if  check_ma60_state(ma60_list[i-59],ma60_list[i-59-12] )
#                  if (ma5 - ma60 ) > 0
#                     m_state = 128   
#                  end
#               end
#               # bear market begin here ...
#             when 1 
#               if  not check_ma60_state(ma60_list[i-59],ma60_list[i-59-12] )
#                 m_state = 0
#               end 
#               # shake in low position
#             when 128 
#                #p date_list[i]
#                #p week_list[i]
#                num = find_number_of_record(date_list[0..i-2],date_list[i]-52*7)
#                #p num
#                max = find_max(week_list[0..i-2],num)
#                # p i
#                # p week_list[i]
#                # p max
#                # p week_list[i-1]


#                if min !=0 
#                      m_state = 129    if (week_list[i-1] > 3 *min)                    
#                else
#                  if (week_list[i] > week_list[i-1] ) and (week_list[i-1] > max )
               
#                   num = find_number_of_record(date_list[0..i-2],date_list[i]-52*7)
#                   min = find_min(week_list[0..i-1],num)

#                   m_state = 129   if (week_list[i-1] > 3 *min)    
#                   end
#               end
               

#               # if (week_list[i] > week_list[i-1] ) and (week_list[i-1] > max )
#               #   m_state = 129    
#               # end
             


#               # if ma20 < ma60
#               #   m_state = 1
#               # end
#               # new high price mode

#               if  not check_ma60_state(ma60_list[i-59],ma60_list[i-59-12] )
#                 m_state = 0
#               end 

#             when 129 
#                #if (week_list[i]<ma5[i]) and (week_list[i-1]<ma5[i-1]) and  (week_list[i-2]<ma5[i-2])
#                #if (week_list[i] < week_list[i-1] ) and (week_list[i-1] < week_list[i-2] )
#                 #if (week_list[i] < week_list[i-1] )
#                 #if (week_list[i] - open_list[i]) < -0.5
#                 if (ma5-ma10)/ma10<-0.01
#                  m_state = 130 
#                  support_price = week_list[i] if support_price == 0 
#                end
#                # shake in high position, select direction again
#             when 130 
#                num = find_number_of_record(date_list[0..i-2],date_list[i]-52*7)
#                #p num
#                max = find_max(week_list[0..i-2],52)
#               if (week_list[i] > week_list[i-1] ) and (week_list[i-1] > max )
#                 m_state = 129
#               end 

#               if (0 - (week_list[i]-support_price)/support_price)> 0.08
#                 m_state = 1
#               end  

#               if  not check_ma60_state(ma60_list[i-59],ma60_list[i-59-12] )
#                 m_state = 0
#               end 
          
#               if (week_list[i] > week_list[i-1] ) and (week_list[i-1] < week_list[i-2] )
#                 support_price = week_list[i-1] if support_price > week_list[i-1]
#               end 

#               support_price = week_list[i] if support_price > week_list[i]

                
               
#             else puts "unknow state #{m_state}"
#             end #end of case 

         

#          end 

#          ts = "ma5=#{ma5},ma10=#{ma10},ma20=#{ma20},ma60=#{ma60},diff=#{diff},dea=#{dea},macd=#{macd},market_state=#{m_state} where id = #{id_list[i]}"
         
#          #p ts
#          sa.push(ts)
#          state_list.push(m_state)

#        end    

#        update_data('weekly_records',sa)
    
#        #break;
#     end # end of code 
# end

def is_shaking?(l,v)
   
  len = l.length
  return false if l.length == 0 
  # l[1..len-1].each_with_index do |x,i|
  return true if (l[len-1]-v)/l[len-1] > 0.08
  # end
   
  max = l.inject(0) {|r,x|  (x > r) ? x : r }
  return true if (max-v)/max >= 0.2  

  return false
end

# def find_number_of_record(l,date)

#   #p date
#    tl = l.reverse
#    pos= 1
#   tl.each do |day|
#      return pos if day<= date 
#      pos += 1
#    end
# end
# def get_52week_high(week_list,date_list,i)
   
#    num = find_number_of_record(date_list[0..i-1],date_list[i]-52*7)
#    return  find_max(week_list[0..i-1],num)
# end


def update_weekly_records2
  Names.get_code_list.each do |code|
    update_weekly_record(code)
    #break
  end
  
  # update_weekly_record('399905')
  # update_weekly_record('000300')
end

def ema(x,n,p)
  return (x*2+(n-1)*p)/(n+1)
end

def update_weekly_record(code)

       puts "Updating weekly data : #{code}"
       
       sa = []
       state_list = []

       new_high = false
       max = 0
       # check last (n+2) records. n = 18
      # w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"id asc")
      
       #t1= Time.now
       w_list = Weekly_records.where(code:"#{code}")
       # t2= Time.now
      


       len= w_list.length 
       #p len
       return if len < 60+12

       week_list =  w_list.collect{|row| row['close']} 
       volume_list =  w_list.collect{|row| row['volume']} 
       open_list =  w_list.collect{|row| row['open']} 
       high_list =  w_list.collect{|row| row['high']} 
       low_list =  w_list.collect{|row| row['low']} 
       id_list   =  w_list.collect{|row| row['id']}  
       date_list   =  w_list.collect{|row| row['date']} 
       #p week_list.length

       #p week_list

       ma5_list = ma(week_list,5)
       ma10_list = ma(week_list,10)
       ma20_list = ma(week_list,20)
       ma60_list = ma(week_list,60)

       ma5_vlist = ma(volume_list,5)
       ma10_vlist = ma(volume_list,10)

       # if (len>=60+12)
       #   diff_list = make_diff_list(week_list,26,12)
       #   dea_list,macd_list = make_dea_macd_list(week_list,26,12,9,diff_list)
       # end

       ema_short_list = []
       ema_long_list  = []
       diff_list=[]
       dea_list=[]
       macd_list=[]
       week_list.each_with_index do |price,i|
         if i==0
          ema_long_list[i]=price
          ema_short_list[i]=price
         else
         #  ema_short_list[i]=ema_short_list[i-1]*11.0/13 + 2.0/13*price
         #  ema_long_list[i]=ema_long_list[i-1]*25.0/27 + 2.0/27*price
            ema_short_list[i]=ema(price,$macd_p[0],ema_short_list[i-1])
            ema_long_list[i]=ema(price,$macd_p[1],ema_long_list[i-1])
           
         end
         diff_list[i]=ema_short_list[i]- ema_long_list[i]

         if i==0
          dea_list[i]=diff_list[i]
         else
          #dea_list[i]=dea_list[i-1]*8.0/10+diff_list[i]*2.0/10
          dea_list[i]=ema(diff_list[i],$macd_p[2],dea_list[i-1])
         end

         macd_list[i]=2*(diff_list[i]-dea_list[i])
       end

       #p ma60_list.length

       support_price = 0
       min = 0
       pos = 0
       support_price_list = []
       bull_market_times = 0

       new_low=10000
       new_high=0.0
       new_high_date=new_low_date=date_list[0]


       week_list.each_with_index do |price,i|

         ma5=0.0 
         ma5=ma5_list[i-4] if i>=4
         ma10=0.0 
         ma10=ma10_list[i-9] if i>=9
         ma20=0.0 
         ma20=ma20_list[i-19] if i>=19

         ma5_vol=0.0 
         ma5_vol=ma5_vlist[i-4] if i>=4
         ma10_vol=0.0 
         ma10_vol=ma10_vlist[i-9] if i>=9

         ma20_3m_before=0.0 
         ma20_3m_before=ma20_list[i-(19+13)] if i>=(19+13)

         ma60=0.0 
         ma60=ma60_list[i-59] if i>=59

         ma60_3m_before=0.0 
         ma60_3m_before=ma60_list[i-(59+13)] if i>=(59+13)
         ma60_6m_before=0.0 
         ma60_6m_before=ma60_list[i-(59+26)] if i>=(59+26)

         # diff=0.0 
         # diff=diff_list[i-25] if i>=25
         # dea=0.0 
         # dea=dea_list[i-33] if i>=33
         # macd=0.0
         # macd=macd_list[i-33] if i>=33

         diff=diff_list[i]
         dea=dea_list[i]
         macd=macd_list[i]

         m_state = 0 # default is bear market
         days_in_state = i-pos

         up = ""
         

         new_high,new_high_date = get_52week_high(week_list,date_list,i,true) if i>53
         
         #puts  "current = #{date_list[i].to_s}:#{week_list[i]}, new_high = #{new_high_date.to_s}:#{new_high}"
         if week_list[i] > new_high
           new_high = week_list[i] 
           new_high_date=date_list[i]
           up = " UPDATING"
         end 
         #puts  "current = #{date_list[i].to_s}:#{week_list[i]}, new_high = #{new_high_date.to_s}:#{new_high}"+up
         #p new_high,new_high_date
         
         new_low,new_low_date = get_52week_low(week_list,date_list,i,true)    if i>53
         
         #puts  "current = #{date_list[i].to_s}:#{week_list[i]}, new_low = #{new_low_date.to_s}:#{new_low}"
        
         up=""
         if week_list[i] < new_low

           new_low = week_list[i] 
           new_low_date=date_list[i]
           up = " UPDATING"
         end 
         #puts  "current = #{date_list[i].to_s}:#{week_list[i]}, new_low  = #{new_low_date.to_s}:#{new_low}"+up
         # p new_low
         # p new_low_date
         # if week_list[i] > new_high
         #   new_high=week_list[i]
         #   new_high_date=date_list[i]
         # end


         # if week_list[i] < new_low
         #   new_low=week_list[i]
         #   new_low_date=date_list[i]
         # end



      

         # 0   : init value.
         # 1   : bottom state, ma60 should like a like 

         #       bear market , don't buy stock
         # 128 : bull market , shake in low price. best buying point
         # 129 : bull market , new high , pay attention to urgent grow 
         # 130 : bull market , but now in shake mode, so box operation is best

         if i>=(59+13)  # there exist ma60

           #p i
           #p ma60[i-59]
           #p ma60[i-59-12]
            m_state = state_list[i-1]
            case m_state
              # now in bear market
            when 0 
              #if  check_ma60_state(ma60_list[i-59],ma60_list[i-59-13] )
              if (not bear_market?(ma60,ma60_3m_before)) and (not start_bear_market?(ma20,ma20_3m_before)) and ((ma60-ma60_3m_before)/ma60_3m_before<0.1)
               #exit from bear market

                # if  (not bull_market?(ma20,ma20_3m_before))
                #     m_state = 1 
                # else
                #     m_state =3
                # end

                m_state = 1
                pos = i
              end
             
              # bottom state
            when 1 

               # if not new_high
               #   max = get_52week_high(week_list,date_list,i)
               #   if week_list[i] > max
               #      new_high = true
               #   end
               # else
                  if  is_shaking?(week_list[i-26..i-1],week_list[i])
                    m_state = 2
                    pos = i
              #      new_high = false
                    #max = 0
                  end
               # end


                max = get_52week_high(week_list,date_list,i-1)
               # p date_list[i]
               # p max
               if (week_list[i] > max) and (week_list[i-1] > max)
                     
                       m_state = 3
                    
                      #new_high = false
                      support_price = week_list[i-1]

                     pos = i
                     bull_market_times += 1
                end

              # if bull_market?(ma20,ma20_3m_before)
              #    m_state =3 
              #  end

               if start_bear_market?(ma20,ma20_3m_before)
                 m_state = 0
                 pos = i
               end 
              # check if bull state begin ?
            when 2
               # if bull_market?(ma20,ma20_3m_before)
               #   m_state =3 
               # end

               max = get_52week_high(week_list,date_list,i-1)
               # p date_list[i]
               # p max
               #if (week_list[i] > week_list[i-1]) and (week_list[i-1] > max)
               if (week_list[i] > max) and (week_list[i-1] > max)
                    
                       m_state = 3
                    
                      #new_high = false
                      support_price = week_list[i-1]

                     pos = i
                     bull_market_times += 1
                end

               # if not new_high
               #   max = get_52week_high(week_list,date_list,i)
               #   if week_list[i] > max
               #      new_high = true
               #   end
               # else
               #    if ((w_list[i]['close'] - w_list[i]['open'])/w_list[i]['open'] > 0.02) and (w_list[i-1]['close'] < w_list[i-1]['open']) 
               #     if (week_list[i] > max) 
               #   #if bull_market?(ma20,ma20_3m_before)
               #        m_state = 3
               #        new_high = false
               #        support_price = week_list[i-1]

               #        pos = i
               #        #max = 0
               #     end 
               #   end
               # end

                
                  



               # if start_bear_market?(ma20,ma20_3m_before)
               #   m_state = 0
               # end 

               # enter bull state
            when 3

               
                #if ((ma10 - ma5) / ma10 > 0.0 ) #or  
                #if (week_list[i] < ma20_list[i-19]) and (week_list[i-1] < ma20_list[i-20]  )
                if (week_list[i] < ma20_list[i-19]) and (week_list[i-1] < ma20_list[i-20]  )
            
                #if (not bull_market?(ma10,ma10_list[i-9-13]))
                 #if i-pos > 13 # at least last for 13 weeks 
                 if ((week_list[i]-support_price)/support_price > 0.5) and (i-pos >= 13)
                   m_state =4
                 else
                  m_state =6
                 end

                  pos = i
                end

              
               # max = get_52week_high(week_list,date_list,i)
            
               # if (week_list[i] > max)
                
               #        support_price_list.push(week_list[i])
               #        support_price_list.sort!
               #        support_price_list.reverse!
               #  else
               #    tl = support_price_list
               #    tl.each |num|
               #       support_price_list.shift if week_list[i] < support_price_list[0]
               #    end
               #  end

                 #if  is_shaking?(week_list[i-26..i-1],week_list[i])
              #    if ((ma5-ma10)/ma10<0.04)
              #       m_state = 7
              #       pos = i
              # #      new_high = false
              #       #max = 0
              #     end
                #puts " #{date_list[i]} support_price = #{support_price}, current = #{week_list[i]}"
                # if (week_list[i] < support_price) and (week_list[i-1] < support_price) 
                #     m_state = 2
                # end


                # exit from bull state
            when 4
   
                 
                 if start_bear_market?(ma20,ma20_3m_before)
                  m_state = 0
                  pos = i
                 end

                 if  is_shaking?(week_list[i-26..i-1],week_list[i])
                 m_state = 5
                 pos = i
                 end
            
                # bull market start again ? not a chance
               # if bull_market?(ma20,ma20_3m_before)
               #   m_state =3 
               # end

            when 5
               if start_bear_market?(ma20,ma20_3m_before)
                 m_state = 0
                 pos = i
               end 

               # if bull_market?(ma20,ma20_3m_before)
               #   m_state =3 
               # end 


               max = get_52week_high(week_list,date_list,i-1)
               if (week_list[i] > max) and (week_list[i-1] > max)
                    
                       m_state = 3
                    
                      #new_high = false
                      support_price = week_list[i-1]

                     pos = i
                     bull_market_times += 1
                end

               # if not new_high
               #   max = get_52week_high(week_list,date_list,i)
               #   if week_list[i] > max
               #      new_high = true
               #   end
               # else

               #     if ((w_list[i]['close'] - w_list[i]['open'])/w_list[i]['open'] > 0.02) and (w_list[i-1]['close'] < w_list[i-1]['open']) 
               #     if (week_list[i] > max) 
               #  # if bull_market?(ma20,ma20_3m_before)
               #        m_state = 3
               #        new_high = false
               #        support_price = week_list[i-1]

               #        pos =i
               #     end 
               #   end
                 #puts " #{date_list[i]} support_price = #{support_price}, current = #{week_list[i]}"

               #end

              


            when 6
              max = get_52week_high(week_list,date_list,i-1)
               # p date_list[i]
               # p max
               #if (week_list[i] > week_list[i-1]) and (week_list[i-1] > max)
               if (week_list[i] > max) and (week_list[i-1] > max)
                     if bull_market_times == 0
                       m_state = 3
                     else
                       m_state= 8
                     end
                      #new_high = false
                      support_price = week_list[i-1]

                     pos = i 
                     bull_market_times += 1
                end
               
                #shaking in bull state
              when 7
                  if ((ma10 - ma5) / ma10 > 0.01 ) #or  
            
                #if (not bull_market?(ma10,ma10_list[i-9-13]))
                 #if i-pos > 13 # at least last for 13 weeks 
                 if ((week_list[i]-support_price)/support_price > 0.5) and (i-pos >= 13)
                   m_state =4
                 else
                  m_state =6
                 end

                  pos = i
                end


                 max = get_52week_high(week_list,date_list,i-1)
               # p date_list[i]
               # p max
               #if (week_list[i] > week_list[i-1]) and (week_list[i-1] > max)
               if (week_list[i] > max) and (week_list[i-1] > max)
                    
                       m_state = 3
                    
                      #new_high = false
                      support_price = week_list[i-1]

                     pos = i 
                     bull_market_times += 1
                end

            when 8
                  if ((ma10 - ma5) / ma10 > 0.01 ) #or  
            
                #if (not bull_market?(ma10,ma10_list[i-9-13]))
                 #if i-pos > 13 # at least last for 13 weeks 
                 if ((week_list[i]-support_price)/support_price > 0.5) and (i-pos >= 13)
                   m_state =4
                 else
                  m_state =6
                 end

                  pos = i
                end

               
            else puts "unknown state #{m_state}"
            end #end of case 

         

         end 

         ts1 = "ma5=#{ma5},ma10=#{ma10},ma20=#{ma20},ma60=#{ma60},ma20_3m_before=#{ma20_3m_before},ma60_3m_before=#{ma60_3m_before},ma60_6m_before=#{ma60_6m_before},ma5_vol=#{ma5_vol},ma10_vol=#{ma10_vol}"
         ts2 =",diff=#{diff},dea=#{dea},macd=#{macd},market_state=#{m_state},days_in_state=#{days_in_state},support_price=#{support_price}"     
         ts3 =",new_high=#{new_high},new_low=#{new_low},new_high_date=date(\'#{new_high_date}\'),new_low_date=date(\'#{new_low_date}\')" 
         #p ts3
         ts_end = "where id = #{id_list[i]}"

         ts = ts1+ts2+ts3+ts_end
         
         #p ts
         sa.push(ts)
         state_list.push(m_state)

       end    

       #t3= Time.now
       update_data('weekly_records',sa)
       #t4= Time.now

       #p "fetch:#{t2-t1}, calulating:#{t3-t2}, update:#{t4-t3}, total:#{t4-t1}"
 
end

def get_market_str(state)
  return "bear market            " if state == 0
  return "bottom state           " if state == 1
  return "shaking in bottom      " if state == 2
  return "bull start first time  " if state == 3
  return "exit from bull         " if state == 4
  return "shaking after bull     " if state == 5
  return "shaking after new high " if state == 6
  return "shaking in bull state  " if state == 7
  return "bull state start again " if state == 8
  return "unknown state #{state} "

end

def display_stock_states(code,info)
  
      old_market_state = 0
      old_ratio = 0
      v_state = false
      buy_price = 0.0

       # check last (n+2) records. n = 18
       w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"id asc")
       start_date = w_list[0]['date']

       #puts ""
       new_high=new_low=0
       new_high_date=new_low_date=nil
       w_list.each_with_index do |rec,i|

         case info
         when 1
         market_state = rec['market_state']
         if market_state != old_market_state
            
           puts "#{Names.get_name(code)}(#{code}) turn in #{get_market_str(market_state)} at #{rec['date']}" 
           old_market_state = market_state
         end

         when 2

         if new_high!=rec['new_high']
          #puts "found new high at #{rec['date']} : #{rec['close']} ,new_high on #{rec['new_high_date']} #{rec['new_high']}, previous new high on #{new_high_date} : #{new_high}"
          puts "found new high at #{rec['date']} : #{rec['close']} ,new_high on #{rec['new_high_date']} #{rec['new_high']}"
         
          new_high = rec['new_high']
          new_high_date=rec['date']
         end

         if new_low!=rec['new_low']
          puts "found new low at #{rec['date']} : #{rec['close']} ,new_low on #{rec['new_low_date']} #{rec['new_low']}"
          new_low = rec['new_low']
          new_low_date=rec['date']
         end

       when 3
           ratio =0.0

          ratio = (rec['ma5_vol']-rec['ma10_vol'])/rec['ma10_vol'] if rec['ma10_vol'] >0

          diff = ratio - old_ratio

          #puts "on #{rec['date'].to_s} ratio= #{format_roe(ratio)} diff = #{format_roe(diff)} "
         if (ratio > 0.3) and v_state == false and (diff > -0.001)
           buy_price = rec['close']
           puts "buy  on #{rec['date'].to_s} at price #{buy_price}"
           v_state = true
         end

         if (ratio < 0.3) and v_state
          price = rec['close']
          roe = (price-buy_price)/buy_price*100
          puts "sell on #{rec['date'].to_s} at price #{price} , roe = #{format_roe(roe)}" 
          v_state = false
          old_ratio = 0.0

         end

         old_ratio = ratio
       when 4
           ratio =0.0

          ratio = (rec['ma5_vol']-rec['ma10_vol'])/rec['ma10_vol'] if rec['ma10_vol'] >0

         if (rec['diff']>rec['dea']) and v_state == false and (ratio>0.2) and (rec['ma20']>rec['ma60'])
           buy_price = rec['close']
           puts "buy  on #{rec['date'].to_s} at price #{buy_price}"
           v_state = true
         end

          price = rec['close']
          roe = (price-buy_price)/buy_price*100
        if ((rec['diff']<rec['dea']) or (roe<0)) and v_state
          #price = rec['close']
          #roe = (price-buy_price)/buy_price*100
          puts "sell on #{rec['date'].to_s} at price #{price} , roe = #{format_roe(roe)}" 
          v_state = false
         end


       else
        puts "unknown info #{info}"
       end #case

       end
    
end


def find_state(state,date = nil)
  

     date = Weekly_records.find(:all, :conditions=>" code = \'600036\'", :order=>"id asc").last['date'] if date == nil
     w_list = Weekly_records.find(:all, :conditions=>" market_state = #{state}  and date = date(\'#{date.to_s}\')", :order=>"id asc")
       # check last (n+2) records. n = 18
    
      w_list.each do |rec|
       code = rec['code']
       puts "#{code} in #{get_market_str(state)}" 
    end # of each code
end


def calc_new_number(l)
   b_n = 0
   m_n = 0
   s_n = 0

   l.each do |rec|
      case rec['code'][0..1]
      when '60' 
        b_n += 1
      when '00'
       m_n += 1
      when '30' 
        s_n += 1
      end
   end

   return b_n,m_n,s_n
end

def max(a,b)
  (a>b) ? a : b
end

def make_new_list(l,obn,omn,osn,total_amount)
  b_n,m_n,s_n = calc_new_number(l)

  len = l.length
  b_list = l[0..b_n-1]
  m_list = l[b_n..(b_n+m_n-1)]
  s_list = l[(b_n+m_n)..len-1]

  s_n *=3
  nl = []
  #nl += b_list if (b_n >= obn) and (b_n > 10)
  #nl += m_list if (m_n >= omn) and (m_n > 10)
  #nl += s_list if (s_n >= osn) and (s_n > 10)
  mx = max(b_n,max(m_n,s_n))

  nl = b_list if (b_n == mx) 
  nl = m_list if (m_n == mx) 
  nl = s_list if (s_n == mx) 
  #p nl

  np_list = nl.collect{|x| x['close']}
  nc_list = nl.collect{|x| x['code']}
  #p nc_list
  na_list = np_list.collect {|x| (total_amount/(x*100)).floor*100 }

  return nc_list,np_list,na_list


end


def get_buying_list(w_list1,day)
   #w_list1 = Weekly_records.find(:all, :conditions=>" date = date(\'#{day.to_s}\')", :order=>"id asc")
   w_list2 = Weekly_records.find(:all, :conditions=>" date = date(\'#{(day-1).to_s}\')", :order=>"id asc")
   w_list3 = Weekly_records.find(:all, :conditions=>" date = date(\'#{(day-2).to_s}\')", :order=>"id asc") 

   sa=[]
   w_list1.each_with_index do |rec,i|
      if (w_list1[i]['ma5'] > w_list2[i]['ma5']) and (w_list2[i]['ma5'] < w_list3[i]['ma5']) 
        sa.push(w_list1[i]['code'])
      end
   end   

end

#persuit new stragegy, not a good choice
def test_drive(asset)
  

     date_list = Weekly_records.find(:all, :conditions=>" code = \'600036\'", :order=>"id asc").last(200).collect{|x| x['date']}
       # check last (n+2) records. n = 18
    
     last_day_money = 100000000.0

     old_len = 0
     old_big_num = 0
     old_middle_num = 0
     old_small_num =0

      date_list.each do |day|

        #p day
        gmv = 0
        pl_list = []
        cl_list =asset.get_code_list

        #p cl_list
        if cl_list.length >0 
          w_list = Weekly_records.find(:all, :conditions=>"date = date(\'#{day.to_s}\')", :order=>"id asc")
             pl_list = cl_list.collect do |code|
                 rec = w_list.find {|x| x['code'] == code}

                  h=Hash.new
                  h[:code ] = code 

                 if rec
                     h[:price] = rec['close'] 
                 else
                     h[:price] = asset.get_price(code)
                 end
                 h
             end

          #gmv = asset.get_gmv(pl_list)
        end


        
        w_list = Weekly_records.find(:all, :conditions=>" market_state = 3  and date = date(\'#{day.to_s}\')", :order=>"id asc")
        next if  w_list.length == 0



        big_num,middle_num,small_num = calc_new_number(w_list)

        # p w_list.length
        # w_list.delete_if do |rec|
        #   if cl_list.find{|x| x == rec['code']}
        #     false
        #   else
        #     if get_buying_list(w_list,day).find{|x| x == rec['code']}
        #       false
        #     else
        #       true
        #     end 
        #   end
       
        # end
        # p w_list.length
        
        code_list  = w_list.collect{|rec| rec['code']}
        price_list = w_list.collect{|rec| rec['close']}
        date_list = w_list.collect{|rec| rec['date']}
        len = w_list.length

        print big_num,' ',middle_num,' ',small_num,' '


        #p pl_list.length
        asset.sell_all(day,pl_list)
        #p asset.get_code_list
        #asset.show_log
        total_money = asset.get_current_money

        printf "%s, total rate = %.2f ,inc rate = %s ,last week = %.2f , this week = %.2f , num = %d \r\n",day.to_s,total_money/100000000,format_roe( (total_money-last_day_money)/last_day_money),last_day_money,total_money,len

        last_day_money = total_money


        
        #len = 20
        total_amount = total_money/len
        #p "dfffffffffff"
        #p len
        #p total_amount
        #p price_list
        amount_list = price_list.collect {|x| (total_amount/(x*100)).floor*100 }
        #p amount_list

        #if (len > old_len)
        # nc_list,np_list,na_list = make_new_list(w_list,old_big_num,old_middle_num,old_small_num,total_amount)
        #   nc_list.each_with_index do |code,i|
        #     asset.buy(code,day,np_list[i],na_list[i])
        #   end
        #end

        #if len > old_len+5
          code_list.each_with_index do |code,i|
             asset.buy(code,day,price_list[i],amount_list[i])
          end
        #end

        old_len = len
        
        old_big_num = big_num
        old_middle_num = middle_num
        old_small_num =small_num


        #asset.show_log
        asset.clear_log

    end # of each day
end

# def get_price_list(cl_list, w_list,asset,old_pl_list)
#   pl_list = cl_list.collect do |code|
#                  rec = w_list.find {|x| x['code'] == code}

#                   h=Hash.new
#                   h[:code ] = code 

#                  if rec
#                      h[:price] = rec['close'] 
#                  else
#                      #h[:price] = asset.get_price(code)
#                      x = old_pl_list.find {|x| x[:code] == code}
#                      if x!=nil
#                         h[:price] = x[:price]
#                      else
#                         h[:price] = asset.get_price(code)
#                      end
#                  end
#                  h
#              end

#     return pl_list
# end

def get_pos(code,m_list)
   pos = 0
   while m_list[pos]['code']!= code
     pos += 1
   end

   pos2 =pos
   while m_list[pos2]['code']== code
     pos2 += 1
   end

   return pos,pos2-1
end

# def get_unit_amount(code_list,total_money)

#   len = code_list.length
#   return 0 if len == 0
#   return total_money/len
# end

def get_new_stock_list(clist,asset,day,total_money)
       ma60_look_ahead = 26

       code_list =[]
       price_list = []
       amount_list = []

      
      unit_amount = total_money/50.0


      left_money = asset.get_current_money

       if left_money < unit_amount
         return code_list,price_list,amount_list 
       end


       #p code
       c_list = asset.get_code_list
       #p "sssss"

       #d1 = Weekly_records.get_new_date(day,29)

        clist.each do |code|
          next if c_list.find {|x| x == code} 
        
           w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\' and date <= date(\'#{day.to_s}\')", :order=>"id asc").last(3)
          next if w_list.length!=3
          
          if (w_list[2]['ma5'] > w_list[1]['ma5']) and (w_list[1]['ma5'] < w_list[0]['ma5'])
                         price = w_list[2]['close']
                         code_list.push(code)
                         price_list.push(price)


                          am = (unit_amount/(price*100)).floor*100
                         amount_list.push(am)

                         left_money -= am*price
                       
                          if left_money< unit_amount #buy 20 stock at the most
                             return code_list,price_list,amount_list
                         end
          end
    
        end

        # unit_amount = get_unit_amount(code_list,asset.get_current_money)
        # amount_list= price_list.collect {|price|  (unit_amount/(price*100)).floor*100}
        

        return code_list,price_list,amount_list 

       
       # the follow no use any more
       clist.each do |code|
           #p code
          

           next if c_list.find {|x| x == code} # if stock already in portfilo, no need to check.

           w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\' and date <= date(\'#{day.to_s}\')", :order=>"id asc").last(ma60_look_ahead+3)

           # p1,p2 = get_pos(code,m_list)
           # w_list = m_list[p1..p2]


           #p w_list
           len= w_list.length 
           next if len != (ma60_look_ahead+3)
         #  p len
         
           week_list =  w_list.collect{|row| row['close']} 
           #p week_list
           ma5_list  =  w_list.collect{|row| row['ma5']} 
           #ma10_list  =  w_list.collect{|row| row['ma10']} 
           #ma20_list  =  w_list.collect{|row| row['ma20']} 
           ma60_list =  w_list.collect{|row| row['ma60']} 
           #date_list =  w_list.collect{|row| row['date']} 
           #m_state_list = w_list.collect{|row| row['market_state']} 
           #p m_state_list[134]

           #p ma60_list

           #return if ma60_list[0] == 0.0 # ma60 data is valid
           #p week_list.length

           week_list[(ma60_look_ahead+2)..len-1].each_with_index do |x,i|
              if ma60_list[i] !=0.0

                 index = i+ma60_look_ahead+2
                 #p index
                 #p m_state_list[index]
                 #p date_list[index]
                 if check_ma60_state(ma60_list[index],ma60_list[index-ma60_look_ahead]) # not in long down state
                 #if m_state_list[index] == 1
                    
                   if is_valley?(ma5_list[index-2],ma5_list[index-1],ma5_list[index])
                   #if is_valley?(week_list[index-2],week_list[index-1],week_list[index])
                      #ts = ""
                      #ts += ", ma5,ma10 around ma20" if   (abs((ma5_list[index] - ma20_list[index])/ma20_list[index]) < 0.02) and (abs((ma10_list[index] - ma20_list[index])/ma20_list[index]) < 0.02)
                      #ts += ", ma5 around ma60" if   ((ma5_list[index] - ma60_list[index])/ma60_list[index]) < 0.08
                      #puts "Found Valley  point, #{code} at #{date_list[index].to_s}  #{ts} " if ts.length > 0

                      if   ((ma5_list[index] - ma60_list[index])/ma60_list[index]) < 0.08 # found 
                         code_list.push(code)
                         price_list.push(week_list[i])
                         am = (unit_amount/(week_list[i]*100)).floor*100
                         amount_list.push(am)

                         left_money -= am*week_list[i]
                         p left_money
                         p unit_amount


                          if left_money< unit_amount #buy 20 stock at the most
                             return code_list,price_list,amount_list
                         end

                      end
                   end


                 end
              end

           end
        #breakm
     end  # of Names

       return code_list,price_list,amount_list
end


 def weekly_monitor(topN,weeks)


  # sa1=find_candidate(37,1000,2,true)
  # sa2=find_candidate(35,10,1,true)

  # sa2.each do |h|
  #   code = h[:code]
  #   p code
  #   x= sa1.find {|h2| h2[:code] == code}
  #   if x==nil
  #     puts "#{format_code(code)} not found in old list"
  #   end
  # end

  # return 

  sa=[]
  day= Time.now.to_date
  old_day = previous_work_day(day)
  min_list = Daily_minlist_records.get_min_list_for_day(old_day,2)
 
  w_list2 = Daily_records.find(:all, :conditions=>" date = date(\'#{old_day.to_s}\')", :order=>"id asc")

  
  while (1)
    sa = []

  min_list.each do |min|

      code=min['code']    
      if ((r2 = w_list2.find {|rec| rec['code'] == code})!=nil)
         #puts "fetching data from sina for code #{code}..."
         open,high,close,low=get_price_from_sina(code)

         if ((r2['close'] - close) / close < -0.01 ) and (r2['amount'] !=0.0)
            # it's a real case.
             price = close
           old_price = r2['close']
           roe = ((price - old_price)/old_price*100)

           if roe>1
               #puts "found #{Names.get_name(code)}(#{code}) on #{Time.now.to_s} at price #{price},low price #{old_price} ,roe:#{(roe*100).floor/100.0}%"
         
             h=Hash.new 
             h[:code] =code
             h[:price]=price
             h[:min_price]=min['price']
             h[:date] = day
             h[:min_date] = min['date']
             h[:last_days]= min['last_days']
            # h[:sort_key]= min['last_days']

            # roe = 100 if roe <=0
            # roe +=10 if roe<=1

             h[:roe]=roe

             #h[:sort_key]=  h[:sort_key]+35 if  h[:sort_key]<=63
             

             sa.push(h)
           end
         end

         
         #p h
      end
  end

      #p sa.length
      sa.sort_by!{|h| h[:roe]}
      
      ind = sa.length
      ind = topN if ind>topN

      puts "------------------------------------------------------------------------------"
      sa[0..ind].each do |h|
       # p h
        puts "#{Names.get_name(h[:code])}(#{h[:code]}) on #{Time.now.to_s}, last #{h[:last_days]} days, price #{h[:price]}, last price #{h[:min_price]} on #{h[:min_date]} #{(h[:roe]*100).floor/100.0}% high compared to last price"  
      end
 
      sleep(period)   
  end # while(1)

end


def show_market_state(code,update_flag=false)
   #w_list = Weekly_records.find(:all, :conditions=>" code = \'#{code}\'", :order=>"id asc")
   w_list = Weekly_records.where(code: "#{code}").order("id asc")
   #p w_list.length

   last_state = :null
   market_state = :null
   previous_state = :null
   shake_times = 0

   sa=[]

   w_list.each do |rec|
     
     v1 = rec['ma20']
     v2 = rec['ma20_3m_before']
 
     slope = 0 if v2 == 0
     slope = (v1-v2)/v2*100 if v2>0
 
     #market_state 

     case last_state
       when :null

        #previous_state = :null
        #market_state = :new_high if  (rec['close']==rec['new_high']) and (rec['date']==rec['new_high_date'])

        if (rec['ma10']-rec['ma60'])/rec['ma60'] > 0.11
          market_state = :bull 
         shake_times = 0
        end
       # market_state = :bull if  (rec['close']==rec['new_high']) and (rec['date']==rec['new_high_date'])
       when :bear
        #market_state = :bull if (rec['ma5']-rec['ma20'])/rec['ma20'] > 0.02
        market_state = :bottom if (rec['ma5']>rec['ma60'])
       when :bottom
        if (rec['ma10']-rec['ma60'])/rec['ma60'] > 0.11
          market_state = :bull 
         shake_times = 0
        end


        #previous_state = :bottom
        #market_state = :new_high if  (rec['close']==rec['new_high']) and (rec['date']==rec['new_high_date'])

        #market_state = :bull if  (rec['close']==rec['new_high']) and (rec['date']==rec['new_high_date'])
        #market_state = :bull if slope > 9
       when :bull
        ratio= (rec['ma10']-rec['ma60'])/rec['ma60']
        puts "on #{rec['date'].to_s}, bull ratio = #{ratio}"
        market_state = :under_ma20 if (rec['close']<rec['ma20']) and (rec['close']<rec['ma5'])


       when :under_ma20
         #market_state = :shaking_in_bull if (rec['close']<rec['ma20']) and (rec['close']<rec['ma5'])
         if (rec['close']>rec['ma20']) and (rec['close']>rec['ma5']) and (rec['ma5']>rec['ma10']) and (shake_times==0)
           market_state = :bull 
           shake_times =+1
         # else
         #  market_state = :shaking_in_bull
         #  shake_times +=1
         # end
         end

         if shake_times==1
            if (rec['close']<rec['ma20']) and (rec['close']<rec['ma5'])
              market_state = :bull_over
            end

         end
      when :bull_over
        market_state = :bear if (rec['ma20']<rec['ma60'])
        market_state = :jump_after_bull if (rec['ma5']>rec['ma10']) and (rec['close']>rec['ma5']) 

      when :jump_after_bull
        market_state = :jump_over if (rec['ma5']<rec['ma10']) and (rec['close']<rec['ma5']) 

      when :jump_over 
        market_state = :bear if (rec['ma20']<rec['ma60'])
       

       # when :shaking_in_bull
       #  market_state = :bear if (rec['ma20']<rec['ma60'])
       #  market_state = :bull if (rec['ma5']>rec['ma10']) and (rec['close']>rec['ma5']) and (shake_times<3)
       #  # previous_state = :shaking_in_bull
       #  # if  (rec['close']==rec['new_high']) and (rec['date']==rec['new_high_date'])
       #  #   if (code!='399905') and (code!='000300') #only stock could create new high after shaking. index will go bear when first shake happens
       #  #     market_state = :new_high 
       #  #   end
       #  # end
       #  #market_state = :bull if (rec['ma10']-rec['ma60'])/rec['ma60'] > 0.11
       # when :new_high
       #   if (rec['close']==rec['new_high']) and (rec['date']==rec['new_high_date'])
       #     market_state = :bull 
       #   else
       #    market_state = previous_state
       #   end

       else
        puts "unkown state = #{last_state.to_s}"
     end

      m_state=0
      case market_state
      when :bear,:jump_over,:bull_over
        m_state = 1
      else
        m_state = 0
      end

      ts = "market_state=#{m_state} where id = #{rec['id']}"

      #p ts

      sa.push(ts)

     puts "on #{rec['date']} in #{market_state.to_s}" if last_state!=market_state
     last_state = market_state
     #puts "on #{rec['date']} in #{last_state.to_s}, ratio=#{format_roe(slope)}, ma5=#{format_big_num(rec['ma5'])}, ma20 = #{format_big_num(rec['ma20'])}"
   end

  #p sa.length
  #p update_flag
  update_data('weekly_records',sa) if update_flag==1

end

def same_week?(t1,t2)
  nt1 = Time.parse(t1+' 15:00:00')
   nt2 = Time.parse(t2+' 15:00:00')
  return nt1.strftime('%U').to_i == nt2.strftime('%U').to_i
end


def load_tushare_from_json

  load_name_into_database if Names.last == nil 

  #return 

  if Weekly_records.last != nil
    wid = Weekly_records.last['id']+1
  else
    wid = 1
  end

  empty_database=true if wid == 1

  # json = File.read('cache.txt')
  # h = JSON.parse(json)


  buf=""
  pre =0
  File.open("cache.txt").each_char do |ch|
     buf += ch if pre!=0
     if (pre=='}')  and  (ch=='}')

       #p buf
       len = buf.length
       start_pos = buf.index('{"') 

       #p start_pos
       ns = buf[start_pos..len-1]
       code = buf[2..7] 
       code = buf[1..6] if start_pos==9
       code = '000300' if code == '399300'

       #p code
       h = JSON.parse(ns)
       #p h.keys.sort       
       #
       #
       
       p "process #{code}..."
       week_arr = []
      week_num = 1
      h.keys.sort.each do |week|
      v = h[week]
      #p "#{code},#{date}, #{v}"
      if empty_database # this is a empty database
            ts = "#{wid},\'#{code.to_s}\',date(\'#{week}\'),#{week_num},#{v['open']},#{v['high']},#{v['low']},#{v['close']},#{v['volume']},#{v['volume']*v['close']},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,date(\'#{week}\'),date(\'#{week}\')"

             week_arr.push(ts)

             wid += 1
             week_num += 1

      else
      end #of empty_database

    end #of each week

      
     insert_data('weekly_records',week_arr) if week_arr.length!=0
       
     #h.each {|line| p line}
     update_weekly_record(code) 
       
       
       buf=""
     end
    
     pre = ch


  end
 
  
  return

  #h.each{|x| p x}
  h.keys.each do |code|
    p "process #{code}..."
    week_arr = []
    week_num = 1
    h[code].keys.sort.each do |week|
      v = h[code][week]
      #p "#{code},#{date}, #{v}"
      if empty_database # this is a empty database
            ts = "#{wid},\'#{code.to_s}\',date(\'#{week}\'),#{week_num},#{v['open']},#{v['high']},#{v['low']},#{v['close']},#{v['volume']},#{v['volume']*v['close']},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,date(\'#{week}\'),date(\'#{week}\')"

             week_arr.push(ts)

             wid += 1
             week_num += 1

      else
      end #of empty_database

    end #of each week

      
     insert_data('weekly_records',week_arr) if week_arr.length!=0
       
     #h.each {|line| p line}
     update_weekly_record(code) 
    
  end # of each code


end #of load_json\\

def last_three_month_analysis(dir,days=90,check_ma5_days=1000)

  load_name_into_database if Names.count == 0 

   three_month_before = Time.now.to_date - days

   sa=[]
   #qf = 1.0

  Dir.glob("#{dir}\/*.txt").sort.each do |afile|
    puts "processing file #{afile}"
     qf = 1.0

    pos = afile.index('S')
    market=afile[pos..(pos+1)]  #SH SZ
    code = afile[(pos+2)..(pos+7)]

    b_first = true
    start = high = low = close =  0.0
    sina_format = false

    updays_ma5 = 0
    updays_ma10 = 0

    File.open(afile,:encoding =>'gbk' ) do |file|

      #last_date = ''
      ta = []
      last_d = '2016-07-01'
      ls = 0
      ma5=0.0
      ma10 =0.0
      ta5 = []
      ta10 = []
      close = 0.0
    

      file.each_line do |line|
        #p line
        #
       if (line.index('SINA')!=nil) and (not sina_format)
          file.rewind
          file.set_encoding('utf-8')
          line = file.readline
          qf = line.scan(/[0-9]+\.[0-9]+/)[0].to_f
          sina_format = true
        end

        ndate = nil
        ta=[]
        #p line
        
        if (line[4] == '-') 
          ta = line.split(/ /)
          ndate = Date.parse(ta[0])
          #close = ta[4].to_f
        else

          if (line[2] == '/') 
            ta = line.split(/\t/)
            #p ta
            ndate = Date.new(line[6..9].to_i,line[0..1].to_i,line[3..4].to_i)
            #close = ta[4].to_f
          end  
        end

      

          if (ndate!=nil) and ((ndate) >= three_month_before)
             if b_first
                start= ta[4].to_f
                high = ta[2].to_f
                low  = ta[3].to_f
                close = start

                b_first = false
             end

             high = ta[2].to_f if ta[2].to_f > high
             low  = ta[3].to_f if ta[3].to_f < low
             close = ta[4].to_f

             ta5.shift if ta5.size >= 5
             ta5.push(close)
             ta10.shift if ta10.size >= 10
             ta10.push(close)
             ma5= ta5.inject(:+)/5
             ma10= ta10.inject(:+)/10 

             if (close > ma5) and (ma5 > ma10) 
               updays_ma5 += 1
             else
               updays_ma5 = 0
             end

             if (close > ma10) 
              updays_ma10 += 1
             else
              updays_ma10 = 0
             end

             #p "#{ta[0]} #{start} #{high} #{low} #{close}" 


          end
        
       
      end

     
    end #each_line 

    h = Hash.new
    h[:code] = code
    h[:close] = 0.0
    h[:close] = close/qf if close!=0.0
    h[:start] = start/qf
    h[:high] = high/qf
    h[:low] = low/qf
    h[:roe] = 0.0
    h[:roe] = (close-start)/start*100 if start!=0.0
    h[:updays_ma5] = updays_ma5
    h[:updays_ma10] = updays_ma10

    h[:high_roe] = 0.0
    h[:high_roe] = -(high-close)/high*100 if high!=0.0
    h[:low_roe] = 0.0
    h[:low_roe] = -(low-close)/low*100 if low!=0.0
#    h[:high_low_roe] = 0.0
#    h[:high_low_roe] = (low-high)/high*100 if high!=0.0



    #p h 

    sa.push(h)

  end # each file

  #sa.sort_by{|h| h[:roe]}

   puts " 代码            统计回报  高位回落 低位上涨 当前价格 超过MA5 超过MA10"
  sa.sort_by{|h| -h[:roe]}.each do |h|
    if check_ma5_days == 1000
      puts "#{format_code(h[:code])}  #{format_roe(h[:roe])}  #{format_roe(h[:high_roe])}  #{format_roe(h[:low_roe])}    #{format_price((h[:close]*100).round/100.0)}     #{h[:updays_ma5]}    #{h[:updays_ma10]} "
    else
      if h[:updays_ma5] >= check_ma5_days
       puts "#{format_code(h[:code])}  #{format_roe(h[:roe])}  #{format_roe(h[:high_roe])}  #{format_roe(h[:low_roe])}    #{format_price((h[:close]*100).round/100.0)}     #{h[:updays_ma5]}    #{h[:updays_ma10]} "
      end
    end
  end 

end


def update_till_lastest(dir)

  load_name_into_database if Names.count == 0 

  counter = 1

  Dir.glob("#{dir}\/*.txt").sort.each do |afile|
    puts "processing file #{afile}"

    pos = afile.index('S')
    market=afile[pos..(pos+1)]  #SH SZ
    code = afile[(pos+2)..(pos+7)]

    File.open(afile,:mode => 'r+') do |file|

      #last_date = ''
      ta = []
      last_d = '2016-07-01'
      ls = 0
      file.each_line do |line|
        #p line
        if line[4] == '-'
          ta = line.split(/ /) 
          last_d = ta[0]
        end
        #
        # if line[4]=='-'
        #   ls = -line.length
        #   break
        # end
      end

      # file.seek(ls,IO::SEEK_END)
      # line=file.readline
      # ta = line.split(/ /)
      # p ta
      # last_d = ta[0]

      last_date = Date.parse(last_d)

      start_date = (last_date +1).to_s
      
      end_date = Time.now.to_date
      end_date = end_date -1  if end_date.saturday?
      end_date = end_date -2  if end_date.sunday?
      next if (last_date +1) > end_date 

      end_date = Time.now.to_date.to_s

       code2 = code
      code2 = '399300' if code == '000300'
         t = Time.now
        # sa = get_history_data_from_sina_fuquan(code2,Date.parse(start_date) )
        # p "#{code.to_s} #{start_date} #{sa.to_s} takes #{Time.now-t} seconds."
        # 
        begin
          puts counter
          sleep(15) if counter % 10 == 0
          counter += 1
          sa = get_h_data_from_sina(code2,start_date,end_date )
          #qf = get_fuquan_factor_from_sina(code2)
        rescue
          p "Network ERROR when fetch #{code2} fuquan data from sina at #{Time.now.to_s}"
          # begin
          #   sa = get_h_data_from_sina(code2,start_date,end_date )
          #   qf = get_fuquan_factor_from_sina(code2)
          # rescue
          # p "Network ERROR AGAIN when fetch #{code2} fuquan data from sina at #{Time.now.to_s}"
          # end
        end

        len = 0 

        len=sa.length if sa != nil
        p "#{code.to_s} #{start_date}:#{end_date} : #{len} records takes #{Time.now-t} secs at #{Time.now.strftime("%x %X")}"
        
        if len>0
          file.rewind
          if sa[len-1][7] != nil
             line = "#{code} #{format_code(code)} #{sa[len-1][7]} at #{end_date} SINA FUQUAN DATA"
          else
             line = "#{code} #{format_code(code)} 1.0 at #{end_date} SINA FUQUAN DATA"
          end
          file.puts(line)
          file.seek(0, IO::SEEK_END)
          #wf.puts("      日期     开盘      最高      收盘      最低      成交量     成交额   复权因子")
          sa.each do |h|
            file.puts "#{h[0]} #{h[1]} #{h[2]} #{h[3]} #{h[4]} #{h[5]} #{h[6]} #{h[7]} "
          end
        end
      
        
    end # file

  end # each file
end

def update_fuquan_data_by_filename(codefile,dir,start_date=nil,end_date=nil)

   load_name_into_database if Names.count == 0 

   if start_date == nil
      rec = Weekly_records.where(:code =>"000300").last
      if rec != nil
        start_date = (rec['date'] ).to_s
      else
        start_date = '2016-07-01' 
      end
    end

   end_date = Time.now.to_date.to_s if end_date == nil

   counter = 1
  
  File.open(codefile).each_line do |line|

      ta = line.split('|')
      code = ta[1]
   
 
      code2 = code
      code2 = '399300' if code == '000300'


        pref = 'SZ'
        pref = 'SH' if code[0] == '6'


      if not File.exist?("#{dir}\/#{pref}#{code}.txt")
           t = Time.now
          # sa = get_history_data_from_sina_fuquan(code2,Date.parse(start_date) )
          # p "#{code.to_s} #{start_date} #{sa.to_s} takes #{Time.now-t} seconds."
          # 
          begin
            sa = get_h_data_from_sina(code2,start_date,end_date )
            #qf = get_fuquan_factor_from_sina(code2)
            counter += 1
            sleep(10) if counter % 3 == 0
          rescue
            p "Network ERROR when fetch #{code2} fuquan data from sina at #{Time.now.to_s}"
            # begin
            #   sa = get_h_data_from_sina(code2,start_date,end_date )
            #   qf = get_fuquan_factor_from_sina(code2)
            # rescue
            # p "Network ERROR AGAIN when fetch #{code2} fuquan data from sina at #{Time.now.to_s}"
            # end
          end

           len = 0 
          len=sa.length if sa != nil
          p "#{code.to_s} #{start_date}:#{end_date} : #{len} records takes #{Time.now-t} secs at #{Time.now.strftime("%x %X")}"


          if len > 0 
            pref = 'SZ'
            pref = 'SH' if code[0] == '6'
            wf = File.new("#{dir}\/#{pref}#{code}.txt",'w')

             if sa[len-1][7] != nil
              line = "#{code} #{format_code(code)} #{sa[len-1][7]} at #{end_date} SINA FUQUAN DATA"
             else
               line = "#{code} #{format_code(code)} 1.0 at #{end_date} SINA FUQUAN DATA"
             end

            #line = "#{code} #{format_code(code)} #{sa[len-1][7]} at #{end_date} SINA FUQUAN DATA"
            wf.puts(line)
            wf.puts("      日期     开盘      最高      最低      收盘      成交量     成交额   复权因子")
            sa.each do |h|
              wf.puts "#{h[0]} #{h[1]} #{h[2]} #{h[3]} #{h[4]} #{h[5]} #{h[6]} #{h[7]} "
            end
          
            wf.close
          end
          #sa.each {|x| p x}
          #break
        end
       
    end
end


#根据最新的股票文件，以及以前下载的文件目录，更新数据。 有旧数据的股票，更新到最新日期，没有旧数据的股票，创建文件，并获取180天到现在的数据
def update_fuquan_data_by_filename_2(codefile,dir)

   clear_table('name')
   load_name_into_database(codefile) if Names.count == 0 

  end_date = Time.now.to_date
  end_date = end_date -1  if end_date.saturday?
  end_date = end_date -2  if end_date.sunday?
  #end_date = end_date.to_s

 
  #start_date = (Time.now.to_date - 180 ).to_s

  #puts "#{start_date} #{end_date}"
  #
  counter = 1
    
  
  File.open(codefile).each_line do |line|

      ta = line.split('|')
      code = ta[1]
   
 
      code2 = code
      code2 = '399300' if code == '000300'


        pref = 'SZ'
        pref = 'SH' if code[0] == '6'


      #puts "#{start_date} #{end_date}"

      if not File.exist?("#{dir}\/#{pref}#{code}.txt")

          next if not is_new_stock_number?(code)

          puts "#{dir}\/#{pref}#{code}.txt not found, create file"
           t = Time.now
          # sa = get_history_data_from_sina_fuquan(code2,Date.parse(start_date) )
          # p "#{code.to_s} #{start_date} #{sa.to_s} takes #{Time.now-t} seconds."
          
          begin
            #puts "#{start_date} #{end_date}"
            end_date = end_date.to_s
            start_date = (Time.now.to_date - 180 ).to_s
            sa = get_h_data_from_sina(code2,start_date,end_date )
            #qf = get_fuquan_factor_from_sina(code2)
            counter += 1
            sleep(20) if counter % 10 == 0
          rescue
            p "Network ERROR when fetch #{code2} fuquan data from sina at #{Time.now.to_s}"
          end

           len = 0 
          len=sa.length if sa != nil
          p "#{code.to_s} #{start_date}:#{end_date} : #{len} records takes #{Time.now-t} secs at #{Time.now.strftime("%x %X")}"


          if len > 0 
            pref = 'SZ'
            pref = 'SH' if code[0] == '6'
            wf = File.new("#{dir}\/#{pref}#{code}.txt",'w')

             if sa[len-1][7] != nil
              line = "#{code} #{format_code(code)} #{sa[len-1][7]} at #{end_date} SINA FUQUAN DATA"
             else
               line = "#{code} #{format_code(code)} 1.0 at #{end_date} SINA FUQUAN DATA"
             end

            #line = "#{code} #{format_code(code)} #{sa[len-1][7]} at #{end_date} SINA FUQUAN DATA"
            wf.puts(line)
            wf.puts("      日期     开盘      最高      最低      收盘      成交量     成交额   复权因子")
            sa.each do |h|
              wf.puts "#{h[0]} #{h[1]} #{h[2]} #{h[3]} #{h[4]} #{h[5]} #{h[6]} #{h[7]} "
            end
          
            wf.close
          end
          #sa.each {|x| p x}
          #break
        else # the file exist in the directory 

         
          File.open("#{dir}\/#{pref}#{code}.txt",:mode => 'r+') do |file|

              #last_date = ''
              ta = []
              last_d = '2016-07-01'
              ls = 0
              file.each_line do |line|
                #p line
                if line[4] == '-'
                  ta = line.split(/ /) 
                  last_d = ta[0]
                end
                #
                # if line[4]=='-'
                #   ls = -line.length
                #   break
                # end
              end

              # file.seek(ls,IO::SEEK_END)
              # line=file.readline
              # ta = line.split(/ /)
              # p ta
              # last_d = ta[0]

              last_date = Date.parse(last_d)

              start_date = (last_date +1).to_s
              
              end_date = Time.now.to_date
              end_date = end_date -1  if end_date.saturday?
              end_date = end_date -2  if end_date.sunday?

              if (last_date +1) > end_date  # just for force update 
                 file.rewind
                 line=file.readline
                 na = line.split(' ')
              
                 if (na[0] == na[1])
                  qf = na[2] 
                  puts "#{code} #{format_code(code)} #{qf} at #{last_d} SINA FUQUAN DATA"
                  file.rewind
                  line = "#{code} #{format_code(code)} #{qf} at #{last_d} SINA FUQUAN DATA"
                  file.puts(line)
                end


              end

              next if (last_date +1) > end_date 

              puts "#{dir}\/#{pref}#{code}.txt found, update file"

              end_date = Time.now.to_date.to_s

               code2 = code
              code2 = '399300' if code == '000300'
                 t = Time.now
                # sa = get_history_data_from_sina_fuquan(code2,Date.parse(start_date) )
                # p "#{code.to_s} #{start_date} #{sa.to_s} takes #{Time.now-t} seconds."
                # 
                begin
                  sa = get_h_data_from_sina(code2,start_date,end_date )
                  #qf = get_fuquan_factor_from_sina(code2)
                  counter += 1

                  sleep(20) if counter % 10 == 0
                rescue
                  p "Network ERROR when fetch #{code2} fuquan data from sina at #{Time.now.to_s}"
                  # begin
                  #   sa = get_h_data_from_sina(code2,start_date,end_date )
                  #   qf = get_fuquan_factor_from_sina(code2)
                  # rescue
                  # p "Network ERROR AGAIN when fetch #{code2} fuquan data from sina at #{Time.now.to_s}"
                  # end
                end

                len = 0 

                len=sa.length if sa != nil
                p "#{code.to_s} #{start_date}:#{end_date} : #{len} records takes #{Time.now-t} secs at #{Time.now.strftime("%x %X")}"
                
                if len>0
                  file.rewind
                  if sa[len-1][7] != nil
                     line = "#{code} #{format_code(code)} #{sa[len-1][7]} at #{end_date} SINA FUQUAN DATA"
                  else
                     line = "#{code} #{format_code(code)} 1.0 at #{end_date} SINA FUQUAN DATA"
                  end
                  file.puts(line)
                  file.seek(0, IO::SEEK_END)
                  #wf.puts("      日期     开盘      最高      最低      收盘      成交量     成交额   复权因子")
                  sa.each do |h|
                    file.puts "#{h[0]} #{h[1]} #{h[2]} #{h[3]} #{h[4]} #{h[5]} #{h[6]} #{h[7]} "
                  end
                end
              
                
            end # file

 


        end
       
    end
end

def update_fuquan_data(dir,start_date=nil,end_date=nil)

   load_name_into_database if Names.count == 0 

   if start_date == nil
      rec = Weekly_records.where(:code =>"000300").last
      if rec != nil
        start_date = (rec['date'] ).to_s
      else
        start_date = '2016-07-01' 
      end
    end

   end_date = Time.now.to_date.to_s if end_date == nil
  

   Names.get_code_list.each do |code|
    
  
      # puts "Updating weekly data from tushare  : #{code}"

        #code = '002508'
        code2 = code
       code2 = '399300' if code == '000300'
       #next if code == '000300'

        pref = 'SZ'
        pref = 'SH' if code[0] == '6'
        if not File.exist?("#{dir}\/#{pref}#{code}.txt")

           #start_date = '2016-07-01'
           #end_date = Time.now.to_date.to_s
           t = Time.now
          # sa = get_history_data_from_sina_fuquan(code2,Date.parse(start_date) )
          # p "#{code.to_s} #{start_date} #{sa.to_s} takes #{Time.now-t} seconds."
          # 
          begin
            sa = get_h_data_from_sina(code2,start_date,end_date )
            qf = get_fuquan_factor_from_sina(code2)
          rescue
            p "Network ERROR when fetch #{code2} fuquan data from sina at #{Time.now.to_s}"
            begin
              sa = get_h_data_from_sina(code2,start_date,end_date )
              qf = get_fuquan_factor_from_sina(code2)
            rescue
            p "Network ERROR AGAIN when fetch #{code2} fuquan data from sina at #{Time.now.to_s}"
            end
          end

          len=sa.length
          p "#{code.to_s} #{start_date}:#{end_date} : #{len} records takes #{Time.now-t} secs at #{Time.now.strftime("%x %X")}"
          
          #pref = 'SZ'
          #pref = 'SH' if code[0] == '6'
          wf = File.new("#{dir}\/#{pref}#{code}.txt",'w')
          line = "#{code} #{format_code(code)} #{qf} at #{end_date} SINA FUQUAN DATA"
          wf.puts(line)
          wf.puts("      日期     开盘      最高      最低      收盘      成交量     成交额   复权因子")
          sa.each do |h|
            wf.puts "#{h[0]} #{h[1]} #{h[2]} #{h[3]} #{h[4]} #{h[5]} #{h[6]} #{h[7]} "
          end
        
          wf.close
          #sa.each {|x| p x}
          #break
        end
       
    end

end

def get_h_data_for_code(code,start_date=nil,end_date=nil)

   if start_date == nil
      rec = Weekly_records.where(:code =>"#{code}").last
      if rec != nil
        start_date = (rec['date'] ).to_s
      else
        start_date = '2014-01-01' 
      end
    end

   end_date = Time.now.to_date.to_s if end_date == nil
  

   code2 = code
   code2 = '399300' if code == '000300'

   t = Time.now
    # sa = get_history_data_from_sina_fuquan(code2,Date.parse(start_date) )
    # p "#{code.to_s} #{start_date} #{sa.to_s} takes #{Time.now-t} seconds."
    # 
    begin
      sa = get_h_data_from_sina(code2,start_date,end_date )
      qf = get_fuquan_factor_from_sina(code2)
    rescue
      p "Network ERROR when fetch #{code2} fuquan data from sina at #{Time.now.to_s}"
      begin
        sa = get_h_data_from_sina(code2,start_date,end_date )
        qf = get_fuquan_factor_from_sina(code2)
      rescue
      p "Network ERROR AGAIN when fetch #{code2} fuquan data from sina at #{Time.now.to_s}"
      end
    end

    len=sa.length
    p "#{code.to_s} #{start_date}:#{end_date} : #{len} records takes #{Time.now-t} secs at #{Time.now.strftime("%x %X")}"
    
    pref = 'SZ'
    pref = 'SH' if code[0] == '6'
    wf = File.new("#{pref}#{code}.txt",'w')
    line = "#{code} #{format_code(code)} #{qf} at #{end_date} SINA FUQUAN DATA"
    wf.puts(line)
    wf.puts("      日期     开盘      最高      最低      收盘      成交量     成交额   复权因子")
    sa.each do |h|
      wf.puts "#{h[0]} #{h[1]} #{h[2]} #{h[3]} #{h[4]} #{h[5]} #{h[6]} #{h[7]} "
    end
  
    wf.close

end


def update_weekly_data_from_tushare_new

   tushare=Tushare.new

   # check if a stock is fuquan ?
   Names.get_code_list.each do |code|
    
  
      # puts "Updating weekly data from tushare  : #{code}"

        code2 = code
       code2 = '399300' if code == '000300'
       next if code == '000300'

       h=[]
       #p start_date
       start_date = '2016-06-30'

         t= Time.now
         h=tushare.get_h_data(code2,(Date.parse(start_date)).to_s,(Date.parse(start_date)).to_s)
         next if h.length == 0
         v=h[h.keys[0]]
         #p v['open']
         #h.each {|x| p x}
        #  h.each do |x| 
        #   p x
        # end
         #h=tushare.get_history_data('000300','2016-06-24','2016-07-01','W')
          puts "Updating weekly data from tushare  : #{code} takes #{Time.now-t} seconds"

          sa = get_history_data_from_sina_new(code2,Date.parse(start_date) )
            
          #sa.each {|x| p x}
          if (sa[0] == v['open']) and (sa[4] == v['volume'])
            p "#{code.to_s} no need xingquan"
          else 
            if (sa[0] != v['open']) and (sa[4] == v['volume'])
               p h
              p sa
              p "#{code.to_s} need xingquan"
            else
              p "#{code.to_s} data is different "
              p h
              p sa
            end
          end
       #break
  end
end 

def update_weekly_data_from_tushare
  tushare=Tushare.new

  if Weekly_records.last != nil
    wid = Weekly_records.last['id']+1
  else
    wid = 1
  end

  p wid

  Names.get_code_list.each do |code|
    
  
       puts "Updating weekly data from tushare  : #{code}"
  
       w_list = Weekly_records.where(code:"#{code}")
       datelist = w_list.collect {|row| row['date'] }
       len = datelist.length

       week_num = 1
       start_date = "2009-12-04"
       
       if len!=0
         week_num = w_list[len-1].week_num+1
         start_date = Weekly_records.get_last_date(code).to_s
       end

       #p start_date

       code2 = code
       code2 = '399300' if code == '000300'

       h=[]
       #p start_date

       begin
         h=tushare.get_history_data(code2,start_date,Time.now.to_s[0..9],'W')
         #h=tushare.get_history_data('000300','2016-06-24','2016-07-01','W')
       
       end

       next if h.length == 0

       if (h.length == 1) and (h.keys[0] == start_date)
         p "for #{code}, Data is update, no new data. #{start_date}"
         next 
       end

       week_arr = []

       changed_flag = false;
       
       h.keys.sort.each do |week|
         if week == start_date
           #p "Data is OK ,no need to update"
          
         else
           if same_week?(week,start_date) and (len!=0)
            #update this week data
             rec = Weekly_records.where(:code =>"#{code}",:date =>"#{start_date}").first
             #p rec
             rec.date = week
             rec.open = v['open']
             rec.close = v['close']
             rec.high = v['high']
             rec.low = v['low']
             rec.volume = v['volume']
             rec.amount = v['volume']*v['close']
             #id = rec.id
             rec.save 
             #rec = Weekly_records.where(:id =>338)
             #p rec
             changed_flag = true
           else
            #insert data directly
             # rec = Weekly_records.new do |u|
             # #p rec
             #   u.date = week
             #   u.week_num = week_num
             #   u.open = v['open']
             #   u.close = v['close']
             #   u.high = v['high']
             #   u.low = v['low']
             #   u.volume = v['volume']
             #   u.amount = v['volume']*v['close']
             # end
             # #id = rec.id
             # rec.save 
      
             ts = "#{wid},\'#{code.to_s}\',date(\'#{week}\'),#{week_num},#{v['open']},#{v['high']},#{v['low']},#{v['close']},#{v['volume']},#{v['volume']*v['close']},0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,date(\'#{week}\'),date(\'#{week}\')"

             week_arr.push(ts)

             wid += 1
             week_num += 1

             changed_flag = true
           end
         end
       end

       insert_data('weekly_records',week_arr) if week_arr.length!=0
       
       #h.each {|line| p line}
      update_weekly_record(code) if changed_flag
      #break
  end
end

# def search_for_candidate(ma)
  

#      datelist = Weekly_records.new.get_date_list
#      len = datelist.length
#      date = datelist[len-1]
#      w_list = Weekly_records.find(:all, :conditions=>"date = date(\'#{date.to_s}\')", :order=>"id asc")
#        # check last (n+2) records. n = 18
     
#       cl=[]
#       puts "close < #{ma}"
#       w_list.each do |rec|
#        code = rec['code']
#        value = rec[ma]
#        #puts "#{format_code(code)} at price #{rec['close']}" if rec['date'] == rec['new_low_date']
#        if rec['close'] < value
#          cl.push(code)
#        end
#        #puts "#{format_code(code)} at price #{rec['close']}" if rec['close'] < value
#     end # of each code

#     return cl
# end

def print_help
    puts "This Tool is used to show code market_state"
    puts "-c code   ---  display single stock states "
    puts "-f code   ---  fresh single stock states "
    puts "-s        ---  display stock states statistics "
    puts "-u        ---  update all records market state "
    puts "-t  mode unit_num weeks show_trade    ---  run a sim test for [num] weeks , new"
    puts "-t2  mode unit_num weeks show_trade   ---  run a sim test for [num] weeks , old"
    puts "-g        ---  update all minimum records"
    puts "-a        ---  update all weekly_data and generating minimum list"
    puts "-p  least_days  ---  print lastest minimum list till today"
    puts "-r  weeks ---  print weekly data min list statistics result"
    puts "-x  mode topN pri_week  ---  print current candidate using analysis mode"
    puts "-y  mode topN pri_week compared  ---  print performance for mode topN pri_week"
    puts "-z  mode weeks  ---  trying mode for N weeks"
    puts "-z2  weeks topN  ---  compare all mode for N weeks and topN "

    puts "-z4  weeks     ---  compare all mode for N weeks "

    puts "-ms code update_flag  show market_state [159915 399905 000300]"

    puts "-ttb  weeks topN  ---  compare all mode for N weeks and topN "

    puts "-xp   days topN diff  ---  Find last [days], price change greater than [diff] ,top N  " 
    puts "-xv   days topN diff  ---  Find last [days], price change little than  [diff] ,top N  "  

    puts "-sroe code years ---  财报数据分析  参数: 股票代码 年 "  


     puts "--------------------------------------------------------------------------------------------"
     puts "-tu [dir] [start_date] [end_date] update fuquan data for all codes from database "
     puts "-fu [codefile] [dir] [start_date] [end_date] update fuquan data for all codes from codefile "
     puts "-ud [dir]  update given directory all fuquan files to lastest "
     puts "-sd [dir] [days]  make a statistics for last days. "
     puts "-tc [code] [start_date] [end_date] update single code data from start_date to end_date "


    puts "-h        ---  This help"    
end


code = "600000"

num = 100

 $macd_p=[12.0,26.0,9.0]

check_index_state(0)

$proxy = nil

if ARGV.length != 0
 
    ARGV.each do |ele|       
        if  ele == '-h'          
          print_help
          exit 
        end 


    if ele == '-c'
      code = ARGV[ARGV.index(ele)+1].to_s
      info = ARGV[ARGV.index(ele)+2].to_i
       #puts code
      display_stock_states(code,info) 
    end


   if ele == '-f'
      code = ARGV[ARGV.index(ele)+1].to_s
       #puts code
      update_weekly_record(code) 
    end


    if ele == '-s'
      state = ARGV[ARGV.index(ele)+1].to_i
       #puts code
      find_state(state) 
    end

    if ele == '-u' 
     p1 = ARGV[ARGV.index(ele)+1].to_i

     #$macd_p=[12.0,26.0,9.0]

     # if p1 ==1
     #   $macd_p = [6,30,9] 
     # end 
     update_weekly_records2
    end

    if ele == '-t' 
      mode = ARGV[ARGV.index(ele)+1].to_i
      unit_number = ARGV[ARGV.index(ele)+2].to_i
      num_of_records = ARGV[ARGV.index(ele)+3].to_i
      show_trade = ARGV[ARGV.index(ele)+4].to_i
       #puts code
     
      a=Asset.new
      run_class=Weekly_records.new
      test_trade2(mode,unit_number,a,run_class, num_of_records,show_trade)
      #test_drive2(a,num,show_trade)
      # a.buy('600036','2015-03-09',12,1000)
      #  a.show_portfilo
      # a.buy('600036','2015-03-09',13,1000)
      # a.show_portfilo
      # a.buy('600030','2015-03-09',12,1000)
      # a.sell('600030','2015-03-09',12,100)
      # a.show_portfilo
      # a.sell('600030','2015-03-09',15,900)
      # a.show_portfilo
      # #p a.get_current_money
      # a.show_log
      puts 

    end

    if ele == '-t2' 
      mode = ARGV[ARGV.index(ele)+1].to_i
      unit_number = ARGV[ARGV.index(ele)+2].to_i
      num_of_records = ARGV[ARGV.index(ele)+3].to_i
      show_trade = ARGV[ARGV.index(ele)+4].to_i
       #puts code
     
      a=Asset.new
      run_class=Weekly_records.new
      test_trade(mode,unit_number,a,run_class, num_of_records,show_trade)
      #test_drive2(a,num,show_trade)
      # a.buy('600036','2015-03-09',12,1000)
      #  a.show_portfilo
      # a.buy('600036','2015-03-09',13,1000)
      # a.show_portfilo
      # a.buy('600030','2015-03-09',12,1000)
      # a.sell('600030','2015-03-09',12,100)
      # a.show_portfilo
      # a.sell('600030','2015-03-09',15,900)
      # a.show_portfilo
      # #p a.get_current_money
      # a.show_log
      puts 

    end

    if ele == '-g' 
     least_days = ARGV[ARGV.index(ele)+1].to_i
     update_all_minlist(least_days)
    end

    if ele == '-a' 
     least_days = ARGV[ARGV.index(ele)+1].to_i
     update_weekly_records2
     update_all_minlist(least_days)
    end

   if ele == '-p' 
     num = ARGV[ARGV.index(ele)+1].to_i
     show_last_minlist(500,num)
    end 

   if ele == '-r' 
     num = ARGV[ARGV.index(ele)+1].to_i
     analyze_weekly_min_list(num)
    end 

   if ele == '-x' 
     mode = ARGV[ARGV.index(ele)+1].to_i
     topN = ARGV[ARGV.index(ele)+2].to_i
     pri_week = ARGV[ARGV.index(ele)+3].to_i
     find_candidate(mode,topN,pri_week)
    end 

    if ele == '-xp' 
     days = ARGV[ARGV.index(ele)+1].to_i
     topN = ARGV[ARGV.index(ele)+2].to_i
     roe_diff = ARGV[ARGV.index(ele)+3].to_i
     sortby_mv = ARGV[ARGV.index(ele)+4].to_i

     p "Show last #{days.to_s} days, price change over #{roe_diff.to_s}% , topN = #{topN} "

     find_candidate(51,topN,0,false,days,roe_diff,sortby_mv)
    end 

    if ele == '-xv' 
     days = ARGV[ARGV.index(ele)+1].to_i
     topN = ARGV[ARGV.index(ele)+2].to_i
     roe_diff = ARGV[ARGV.index(ele)+3].to_i
     sortby_mv = ARGV[ARGV.index(ele)+4].to_i

     p "Show last #{days.to_s} days, price change over #{roe_diff.to_s}% , topN = #{topN} "

     find_candidate(52,topN,0,false,days,roe_diff,sortby_mv)
    end 

   if ele == '-y' 
     mode = ARGV[ARGV.index(ele)+1].to_i
     topN = ARGV[ARGV.index(ele)+2].to_i
     pri_week = ARGV[ARGV.index(ele)+3].to_i
     compared_with_last_day = ARGV[ARGV.index(ele)+4].to_i
     find_lastweek_roe(mode,topN,pri_week,false,compared_with_last_day)
    end 


   if ele == '-z' 
     mode = ARGV[ARGV.index(ele)+1].to_i
     weeks = ARGV[ARGV.index(ele)+2].to_i
     stock_num = ARGV[ARGV.index(ele)+3].to_i
     compute_long(mode,weeks)
    end

    if ele == '-z5' 
     mode = ARGV[ARGV.index(ele)+1].to_i
     weeks = ARGV[ARGV.index(ele)+2].to_i
     stock_num = ARGV[ARGV.index(ele)+3].to_i
     compute_long_with_control(mode,weeks)
    end

     if ele == '-z7' 
     mode = ARGV[ARGV.index(ele)+1].to_i
     weeks = ARGV[ARGV.index(ele)+2].to_i
     stock_num = ARGV[ARGV.index(ele)+3].to_i
     compute_long_with_control_aggresive(mode,weeks)
    end

    if ele == '-z2' 
     weeks = ARGV[ARGV.index(ele)+1].to_i
     topN = ARGV[ARGV.index(ele)+2].to_i
     find_longtime_roe(topN,weeks)
    end  

    if ele == '-z3' 
     mode = ARGV[ARGV.index(ele)+1].to_i
     weeks = ARGV[ARGV.index(ele)+2].to_i
     stock_num = ARGV[ARGV.index(ele)+3].to_i
     compute_long2(mode,weeks)
    end

    if ele == '-z4' 
     weeks = ARGV[ARGV.index(ele)+1].to_i
     mode_compare(weeks)
    end

    if ele == '-z6' 
     weeks = ARGV[ARGV.index(ele)+1].to_i
     best_mothod(weeks)
    end

    if ele == '-m1' 
     weeks = ARGV[ARGV.index(ele)+1].to_i
     topN = ARGV[ARGV.index(ele)+2].to_i
     weekly_mo    end  

    if ele == '-ms' 
      code = ARGV[ARGV.index(ele)+1]
       update_flag = ARGV[ARGV.index(ele)+2].to_i
     show_market_state(code,update_flag)
    end  

     if ele == '-lh' 
      ma = ARGV[ARGV.index(ele)+1]
      search_for_candidate(ma)
    end 

    #update data from tushare
    if ele == '-tu' 
      #update_weekly_data_from_tushare
      #load_tushare_from_json
      #update_weekly_data_from_tushare_new
       dir = ARGV[ARGV.index(ele)+1]
       start_date = ARGV[ARGV.index(ele)+2]
       end_date = ARGV[ARGV.index(ele)+3]
       p "#{dir} #{start_date} #{end_date}"
       dir="data_#{Time.now.strftime("%m%d")}" if dir == nil
      update_fuquan_data(dir,start_date,end_date)
     end 

     if ele == '-fu' 
      #update_weekly_data_from_tushare
      #load_tushare_from_json
      #update_weekly_data_from_tushare_new
      codefile = ARGV[ARGV.index(ele)+1]
       dir = ARGV[ARGV.index(ele)+2]
       start_date = ARGV[ARGV.index(ele)+3]
       end_date = ARGV[ARGV.index(ele)+4]
       p "#{codefile} #{dir} #{start_date} #{end_date}"
       dir="data_#{Time.now.strftime("%m%d")}" if dir == nil
      update_fuquan_data_by_filename(codefile,dir,start_date,end_date)
     end 

      if ele == '-ud' 
       dir = ARGV[ARGV.index(ele)+1]
      update_till_lastest(dir)
     end

      if ele == '-ud2' 
         codefile = ARGV[ARGV.index(ele)+1]
       dir = ARGV[ARGV.index(ele)+2]
        update_fuquan_data_by_filename_2(codefile,dir)
     end

     if ele == '-proxy' 
       $proxy = ARGV[ARGV.index(ele)+1]
     end

     if ele == '-sroe' 
        code = ARGV[ARGV.index(ele)+1]
        years = ARGV[ARGV.index(ele)+2].to_i
        years = 20 if years == 0
        show_roe_list(code,years)
     end  

     if ele == '-sd' 
       dir = ARGV[ARGV.index(ele)+1]
        offset = ARGV[ARGV.index(ele)+2].to_i
        check_ma5_days = 1000
        check_ma5_days = ARGV[ARGV.index(ele)+3].to_i if ARGV[ARGV.index(ele)+3] != nil
        #p check_ma5_days
      last_three_month_analysis(dir,offset,check_ma5_days)
     end 

      if ele == '-tc' 
      
       code = ARGV[ARGV.index(ele)+1]
       start_date = ARGV[ARGV.index(ele)+2]
       end_date = ARGV[ARGV.index(ele)+3]
       p "#{code} #{start_date} #{end_date}"
       code="000300" if code == nil
      get_h_data_for_code(code,start_date,end_date)
     end 


  if ele == '-tt' 
      code = ARGV[ARGV.index(ele)+1]

      w_list = Weekly_records.where(code: "#{code}").order("id asc")
      length = w_list.length
  
       (0..200).each do |i|
         #p w_list[length-1-i]['date'].to_s
        flag,sum = is_state_over?(w_list,i,1,20,false)
        end
        
       #check_index_state(3)
    end

    if ele == '-tta' 

       buy_list = []
      sell_list = []

      name_len = Names.get_code_list.length

      Names.get_code_list.each do |code|  

        #p "checking #{format_code(code)}.."
      
      w_list = Weekly_records.where(code: "#{code}").order("id asc")
      flag,sum =  is_state_over?(w_list,0,1,30,false)
        []
      if flag 

        p format_code(code)

        h=Hash.new
        h[:code]=code
        h[:sum] = sum


        len = w_list.length
        price = w_list[len-1]['close']
        old_price = w_list[len-2]['close']
        h[:rate] = (price - old_price)/old_price * 100

        if sum < 0 
          buy_list.push(h)
        else
          sell_list.push(h)
        end
      end

      end

      p "Buying list..."
      #p buy_list.length
      buy_list.sort_by!{|h| h[:sum]}
      buy_list.each {|h| p "#{format_code(h[:code])} total_height=#{format_roe(h[:sum])} last_week_roe=#{format_roe(h[:rate])}"}

      p "Sell list..."
      #p sell_list.length
      sell_list.sort_by!{|h| h[:sum]}.reverse!
      sell_list.each {|h| p "#{format_code(h[:code])} total_height=#{format_roe(h[:sum])} last_week_roe=#{format_roe(h[:rate])}"}
        
       #check_index_state(3)
    end




       #
     if ele == '-ttb' 

       buy_list = []


     

      name_len = Names.get_code_list.length

      Names.get_code_list.each do |code|  

        #p "checking #{format_code(code)}.."
      
      w_list = Weekly_records.where(code: "#{code}").order("id asc")
      p format_code(code) if is_new_high?(w_list,0,5)
    
    end
    
    end


   end
else
  print_help
end








