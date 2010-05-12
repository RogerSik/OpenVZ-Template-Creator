#!/bin/bash
#
# OpenVZ Template OS Creator [upgrade skript]
# http://github.com/RogerSik/OpenVZ-Template-Creator
#

cat << EOF > /etc/init/openvz.conf
# OpenVZ - Fix init sequence to have OpenVZ working with upstart
# by Stephane Graber [1] modified by bodhi.zazen [2] to work with Proxmox 
# [1] https://bugs.launchpad.net/ubuntu/+source/mountall/+bug/436130/comments/34
# [2] http://blog.bodhizazen.net/linux/ubuntu-10-04-openvz-templates/

description "Fix OpenVZ"

start on startup

task
pre-start script
mount -t devpts devpts /dev/pts
mount -t tmpfs varrun /var/run
mount -t tmpfs varlock /var/lock
mkdir -p /var/run/network
if [ ! -e /etc/mtab ]; then
cat /proc/mounts > /etc/mtab
fi
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
deb http://de.archive.ubuntu.com/ubuntu lucid main restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu lucid main restricted universe multiverse

deb http://de.archive.ubuntu.com/ubuntu lucid-updates main restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu lucid-updates main restricted universe multiverse

deb http://de.archive.ubuntu.com/ubuntu lucid-security main restricted universe multiverse
deb-src http://de.archive.ubuntu.com/ubuntu lucid-security main restricted universe multiverse

#deb http://de.archive.ubuntu.com/ubuntu lucid-backports main #restricted universe multiverse
#deb-src http://de.archive.ubuntu.com/ubuntu lucid-backports main #restricted universe multiverse
EOF

apt-get update
apt-get dist-upgrade -y

# because another a upgrade would begins the booting problems again
echo "mountall hold"|dpkg --set-selections
echo "upstart hold"|dpkg --set-selections

# modprobe fix
rm /sbin/modprobe
ln -s /bin/true /sbin/modprobe

# ssh fix
sed -i -e 's_oom never_#oom never_g' /etc/init/ssh.conf

# Removing of broken scripts
cd /etc/init/
rm -f console* control* hwclock* module* mount* network-interface* plymouth* procps* tty* udev* upstart*

clear
echo -e "\e[01;31m ######################### \033[0m"
echo "Don't forget to comment in"
echo "console output"
echo "env INIT_VERBOSE"
echo "in /etc/init/rc.conf"
echo -e "\e[01;31m ######################### \033[0m"
