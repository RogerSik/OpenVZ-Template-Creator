#!/bin/bash
#
# OpenVZ Template OS Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
#

rm /etc/init/tty*

mkdir /etc/init
cat << EOF > /etc/init/openvz.conf
# OpenVZ – Fix init sequence to have OpenVZ working with upstart
# by http://blog.bodhizazen.net/linux/openvz-ubuntu-9-10-templates/
description "Fix OpenVZ"

start on startup

task
pre-start script
mount -t proc proc /proc
mount -t devpts devpts /dev/pts
mount -t sysfs sys /sys
mount -t tmpfs varrun /var/run
mount -t tmpfs varlock /var/lock
mkdir -p /var/run/network
touch /var/run/utmp
chmod 664 /var/run/utmp
chown root.utmp /var/run/utmp
if [ "$(find /etc/network/ -name upstart -type f)" ]; then
chmod -x /etc/network/*/upstart || true
fi
end script

script
start networking
initctl emit filesystem --no-wait
initctl emit local-filesystems --no-wait
initctl emit virtual-filesystems --no-wait
init 2
end script
EOF

cat << EOF > /etc/apt/sources.list
deb http://de.archive.ubuntu.com/ubuntu karmic main #restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu karmic main #restricted universe multiverse

deb http://de.archive.ubuntu.com/ubuntu karmic-updates main #restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu karmic-updates main #restricted universe multiverse

deb http://de.archive.ubuntu.com/ubuntu karmic-security main #restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu karmic-security main #restricted universe multiverse

#deb http://de.archive.ubuntu.com/ubuntu karmic-backports main #restricted universe multiverse
#deb-src http://de.archive.ubuntu.com/ubuntu karmic-backports main #restricted universe multiverse
EOF

source ./10_distri_install_packages.sh
apt-get update
apt-get install gpgv -y --force-yes
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

# Netzwerk
echo "hostname" > /etc/hostname
echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts

# Note: the warning "/sbin/MAKEDEV: warning: can't read /proc/devices" is safe to ignore.
cd /dev && /sbin/MAKEDEV ptyp && cd /

#umount /dev
umount /proc
#umount /sys

# the real password set OpenVZ!
passwd
