cd /home/mike/do/work/sa
ruby import_data.rb -gcl name.txt 
ruby update_weekly_records.rb -ud2 name.txt data_0331
rm db_backup.db
mv db_daily.db db_backup.db
ruby create_sys_table.rb
ruby import_data.rb -b -d data_0331
ruby import_data.rb -sball
ruby import_data.rb -loadfile stockinfo_hk.txt stock_basic_info
ruby update_weekly_records.rb -u
ruby import_data.rb -ttq 1000 16 10 1
