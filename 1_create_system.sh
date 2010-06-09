#!/bin/bash
#
# OpenVZ Template Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
#
 dialog --title "OpenVZ Template Creator" --textbox ./LICENSE 20 80

 dialog --no-cancel --menu "What is your host?" 10 30 3  \
	"Debian" . \
	"Ubuntu" . \
	"None of both" . 2>/tmp/input_host.tmp
	input_host=`cat /tmp/input_host.tmp`

 dialog --no-cancel --menu  "Which distribution want you build?" 15 50 7 \
	hardy "Ubuntu 8.04 - Hardy Heron"  \
	intrepid "Ubuntu 8.10 - Intrepid Ibex"  \
	jaunty "Ubuntu 9.04 - Jaunty  Jackalope"  \
	karmic "Ubuntu 9.10 - Karmic Koala"   \
	lucid "Ubuntu 10.04 - Lucid Lync"  \
	gentoo "Gentoo"  \
	lenny "Debian 5 - Lenny" 2>/tmp/input_distri.tmp
	input_distri=`cat /tmp/input_distri.tmp`

 dialog --no-cancel --inputbox "Where to create the system? (default /mnt/dice/)" 8 60 "/mnt/dice/" 2>/tmp/input_path.tmp
	input_path=`cat /tmp/input_path.tmp`

# clean umount
umount $input_path/dev 2>/dev/null
umount $input_path/proc 2>/dev/null
umount $input_path/sys 2>/dev/null

# clear/create the path
rm -rf $input_path/* 
if [ ! -d $input_path ]; then
    mkdir $input_path
fi 

case "$input_distri" in
     hardy|intrepid|jaunty|karmic|lucid|lenny)
		case "$input_host" in
		     Debian|Ubuntu)
				echo "Download and installation the latest debootstrap."
				wget http://files.yoschi.cc/debs/debootstrap.deb
				dpkg -i debootstrap.deb
				rm debootstrap.deb
				;;
		     *)
				dialog --msgbox "Host distri not supported yet. Sorry." 5 42
				exit 0
				;; esac
		clear

		dialog --no-cancel --menu "i386 or amd64?" 15 50 6  \
		i386 . \
		amd64 . 2>/tmp/input_arch.tmp
		input_arch=`cat /tmp/input_arch.tmp`

		debootstrap --variant=minbase --arch $input_arch $input_distri $input_path
                ;;
                
     gentoo)
		dialog  --no-cancel --menu "x86 or amd64?" 15 50 6  \
		x86 . \
		amd64 . 2>/tmp/input_arch.tmp
		input_arch=`cat /tmp/input_arch.tmp`

		TMP_DIR="/tmp/openvz-tc-gentoo"
		mkdir ${TMP_DIR}
		cd ${TMP_DIR}

		clear
		dialog --msgbox "Please download a stage3 Archive AND the .DIGESTS files as well." 5 70
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
			dialog --msgbox "Error while downloading files. md5sums did not match."  5 60
			exit 1
		fi
		dialog --msgbox "All Checksums correct."  5 26
		rm -f digests

		dialog --msgbox "Extracting Stage3."  5 22
		tar xjpf stage3*.tar.bz2 -C $input_path
		dialog --msgbox "Extracting Portage tree." 5 28
		tar xjpf portage-latest.tar.bz2 -C $input_path/usr/

		dialog --msgbox  "Remove install archives." 5 28

		cd ..
		rm -rf ${TMP_DIR}
		;; #END gentoo

     *)
                exit 0
                ;; esac
clear

cp -R /etc/resolv.conf $input_path/etc/
wget -q http://files.yoschi.cc/vpsmem -P $input_path/usr/local/bin
chmod +x $input_path/usr/local/bin/vpsmem

#if dev is mounted the mknod commands in the install scripts will create the devices on the host machine and not inside the template
#mount -o bind /dev $input_path/dev
mount -t proc none $input_path/proc # because another openssh-server will not configured to the end
#mount -t sysfs none $input_path/sys

dialog --msgbox "Done. Now you are in your new system chrooted." 5 50
chroot $input_path

