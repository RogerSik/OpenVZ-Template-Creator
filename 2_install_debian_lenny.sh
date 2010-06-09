#!/bin/bash
#
# OpenVZ Template OS Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
#
# Debian Lenny part by: jrocho (http://github.com/jrocho/OpenVZ-Template-Creator)
# E-Mail: jan.rocho@carrot-server.com

chmod 700 /root

apt-get update
apt-get install aptitude dialog -y

sed -i -e '/getty/d' /etc/inittab

sed -i -e 's@\([[:space:]]\)\(/var/log/\)@\1-\2@' /etc/*syslog.conf

rm -f /etc/mtab
ln -s /proc/mounts /etc/mtab

cat << EOF > /etc/resolv.conf
nameserver 213.133.98.98
nameserver 213.133.99.99
nameserver 213.133.100.100

EOF

cat << EOF > /etc/apt/sources.list
deb http://ftp.de.debian.org/debian/ lenny main contrib non-free
deb-src http://ftp.de.debian.org/debian/ lenny main contrib non-free
deb http://security.debian.org/ lenny/updates main contrib non-free
deb http://volatile.debian.org/debian-volatile lenny/volatile main non-free

EOF

aptitude update
aptitude dist-upgrade -y
aptitude install ssh bzip2 vim bc lsof nano quota rsync wget less locales -y
aptitude clean

# Link /etc/mtab to /proc/mounts, so df and friends will work: 
rm -f /etc/mtab
ln -s /proc/mounts /etc/mtab

# tun and fuse device create
mkdir -m 0770 /dev/net
mknod -m 0660 /dev/net/tun c 10 200
chown root:root /dev/net/tun
mknod -m 0660 /dev/fuse c 10 229
chown root:ssh /dev/fuse

# SSH Setup
rm /etc/ssh/moduli
echo "# Default settings for openssh-server. This file is sourced by /bin/sh from" > /etc/default/ssh
echo "# /etc/init.d/ssh." >> /etc/default/ssh
echo >> /etc/default/ssh
echo "# Options to pass to sshd" >> /etc/default/ssh
echo "SSHD_OPTS=" >> /etc/default/ssh
echo >> /etc/default/ssh
echo "# OOM-killer adjustment for sshd (see" >> /etc/default/ssh
echo "# linux/Documentation/filesystems/proc.txt; lower values reduce likelihood" >> /etc/default/ssh
echo "# of being killed, while -17 means the OOM-killer will ignore sshd; set to" >> /etc/default/ssh
echo "# the empty string to skip adjustment)" >> /etc/default/ssh
echo "#SSHD_OOM_ADJUST=-17" >> /etc/default/ssh
echo "unset SSHD_OOM_ADJUST" >> /etc/default/ssh

# Network
echo "hostname" > /etc/hostname
echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts

# Note: the warning "/sbin/MAKEDEV: warning: can't read /proc/devices" is safe to ignore.
cd /dev && /sbin/MAKEDEV ptyp && cd /

# disable some services
update-rc.d -f klogd remove
update-rc.d -f quotarpc remove
update-rc.d -f exim4 remove
update-rc.d -f inetd remove

# set the default timezone
echo "Europe/Vienna" > /etc/timezone

# get config files
rm /etc/nanorc
wget -q http://zak.rocho.org/carrot/nanorc -P /etc
rm /etc/vim/vimrc
wget -q http://zak.rocho.org/carrot/vimrc -P /etc/vim

# automatically create the right /lib/modules for the current kernel
wget -q http://zak.rocho.org/carrot/iptables -P /etc/init.d
chmod 755 /etc/init.d/iptables
update-rc.d iptables start 99 2 3 4 5 . stop 00 0 1 6 .

# configure the locales
wget -q http://zak.rocho.org/carrot/locale.gen -P /etc
chmod 644 /etc/locale.gen
/usr/sbin/locale-gen

#umount /dev
umount /proc
#umount /sys

# the real password set OpenVZ!
passwd
