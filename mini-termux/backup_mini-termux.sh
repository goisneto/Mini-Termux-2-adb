#!/system/bin/sh
script="${BASH_SOURCE[0]}"
if [ -z "${script}" ]; then
	script="$(/system/bin/realpath "$0")"
fi
script_dir="$(/system/bin/dirname "${script}")"
enable_acc_from_all_apps(){
	#for edit from real termux
	eval "/system/bin/chmod 7777 ${script_dir}/.. ${script_dir}/* ${script_dir} ${script_dir}/../unpack_mini-termux.sh > /dev/null 2>&1" > /dev/null 2>&1
}
enable_acc_from_all_apps > /dev/null 2>&1
disable_phantom_process_killer(){
	/system/bin/device_config set_sync_disabled_for_tests persistent > /dev/null 2>&1
	/system/bin/device_config put activity_manager max_phantom_processes 2147483647 > /dev/null 2>&1
	/system/bin/settings put global settings_enable_monitor_phantom_procs false > /dev/null 2>&1
}
disable_phantom_process_killer > /dev/null 2>&1
give_me_all_prioriry(){
	/system/bin/ps -u shell -o pid | /system/bin/tail -n+2 | /system/bin/xargs -r -n1 /system/bin/sh -c '/system/bin/iorenice $0 0 0 > /dev/null 2>&1' > /dev/null 2>&1
	/system/bin/ps -u shell -o pid | /system/bin/tail -n+2 | /system/bin/xargs -r -n1 /system/bin/sh -c '/system/bin/renice -p -n -20 $0 > /dev/null 2>&1' > /dev/null 2>&1
}
give_me_all_prioriry > /dev/null 2>&1
exec /system/bin/tar --selinux --owner root:0 --group root:0 --numeric-owner --sparse -Pmacvf /sdcard/mini-termux.tar.gz "${script_dir}" "${script_dir}/../unpack_mini-termux.sh"
