if [ -z "$1" ];then
echo "please input parameter"
exit
else
ruby create_sys_table.rb
ruby import_data.rb -d "$1"
ruby update_weekly_records.rb -u
ruby import_data.rb -loadfile stockinfo.txt stock_basic_info
fi
