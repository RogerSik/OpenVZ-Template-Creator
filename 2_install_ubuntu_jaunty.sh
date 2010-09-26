#!/bin/bash
#
# OpenVZ Template OS Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
#

rm /etc/event.d/tty*
rm -fr /lib/udev

cat << EOF > /etc/apt/sources.list
deb http://de.archive.ubuntu.com/ubuntu jaunty main restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu jaunty main restricted universe multiverse
 
deb http://de.archive.ubuntu.com/ubuntu jaunty-updates main restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu jaunty-updates main restricted universe multiverse
 
deb http://de.archive.ubuntu.com/ubuntu jaunty-security main restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu jaunty-security main restricted universe multiverse
 
#deb http://de.archive.ubuntu.com/ubuntu jaunty-backports main #restricted universe multiverse
#deb-src http://de.archive.ubuntu.com/ubuntu jaunty-backports main #restricted universe multiverse
EOF

source ./10_distri_install_packages.sh
apt-get update
apt-get install gpgv -y --force-yes
apt-get update
apt-get dist-upgrade -y
apt-get install $ubuntu_all -y --force-yes
apt-get clean

# Link /etc/mtab to /proc/mounts, so df and friends will work: 
rm -f /etc/mtab
ln -s /proc/mounts /etc/mtab
update-rc.d -f mtab.sh remove

# tun and fuse device create
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun
mknod /dev/fuse c 10 229

# Network
echo "hostname" > /etc/hostname
echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts

# Note: the warning "/sbin/MAKEDEV: warning: can't read /proc/devices" is safe to ignore.
cd /dev && /sbin/MAKEDEV ptyp && cd /

# disable some unnecessary boot scripts
update-rc.d -f klogd remove
update-rc.d -f ondemand remove

#umount /dev
umount /proc
#umount /sys

# the real password set OpenVZ!
passwd

echo "Don't forget to add"
echo -e "\e[00;31m[ -d /var/run/network ] || mkdir /var/run/network\e[00m"
echo "in /etc/init.d/networking after"
echo "[ -x /sbin/ifup ] || exit 0"
