#!/bin/bash
#
# OpenVZ Template OS Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
#
# Debian Lenny part by: jrocho (http://github.com/jrocho/OpenVZ-Template-Creator)
# E-Mail: jan.rocho@carrot-server.com

cat << EOF > /etc/apt/sources.list
deb http://ftp.de.debian.org/debian/ lenny main contrib non-free
deb-src http://ftp.de.debian.org/debian/ lenny main contrib non-free
deb http://security.debian.org/ lenny/updates main contrib non-free
deb http://volatile.debian.org/debian-volatile lenny/volatile main non-free
EOF

apt-get update
apt-get dist-upgrade -y
apt-get install aptitude bash-completion bzip2 bc inetutils-ping less locales logrotate lsof man nano quota rsync ssh sshfs vim wget whiptail -y
apt-get clean
apt-get autoremove

# Disable running gettys on terminals as a VE does not have any
sed -i -e '/getty/d' /etc/inittab

# Turn off doing sync() on every write for syslog's log files, to improve I/O performance:
sed -i -e 's@\([[:space:]]\)\(/var/log/\)@\1-\2@' /etc/*syslog.conf

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
cat << EOF > /etc/default/ssh
# Default settings for openssh-server. This file is sourced by /bin/sh from
# /etc/init.d/ssh.

# Options to pass to sshd
SSHD_OPTS=

# OOM-killer adjustment for sshd (see
# linux/Documentation/filesystems/proc.txt; lower values reduce likelihood
# of being killed, while -17 means the OOM-killer will ignore sshd; set to
# the empty string to skip adjustment)
#SSHD_OOM_ADJUST=-17
unset SSHD_OOM_ADJUST
EOF

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

# automatically create the right /lib/modules for the current kernel
wget -q http://files.openvz-tc.org/scripts/iptables -P /etc/init.d
chmod 755 /etc/init.d/iptables
update-rc.d iptables start 99 2 3 4 5 . stop 00 0 1 6 .

#umount /dev
umount /proc
#umount /sys

# the real password set OpenVZ!
passwd
