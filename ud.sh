rm db_backup.db
mv db_daily.db db_backup.db
ruby create_sys_table.rb
ruby update_weekly_records.rb -ud data_0331
ruby import_data.rb -b -d data_0331
ruby import_data.rb -sball
ruby update_weekly_records.rb -u
ruby import_data.rb -loadfile stockinfo_hk.txt stock_basic_info
ruby update_weekly_records.rb -z4 52
