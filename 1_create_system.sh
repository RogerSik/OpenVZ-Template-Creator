#!/bin/bash
#
# OpenVZ Template Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
#
license=`dirname $0`"/LICENSE"
dialog --title "OpenVZ Template Creator" --textbox ${license} 20 80

dialog --no-cancel --menu  "Which distribution want you build?" 15 50 7 \
	hardy "Ubuntu 8.04 - Hardy Heron"  \
	intrepid "Ubuntu 8.10 - Intrepid Ibex"  \
	jaunty "Ubuntu 9.04 - Jaunty  Jackalope"  \
	karmic "Ubuntu 9.10 - Karmic Koala"   \
	lucid "Ubuntu 10.04 - Lucid Lync"  \
	gentoo "Gentoo Linux (stage3)"  \
	lenny "Debian 5 - Lenny" 2>/tmp/input_distri.tmp
	input_distri=`cat /tmp/input_distri.tmp`

if [ $input_distri != "gentoo" ]; then
	dialog --no-cancel --menu "What is your host?" 10 30 3  \
		"Debian" . \
		"Ubuntu" . \
		"None of both" . 2>/tmp/input_host.tmp
	input_host=`cat /tmp/input_host.tmp`
fi

dialog --no-cancel --inputbox "Where to create the system? (default /mnt/dice/)" 8 60 "/mnt/dice/" 2>/tmp/input_path.tmp
	input_path=`cat /tmp/input_path.tmp`

dialog --no-cancel --menu  "Which nameserver want you use for your template?" 10 55 3 \
	"locale" "Use the resolv.conf from the host."  \
	"Google" "Use the public DNS Server from Google."  \
	"Nothing" "Dont use a nameserver." 2>/tmp/input_nameserver.tmp
	input_nameserver=`cat /tmp/input_nameserver.tmp`

# clean umount
umount $input_path/dev >/dev/null 2>&1
umount $input_path/proc >/dev/null 2>&1
umount $input_path/sys >/dev/null 2>&1

# clear/create the path
if [ -f $input_path ]; then
	echo ${input_path}" is a file, aborting." 1>&2
	exit 1;
else
	if [ -d $input_path ]; then
		dialog --yesno "Will delete everithing in $input_path\nProceed?" 0 0
		if [ $? -ne 0 ]; then
			clear
			exit 0
		else
			rm -rf "$input_path/*"
		fi
	fi
	else
		mkdir $input_path
	fi
fi

