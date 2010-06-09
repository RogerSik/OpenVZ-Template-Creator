#!/bin/bash
#
# OpenVZ Template OS Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
#

 dialog --no-cancel --inputbox "Where is the new system? (default /mnt/dice)" 8 50 2>/tmp/input_path.tmp
 input_path=`cat /tmp/input_path.tmp`

 dialog --no-cancel --menu  "Which distribution want you cleanup?" 10 40 3 \
	"Debian" "."  \
	"Ubuntu" "."  \
	"Gentoo" "." 2>/tmp/input_distri.tmp
	input_distri=`cat /tmp/input_distri.tmp`

 dialog --no-cancel --menu  "Which nameserver want you use for your template?" 10 55 3 \
	"locale" "Use the resolv.conf from the host."  \
	"Google" "Use the public DNS Server from Google."  \
	"Nothing" "Dont use a nameserver." 2>/tmp/input_nameserver.tmp
	input_nameserver=`cat /tmp/input_nameserver.tmp`

 dialog --no-cancel --inputbox \
	"Whats the name for that template? (without tar.gz!) \
	example ubuntu-8.04.3-i386" 8 60 2>/tmp/input_template_name.tmp
	input_template_name=`cat /tmp/input_template_name.tmp`

umount $input_path/dev
umount $input_path/proc
umount $input_path/sys

# General cleanup
rm -f $input_path/etc/ssh/ssh_host_*
rm -f $input_path/etc/ssh/moduli

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
		exit 0;
		;; esac

case "$input_distri" in
	debian|ubuntu)
		# Each individual VE should have its own pair of SSH host keys. 
		# The code below will wipe out the existing SSH keys and instruct the newly-created VE to create new SSH keys on first boot.
		#cat << C_EOF > ${input_path}/etc/rc2.d/S15ssh_gen_host_keys
		##!/bin/sh
		#ssh-keygen -f /etc/ssh/ssh_host_rsa_key -t rsa -N ''
		#ssh-keygen -f /etc/ssh/ssh_host_dsa_key -t dsa -N ''
		#rm /etc/rc2.d/S15ssh_gen_host_keys
		#C_EOF
		# looks like bash doesnt like cat << EOF > file input inside a case statement. putting the file line-by-line
		#cat << C_EOF > ${input_path}/etc/rc2.d/S15ssh_gen_host_keys
		echo "#!/bin/sh" > ${input_path}/etc/rc2.d/S15ssh_gen_host_keys
		echo "ssh-keygen -f /etc/ssh/ssh_host_rsa_key -t rsa -N ''" >> ${input_path}/etc/rc2.d/S15ssh_gen_host_keys
		echo "ssh-keygen -f /etc/ssh/ssh_host_dsa_key -t dsa -N ''" >> ${input_path}/etc/rc2.d/S15ssh_gen_host_keys
		echo "rm /etc/rc2.d/S15ssh_gen_host_keys" >> ${input_path}/etc/rc2.d/S15ssh_gen_host_keys
		chmod +x $input_path/etc/rc2.d/S15ssh_gen_host_keys

		cd $input_path/root/
		> .bash_history; > .viminfo
		cd $input_path/var/log
		> aptitude; > messages; > auth.log; > kern.log; > bootstrap.log
		> dpkg.log; > syslog; > daemon.log; > apt/term.log; > faillog; > lastlog; > wtmp 
		rm -f $input_path/var/log/*.0 $input_path/var/log/*.1
		;; #END debian|ubuntu
	gentoo)
		cd $input_path/var/log/
		> lastlog; > faillog; > wtmp
		> auth.log; > cron.log; > daemon.log; > debug; > dmesg; > mail.log; > messages; > syslog; > user.log
		> emerge-fetch.log; > emerge.log; > portage/elog/summary.log
		cd $input_path/usr/portage/distfiles/
		rm -ri *
		cd $input_path/root/
		> .bash_history
		rm -ri .ssh
		;; #END gentoo
	*)
		exit 0;
		;; esac

cd $input_path 
tar --numeric-owner -zcf ~/${input_template_name}.tar.gz .
dialog --msgbox "$input_template_name.tar.gz saved under ~/" 5 42

