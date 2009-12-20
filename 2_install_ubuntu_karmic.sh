#!/bin/bash

mkdir /etc/init
cat << EOF > /etc/init/openvz.conf
# OpenVZ – Fix init sequence to have OpenVZ working with upstart
description “Fix OpenVZ”

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
initctl emit filesystem –-no-wait
initctl emit local-filesystems –-no-wait
initctl emit virtual-filesystems –-no-wait
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

cat << EOF > /etc/fstab
proc  /proc       proc    defaults    0    0
none  /dev/pts    devpts  rw          0    0
EOF

apt-get update
apt-get dist-upgrade -y
apt-get install aptitude language-pack-en-base bash-completion logrotate ssh lsof nano quota rsync vim wget -y --without-recommends
apt-get clean

# Link /etc/mtab to /proc/mounts, so df and friends will work: 
rm -f /etc/mtab
ln -s /proc/mounts /etc/mtab
update-rc.d -f mtab.sh remove

# Netzwerk
echo "hostname" > /etc/hostname
echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts

# Note: the warning "/sbin/MAKEDEV: warning: can't read /proc/devices" is safe to ignore.
cd /dev && /sbin/MAKEDEV ptyp && cd /

#umount /dev
umount /proc
#umount /sys

passwd
