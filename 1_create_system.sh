#!/bin/bash
#
# OpenVZ Template OS Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
#
echo "Where to create the system? (default /mnt/dice)"
read input_path

echo "clean umount"
umount $input_path/dev
umount $input_path/proc
umount $input_path/sys

echo "Clear/Create the path"
rm -rf $input_path/* 
mkdir $input_path


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

case "$input_distri" in
     ubuntu|debian)
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
		echo "x86 of amd64?"
		echo ""
		read input_arch
		case "$input_arch" in
			x86)
				echo ""
				echo "i486, i686, or i686-hardened?"
				echo ""
				read input_variant
				case "$input_variant" in
					i486)
						wget ftp://distfiles.gentoo.org/pub/gentoo/releases/x86/current-stage3/stage3-i486-*.tar.bz2
						wget ftp://distfiles.gentoo.org/pub/gentoo/releases/x86/current-stage3/stage3-i486-*.tar.bz2.DIGEST
						;;
					i686)
						wget ftp://distfiles.gentoo.org/pub/gentoo/releases/x86/current-stage3/stage3-i686-*.tar.bz2
						wget ftp://distfiles.gentoo.org/pub/gentoo/releases/x86/current-stage3/stage3-i686-*.tar.bz2.DIGEST
						;;
					i686-hardened)
						wget ftp://distfiles.gentoo.org/pub/gentoo/releases/x86/current-stage3/hardened/stage3-i686-hardened-*.tar.bz2
						wget ftp://distfiles.gentoo.org/pub/gentoo/releases/x86/current-stage3/hardened/stage3-i686-hardened-*.tar.bz2
						;;
					*)
						echo "Variante" $input_variant "not supported yet. Sorry."
                				exit 0
                				;; esac
				;; #END x86
			amd64)
				echo ""
				echo "multilib, nomultilib, or nomultilib-hardened?"
				echo ""
				read input_variant
				case "$input_variant" in
					nomultilib)
						touch $input_path/.nomultilib
						wget ftp://distfiles.gentoo.org/pub/gentoo/releases/amd64/current-stage3/stage3-amd64-*.tar.bz2
						wget ftp://distfiles.gentoo.org/pub/gentoo/releases/amd64/current-stage3/stage3-amd64-*.tar.bz2.DIGEST
						;;
					multilib)
						wget ftp://distfiles.gentoo.org/pub/gentoo/releases/amd64/current-stage3/stage3-amd64-*.tar.bz2
						wget ftp://distfiles.gentoo.org/pub/gentoo/releases/amd64/current-stage3/stage3-amd64-*.tar.bz2.DIGEST
						;;
					nomultilib-hardened)
						wget ftp://distfiles.gentoo.org/pub/gentoo/releases/amd64/current-stage3/hardened/stage3-amd64-hardened+nomultilib-*.tar.bz2
						wget ftp://distfiles.gentoo.org/pub/gentoo/releases/amd64/current-stage3/hardened/stage3-amd64-hardened+nomultilib-*.tar.bz2.DIGEST
						;;
					*)
						echo "Variante" $input_variant "not supported yet. Sorry."
                				exit 0
                				;; esac
				;; #END amd64
			*)
				echo "Arch" $input_arch "not supported yet. Sorry."
				exit 0
				;; esac

		wget ftp://distfiles.gentoo.org/pub/gentoo/snapshots/portage-latest.tar.bz2
		wget ftp://distfiles.gentoo.org/pub/gentoo/snapshots/portage-latest.tar.bz2.md5sum
		clear
		md5sum -c stage3*.DIGEST
		md5sum -c portage-latest.tar.bz2.md5sum
		echo ""
		echo ""
		echo "Please verify that both, the stage3 and the portage-latest archive have passed the md5sum check. If so please enter \'y\', otherwise press Ctrl+C to start over"
		read input_valid
		#TODO Ordentliche Abfrage einbauen
		tar xjpf stage3*.tar.bz2 -C $input_path
		tar xjpf portage-latest.tar.bz2 -C $input_path/usr/
		rm -i stage3*.tar.bz2*
		rm -i portage-latest*.tar.bz2*
		cp -L /etc/resolv.conf $input_path/etc/
		#TODO evtl. wieder unten fuer alle mounten
		mount -o bind /dev $input_path/dev
		;; #END gentoo

     *)
                echo "Distri" $input_distri "not supported yet. Sorry."
                exit 0
                ;; esac
clear


wget http://files.yoschi.cc/vpsmem
chmod +x vpsmem
mv vpsmem $input_path/usr/local/bin

#mount -o bind /dev $input_path/dev
mount -t proc none $input_path/proc # because another openssh-server will not configured to the end
#mount -t sysfs none $input_path/sys

chroot $input_path
