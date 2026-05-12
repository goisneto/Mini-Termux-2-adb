ls
exit
LS
ls
owd
pwd
pkg
termux-change-repo 
ls
mv /data/local/tmp/mini-termux/debs .
cd debs/
ls
dpkg --force-all -R -i .
cd ..
ls
termux-change-repo 
mkdir /data/data/com.termux/files/usr/etc/apt/apt.conf.d/
mkdir /data/data/com.termux/files/usr/etc/apt/preferences.d/
exit
rm -rf debs/
exit
