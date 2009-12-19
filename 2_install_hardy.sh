#!/bin/bash

# Remove not necessary programs
dpkg -P ubuntu-minimal wpasupplicant wireless-tools \
  udev pcmciautils initramfs-tools console-setup \
  xkb-data usbutils mii-diag ethtool \
  module-init-tools console-tools \
  console-terminus busybox-initramfs libvolume-id0 \
  ntpdate eject pciutils tasksel tasksel-data \
  laptop-detect

rm -fr /lib/udev
initctl stop tty{1,2,3,4,5,6}
rm /etc/event.d/tty*
ln -s /bin/true /sbin/modprobe

cat << EOF > /etc/apt/sources.list
deb http://de.archive.ubuntu.com/ubuntu hardy main #restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu hardy main #restricted universe multiverse

deb http://de.archive.ubuntu.com/ubuntu hardy-updates main #restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu hardy-updates main #restricted universe multiverse

deb http://de.archive.ubuntu.com/ubuntu hardy-security main #restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu hardy-security main #restricted universe multiverse

#deb http://de.archive.ubuntu.com/ubuntu hardy-backports main #restricted universe multiverse
#deb-src http://de.archive.ubuntu.com/ubuntu hardy-backports main #restricted universe multiverse
EOF

cat << EOF > /etc/fstab
proc  /proc       proc    defaults    0    0
none  /dev/pts    devpts  rw          0    0
EOF

aptitude update
aptitude dist-upgrade -y
aptitude install language-pack-en-base bash-completion logrotate ssh lsof nano quota rsync vim -y --without-recommends
aptitude clean

# Link /etc/mtab to /proc/mounts, so df and friends will work: 
rm -f /etc/mtab
#cp -R /proc/mounts /etc/mtab
ln -s /proc/mounts /etc/mtab
update-rc.d -f mtab.sh remove

# Network
echo "hostname" > /etc/hostname
echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts

# Note: the warning "/sbin/MAKEDEV: warning: can't read /proc/devices" is safe to ignore.
cd /dev && /sbin/MAKEDEV ptyp

# Because klogd will hang up the system
update-rc.d -f klogd remove

#umount /dev
umount /proc
#umount /sys

# the real password set OpenVZ!
passwd -L root




