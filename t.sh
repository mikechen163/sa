if [ -z "$1" ];then
echo "please input parameter"
exit
else
ruby create_sys_table.rb
ruby import_data.rb -b -d "$1"
ruby import_data.rb -sball
ruby import_data.rb -loadfile stockinfo_hk.txt stock_basic_info
ruby update_weekly_records.rb -u
fi