case "$input_distri" in
     hardy|intrepid|jaunty|karmic|lucid|lenny)
		case "$input_host" in
		     Debian|Ubuntu)
				echo "Download and installation the latest debootstrap."
				wget http://files.openvz-tc.org/debs/debootstrap.deb
				dpkg -i debootstrap.deb
				rm debootstrap.deb
				;;
		     *)
				dialog --msgbox "Host distri not supported yet. Sorry." 5 42
				exit 0
				;; esac

		dialog --no-cancel --menu "i386 or amd64?" 15 50 6  \
		i386 . \
		amd64 . 2>/tmp/input_arch.tmp
		input_arch=`cat /tmp/input_arch.tmp`

		debootstrap --variant=minbase --arch $input_arch $input_distri $input_path
                ;;

     gentoo)
		TMP_DIR="/tmp/$$"
		LOOP_ABORT="$TMP_DIR/loop_abort"
		rm -f ${LOOP_ABORT} >/dev/null 2>&1
		until [ -f ${LOOP_ABORT} ]; do
			mkdir ${TMP_DIR}
			cd ${TMP_DIR}

			dialog  --no-cancel --menu "How to obtain necessary files?" 0 0 0  \
				links "Open links and I will download the files" \
				lynx "Open lynx and I will download the files" \
				wget "Run wget and I will provide an URL" \
				manual "I will do this on my own just tell me where to put the files" 2>${TMP_DIR}/download_method.tmp
			download_method=`cat ${TMP_DIR}/download_method.tmp`

			MIRRORS="http://www.gentoo.org/main/en/mirrors2.xml"
			BROWSER_MSG="Please pick a mirror and download a stage3 Archive (tar.bz2 AND tar.bz2.DIGESTS). "
				BROWSER_MSG=${BROWSER_MSG}"You will find them in the \"/releases/<ARCH>/\" folder\n\n"
				BROWSER_MSG=${BROWSER_MSG}"Please be aware that you can only proceed installation with a stage3 ARCH that is "
				BROWSER_MSG=${BROWSER_MSG}"binary compatible with the current host machine. (Otherwise chroot will fail)\n\n"
				BROWSER_MSG=${BROWSER_MSG}"You will also need to download a recent Portage snapshot (tar.bz2 AND tar.bz2.md5sum). "
				BROWSER_MSG=${BROWSER_MSG}"You will find them in the \"/snapshots/\" folder."

			case $download_method in
				links)
					dialog --msgbox "$BROWSER_MSG" 0 0
					links ${MIRRORS}
					;;
				lynx)
					dialog --msgbox "$BROWSER_MSG" 0 0
					lynx ${MIRRORS}
					;;
				wget)
					dialog --msgbox "Will drop to shell to allow copy and paste of URLs" 0 0
					clear
					#dialog --inputbox "Please give an URL to a stage3 archive (tar.bz2)" 0 0 2>${TMP_DIR}/download_url.tmp
					echo "Please give an URL to a stage3 archive (tar.bz2)"
					read download_url
					#download_url=`cat ${TMP_DIR}/download_url.tmp`
					wget ${download_url}
					wget ${download_url}".DIGESTS"
					#dialog --inputbox "Please give an URL to a portage-snapshot (tar.bz2)" 0 0 2>${TMP_DIR}/download_url.tmp
					echo ""
					echo ""
					echo "Please give an URL to a portage-snapshot (tar.bz2)"
					read download_url
					#download_url=`cat ${TMP_DIR}/download_url.tmp`
					wget ${download_url}
					wget ${download_url}".md5sum"
					;;
				manual)
					dialog --msgbox "$BROWSER_MSG \n\nPut all these files into $TMP_DIR and confirm with <OK>" 0 0
					;;
				*)
					echo "Invalid download method" 1>&2
					exit 1;
					;; esac

			#Create one digests file with only relevant files
			grep ".tar.bz2$" stage3*.tar.bz2.DIGESTS > digests
			grep "*.tar.bz2$" portage*.tar.bz2.md5sum >> digests
			#Check the digests
			md5sum -c digests >/dev/null 2>&1
			if [ $? -ne 0 ]; then
				dialog --stdout --yesno "Error while downloading files. md5sums did not match. Proceed?" 0 0
				if [ $? -ne 0 ]; then
					cd ..
					rm -rf ${TMP_DIR} >/dev/null 2>&1
					clear
					echo "Download aborted"
					exit 0
				fi
			else
				touch ${TMP_DIR}/loop_abort
			fi
		done

		dialog --msgbox "All Checksums correct." 0 0
		dialog --infobox "Extracting Stage3." 0 0
		tar xjpf stage3*.tar.bz2 -C $input_path
		dialog --infobox "Extracting Portage tree." 5 28
		tar xjpf portage-latest.tar.bz2 -C $input_path/usr/

		dialog --msgbox  "Remove install archives." 5 28

		cd ..
		rm -rf ${TMP_DIR}
		#END gentoo
		;;
     *)
		echo "Input distribution \""${input_distri}"\" not found" 1>&2
                exit 1
                ;; esac

case "$input_nameserver" in
	locale)
		cp -L /etc/resolv.conf $input_path/etc/
		;;
	Google)
cat << EOF > $input_path/etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
		;;
	Nothing)
		rm -f $input_path/etc/resolv.conf >/dev/null 2>&1
		;; esac

wget -q http://files.openvz-tc.org/scripts/vpsmem -P $input_path/usr/local/bin
chmod +x $input_path/usr/local/bin/vpsmem

#if dev is mounted the mknod commands in the install scripts will create the devices on the host machine and not inside the template
#mount -o bind /dev $input_path/dev
mount -t proc none $input_path/proc # because another openssh-server will not configured to the end
#mount -t sysfs none $input_path/sys

dialog --yesno "System created. Do you want to chroot into it?" 0 0
if [ $? -eq 0 ]; then
	SCRIPT_DIR=`dirname $0`
	dialog --yesno "Mount $SCRIPT_DIR to \"/tmp/openvz-tc.org\" inside the chroot?" 0 0
	BIND_SCRIPTS=$?
	if [ $BIND_SCRIPTS -eq 0 ]; then
		mkdir -p "$input_path/tmp/openvz-tc.org"
		mount -o bind ${SCRIPT_DIR} "$input_path/tmp/openvz-tc.org"
	fi
	chroot $input_path
	if [ $BIND_SCRIPTS -eq 0 ]; then
		umount ${SCRIPT_DIR}
	fi
	umount $input_path/proc >/dev/null 2>&1
else
	exit 0
fi
