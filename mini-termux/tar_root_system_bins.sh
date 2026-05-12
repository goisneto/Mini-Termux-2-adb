#!/system/bin/sh
script="${BASH_SOURCE[0]}"
if [ -z "${script}" ]; then
	script="$(/system/bin/realpath "$0")"
fi
script_dir="$(/system/bin/dirname "${script}")"

name="root_system_bins_samsung_$(/system/bin/getprop ro.bootimage.build.version.incremental)"
/system/bin/mount |
/system/bin/cut -d' ' -f3 |
/system/bin/xargs -r /system/bin/sh -c 'exec /system/bin/find "$0" "$@" \( -type d -or -type l \) \( -name bin -or -name xbin -or -name lib -or -name lib32 -or -name lib64 \)' 2>/dev/null |
/system/bin/xargs -r /system/bin/sh -c 'exec /system/bin/find "$0" "$@"' 2>/dev/null > /sdcard/binaries.list
/system/bin/xargs -r /system/bin/sh -c 'exec /system/bin/find "$0" "$@" -type d' 2>/dev/null < /sdcard/binaries.list |
/system/bin/xargs -r /system/bin/sh -c 'for d in "$0" "$@"; do eval "/system/bin/find ${d}/*"; done' 2>/dev/null > /sdcard/binaries.list.1
/system/bin/cat /sdcard/binaries.list /sdcard/binaries.list.1 > /sdcard/binaries.list.2
/system/bin/rm /sdcard/binaries.list /sdcard/binaries.list.1
/system/bin/mv /sdcard/binaries.list.2 /sdcard/binaries.list
echo "/linkerconfig/ld.config.txt" >> /sdcard/binaries.list
/system/bin/xargs -r /system/bin/tar --selinux --mode 7777 --owner root:0 --group root:0 --numeric-owner --sparse -omacvf "/sdcard/${name}.tar.gz" < /sdcard/binaries.list
dest="$(/system/bin/dirname "${script_dir}")/${name}"
/system/bin/mkdir -p "${dest}"
/system/bin/tar --selinux --mode 7777 --owner root:0 --group root:0 --numeric-owner --sparse -omaxvf "/sdcard/${name}.tar.gz" -C "${dest}"
for binary in $(/system/bin/cat /sdcard/binaries.list); do
	if [ ! -e "${dest}${binary}" ]; then
		/system/bin/mkdir -p "$(/system/bin/dirname "${dest}${binary}")"
		(
			/system/bin/cat < "${binary}" > "${dest}${binary}" &&
			/system/bin/chmod 7777 "${dest}${binary}"
		) || (
			/system/bin/base64 - < "${binary}" | /system/bin/base64 -d - > "${dest}${binary}" &&
			/system/bin/chmod 7777 "${dest}${binary}"
		) || (
			/system/bin/echo "${binary}" >> "${dest}/binaries_bypass.list"
			/system/bin/touch "${dest}${binary}"
			/system/bin/chmod 7777 "${dest}${binary}"
		)
	fi
done
/system/bin/rm "/sdcard/${name}.tar.gz" /sdcard/binaries.list
if [ -z "${proot_mini_termux}" ]; then
	proot_mini_termux="${script_dir}/proot-mini-termux"
fi
if [ -e "${proot_mini_termux}" ]; then
	/system/bin/sed -i "s~root_system_bins_dir=\"REPLACE-ME\"~root_system_bins_dir=\"${dest}\"~g" "${proot_mini_termux}"
	/system/bin/chmod 7777 "${proot_mini_termux}"
	exec /system/bin/sh "${proot_mini_termux}"
fi
