#!/bin/bash
#
# OpenVZ Template OS Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
#
echo "Here a list of supported hosts and distributions"
echo "Host: Debian/Ubuntu"
echo "* Ubuntu 8.04 - Hardy Haron (hardy)"
echo "* Ubuntu 8.10 - Intrepid Ibex (intrepid)"
echo "* Ubuntu 9.04 - Jaunty  Jackalope (jaunty)"
echo "* Ubuntu 9.10 - Karmic Koala (karmic)"
echo "* Ubuntu 10.04 - Lucid Lync (lucid)"
echo ""
#echo "Not necesarry which host you have (none)"
#echo "* Gentoo (gentoo)"
echo ""
echo "Your host and which wanted distro"
echo "example 'debian ubuntu' (Debian host and Ubuntu new distribution)"
read input_host
echo ""
echo "Which distro version? (example 'lucid')"
read input_distri_version
echo ""
echo "i386 or amd64?"
read input_distri_arch
echo ""
echo "Where to create the system? (default /mnt/dice)"
read input_path

case $input_host in
	'debian ubuntu'|'ubuntu ubuntu')
		# Downloading and installing the newest debootstrap
		wget -q http://files.yoschi.cc/debs/debootstrap.deb
		dpkg -i debootstrap.deb
		rm debootstrap.deb
		debootstrap --variant=minbase --arch $input_distri_arch $input_distri_version $input_path
		;;
#	'none gentoo')
#		;;	       
     *)
		echo "This combination " $input_host_distri " is not supported yet. Sorry."
		exit 0
		;; esac

wget -q http://files.yoschi.cc/vpsmem -P $input_path/usr/local/bin
chmod +x $input_path/usr/local/bin/vpsmem

#mount -o bind /dev $input_path/dev
mount -t proc none $input_path/proc # because another openssh-server will not configured to the end
#mount -t sysfs none $input_path/sys

chroot $input_path
