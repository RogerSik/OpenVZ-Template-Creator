#!/bin/bash
#
# OpenVZ Template OS Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
#

cat << EOF > /etc/init/mountall.conf
# mountall - Mount filesystems on boot
#
# This helper mounts filesystems in the correct order as the devices
# and mountpoints become available.
#

description	"Mount filesystems on boot"

start on startup

task

emits virtual-filesystems
emits local-filesystems
emits remote-filesystems
emits all-swaps
emits all-filesystems
emits filesystem

pre-start script
    find /var/run -mindepth 1 -maxdepth 1 | grep -v utmp | xargs rm -rf
    mkdir -p /var/run/network
    find /var/lock -mindepth 1 -maxdepth 1 | xargs rm -rf
end script

post-start script
    initctl emit -n filesystem
    initctl emit -n all-swaps
    initctl emit -n all-filesystems
    initctl emit -n virtual-filesystems
    initctl emit -n remote-filesystems
    initctl emit -n local-filesystems
    mount -a
end script


EOF

cat << EOF > /etc/apt/sources.list
deb http://de.archive.ubuntu.com/ubuntu natty main restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu natty main restricted universe multiverse

deb http://de.archive.ubuntu.com/ubuntu natty-updates main restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu natty-updates main restricted universe multiverse

deb http://de.archive.ubuntu.com/ubuntu natty-security main restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu natty-security main restricted universe multiverse

#deb http://de.archive.ubuntu.com/ubuntu natty-backports main #restricted universe multiverse
#deb-src http://de.archive.ubuntu.com/ubuntu natty-backports main #restricted universe multiverse
EOF

source ./5_distri_install_packages.sh
apt-get update
apt-get install gpgv --force-yes -y
apt-get update
apt-get dist-upgrade -y --force-yes
apt-get install $ubuntu_all -y --force-yes
apt-get clean
apt-get autoremove

# modprobe fix
rm /sbin/modprobe
ln -s /bin/true /sbin/modprobe

# Removing of broken scripts
cd /etc/init/
rm -f tty

# network
echo "hostname" > /etc/hostname
echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts

# the real password set OpenVZ!
passwd

clear
