#!/bin/bash
#
# OpenVZ Template OS Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
#

echo "Where is the new system? (default /mnt/dice)"
read input_path

umount $input_path/dev
umount $input_path/proc
umount $input_path/sys

# General cleanup
rm -f $input_path/etc/ssh/ssh_host_*
rm -f $input_path/etc/ssh/moduli

echo "Which distribution are you installing again?"
echo "supported: debian ubuntu gentoo"
read input_distri

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
		echo "Sorry" $input_distri "is not supported"
		exit 0;
		;; esac

echo "Whats the name for that template? (without tar.gz!)"
echo "example ubuntu-8.04.3-i386"
read input_template_name
cd $input_path 
tar --numeric-owner -zcf ~/${input_template_name}.tar.gz .
echo $input_template_name".tar.gz saved under ~/"

