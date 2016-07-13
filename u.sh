if [ -z "$1" ];then
echo "please input parameter"
exit
else
ruby update_weekly_records.rb -ud "$1"
ruby create_sys_table.rb
ruby import_data.rb -d "$1"
ruby update_weekly_records.rb -u
fi