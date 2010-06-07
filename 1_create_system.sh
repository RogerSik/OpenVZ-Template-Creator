#!/bin/bash
#
# OpenVZ Template OS Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
#
echo "What distri want you install?"
echo "Supported:"
echo "* Ubuntu 8.04 - Hardy Haron (hardy)"
echo "* Ubuntu 8.10 - Intrepid Ibex (intrepid)"
echo "* Ubuntu 9.04 - Jaunty  Jackalope (jaunty)"
echo "* Ubuntu 9.10 - Karmic Koala (karmic)"
echo "* Ubuntu 10.04 - Lucid Lync (lucid)"
echo "* Gentoo - current (gentoo)"
echo " = "
read input_distri
echo ""
echo "Where to create the system? (default /mnt/dice)"
read input_path

# clean umount
umount $input_path/dev  2>/dev/null
umount $input_path/proc 2>/dev/null
umount $input_path/sys 2>/dev/null

echo "Clear/Create the path"
rm -rf $input_path/* 
mkdir $input_path

case "$input_distri" in
     hardy|intrepid|jaunty|karmic|lucid)
		echo "What is your host distro?"
		echo "Supported: debian | ubuntu"
		read input_host_distri

		case "$input_host_distri" in
		     ubuntu|debian)
				echo "Download and installation the latest debootstrap."
				wget http://files.yoschi.cc/debs/debootstrap.deb
				dpkg -i debootstrap.deb
				rm debootstrap.deb
				;;
		     *)
				echo "Distri" $input_host_distri "not supported yet. Sorry."
				exit 0
				;; esac
		clear

		echo ""
		echo "i386 or amd64?"
		echo ""
		read input_arch

		debootstrap --variant=minbase --arch $input_arch $input_distri $input_path
                ;;
     gentoo)
		echo ""
		echo "x86 or amd64?"
		echo ""
		read input_arch
		TMP_DIR="openvz-template-creator-gentooinst-tmp"
		mkdir ${TMP_DIR}
		cd ${TMP_DIR}

		clear
		echo ""
		echo "Please download a stage3 Archive AND the .DIGESTS files as well"
		echo "(Press Return to start lynx)"
		read $confirm
		MIRROR="http://ftp.uni-erlangen.de/pub/mirrors/gentoo/"
		URL=${MIRROR}"releases/"${input_arch}
		lynx ${URL}

		wget ${MIRROR}snapshots/portage-latest.tar.bz2
		wget ${MIRROR}snapshots/portage-latest.tar.bz2.md5sum
		clear

		#Create one digests file with only relevant files
		grep tar.bz2$ stage3-amd64-20100514.tar.bz2.DIGESTS > digests
		grep portage-latest.tar.bz2$ portage-latest.tar.bz2.md5sum >> digests
		#Check the digests
		md5sum -c digests
		if [ $? -ne 0 ]
		then
			echo "Error while downloading files. md5sums did not match" >&2
			exit 1
		fi
		echo "All Checksums correct"
		rm digests

		echo ""
		echo "Extracting Stage3"
		tar xjpf stage3*.tar.bz2 -C $input_path
		echo "Extracting Portage tree"
		tar xjpf portage-latest.tar.bz2 -C $input_path/usr/

		echo ""
		echo ""
		echo "Remove install Archives"
		cd ..
		rm -ri ${TMP_DIR}

		echo ""
		echo "Preparing chroot"
		cp -L /etc/resolv.conf $input_path/etc/
		;; #END gentoo

     *)
                echo "Distri" $input_distri "not supported yet. Sorry."
                exit 0
                ;; esac
clear

wget -q http://files.yoschi.cc/vpsmem -P $input_path/usr/local/bin
chmod +x $input_path/usr/local/bin/vpsmem

#if dev is mounted the mknod commands in the install scripts will create the devices on the host machine and not inside the template
#mount -o bind /dev $input_path/dev
mount -t proc none $input_path/proc # because another openssh-server will not configured to the end
#mount -t sysfs none $input_path/sys

chroot $input_path
