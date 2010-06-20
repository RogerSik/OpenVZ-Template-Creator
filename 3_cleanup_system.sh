#!/bin/bash
#
# OpenVZ Template OS Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
#
if [ -f /tmp/input_path.tmp ]; then
	input_path_default=`cat /tmp/input_path.tmp`
else
	input_path_default="/mnt/dice/"
fi
dialog --no-cancel --inputbox "Where is the new system? (default /mnt/dice)" 8 50 "$input_path_default" 2>/tmp/input_path.tmp
	input_path=`cat /tmp/input_path.tmp`

dialog --no-cancel --menu  "Which distribution want you cleanup?" 10 40 3 \
	"Debian" "."  \
	"Ubuntu" "."  \
	"Gentoo" "." 2>/tmp/input_distri.tmp
	input_distri=`cat /tmp/input_distri.tmp`

dialog --no-cancel --inputbox \
	"Whats the name for that template? (without tar.gz!) \
	example ubuntu-8.04.3-i386" 8 60 2>/tmp/input_template_name.tmp
	input_template_name=`cat /tmp/input_template_name.tmp`

umount $input_path/dev >/dev/null 2>&1
umount $input_path/proc >/dev/null 2>&1
umount $input_path/sys >/dev/null 2>&1
umount $input_path/tmp/openvz-tc.org >/dev/null 2>&1

# General cleanup
rm -f $input_path/etc/ssh/ssh_host_*
rm -f $input_path/etc/ssh/moduli

case "$input_distri" in
	debian|ubuntu)
		# Each individual VE should have its own pair of SSH host keys.
		# The code below will wipe out the existing SSH keys and instruct the newly-created VE to create new SSH keys on first boot.
cat << EOF > ${input_path}/etc/rc2.d/S15ssh_gen_host_keys
#!/bin/sh
ssh-keygen -f /etc/ssh/ssh_host_rsa_key -t rsa -N ''
ssh-keygen -f /etc/ssh/ssh_host_dsa_key -t dsa -N ''
rm /etc/rc2.d/S15ssh_gen_host_keys
EOF
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
		dialog --yesno "Wipe out $input_path/usr/portage/distfiles/* ?" 0 0
		if [ $? -eq 0 ]; then
			rm -rf "$input_path/usr/portage/distfiles/*"
		fi
		cd $input_path/root/
		> .bash_history
		dialog --yesno "Wipe out $input_path/root/.ssh/* ?" 0 0
		if [ $? -eq 0 ]; then
			rm -rf "$input_path/root/.ssh/*"
		fi
		;; esac #END gentoo

cd $input_path
tar --numeric-owner -zcf ~/${input_template_name}.tar.gz . 2>/dev/null
dialog --no-cancel --msgbox "$input_template_name.tar.gz \ saved under ~/" 5 42
