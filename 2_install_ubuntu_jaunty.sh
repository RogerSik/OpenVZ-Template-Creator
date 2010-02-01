#!/bin/bash
#
# OpenVZ Template OS Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
#
# Remove not necessary programs 
apt-get remove --purge -y ubuntu-minimal wpasupplicant wireless-tools \
  udev pcmciautils initramfs-tools console-setup \
  xkb-data module-init-tools \
  console-terminus busybox-initramfs \
  ntpdate eject pciutils tasksel tasksel-data laptop-detect

rm /etc/event.d/tty*
rm -fr /lib/udev

cat << EOF > /etc/apt/sources.list
deb http://de.archive.ubuntu.com/ubuntu jaunty main #restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu jaunty main #restricted universe multiverse
 
deb http://de.archive.ubuntu.com/ubuntu jaunty-updates main #restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu jaunty-updates main #restricted universe multiverse
 
deb http://de.archive.ubuntu.com/ubuntu jaunty-security main #restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu jaunty-security main #restricted universe multiverse
 
#deb http://de.archive.ubuntu.com/ubuntu jaunty-backports main #restricted universe multiverse
#deb-src http://de.archive.ubuntu.com/ubuntu jaunty-backports main #restricted universe multiverse
EOF

cat << EOF > /etc/fstab
proc  /proc       proc    defaults    0    0
none  /dev/pts    devpts  rw          0    0
EOF

apt-get update
apt-get dist-upgrade -y
apt-get install anacron aptitude bc language-pack-en language-pack-de bash-completion logrotate ssh lsof man nano quota rsync vim wget -y
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
