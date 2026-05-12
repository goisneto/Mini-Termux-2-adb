#!/system/bin/sh
exec /system/bin/tar --selinux --owner root:0 --group root:0 --numeric-owner --sparse -Pmaxvf /sdcard/mini-termux.tar.gz
