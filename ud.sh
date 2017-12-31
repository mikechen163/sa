cd /home/mike/do/work/sa
ruby import_data.rb -gcl name.txt 
ruby import_data.rb -gcl_hk hk_name.txt 
ruby update_weekly_records.rb -ud2 name.txt data_0331
rm db_backup.db
mv db_daily.db db_backup.db
ruby create_sys_table.rb
ruby import_data.rb -b -d data_0331
ruby import_data.rb -sball
ruby import_data.rb -sbhkall
#ruby import_data.rb -loadfile stockinfo_hk.txt stock_basic_info
ruby import_data.rb -update hkdata
ruby import_data.rb -update d2y
ruby update_weekly_records.rb -u
