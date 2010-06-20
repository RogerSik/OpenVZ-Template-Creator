#!/bin/bash
#
# OpenVZ Template OS Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
# gentoo part by: v1tzl1 (http://github.com/v1tzl1/OpenVZ-Template-Creator)

env-update && source /etc/profile

mkdir -p /root/template-doc/
ln -s /proc/mounts /etc/mtab

ln -s /etc/init.d/net.lo /etc/init.d/net.venet0
rc-update add net.venet0 default
rc-update add sshd default
echo "- Added net.venet0 and sshd to default runlevel" > /root/template-doc/change.log

unmount /dev >/dev/null 2>&1 #ensure that we create the nodes inside the template filesystem and not somwere else (eg. on the host filesystem)
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun
mknod /dev/fuse c 10 229
echo "- Created TUN and FUSE devices" >> /root/template-doc/change.log


# Network
echo "hostname" > /etc/hostname
echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts
echo "" > /etc/fstab

#############################################################################################
################################## /etc/conf.d/clock ########################################
#############################################################################################
echo "- Selected Europe/Berlin as localtime (/etc/localtime and /etc/conf.d/clock)" >> /root/template-doc/change.log
cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

cat << EOF > /etc/conf.d/clock
# /etc/conf.d/clock

# Set CLOCK to "UTC" if your hardware clock is set to UTC (also known as
# Greenwich Mean Time).  If that clock is set to the local time, then
# set CLOCK to "local".
# Note that if you dual boot with Windows, then you should set it to
# "local" because Windows always sets the hardware clock to local time.

CLOCK="UTC"

# Select the proper timezone.  For valid values, peek inside of the
# /usr/share/zoneinfo/ directory.  For example, some common values are
# "America/New_York" or "EST5EDT" or "Europe/Berlin".  If you want to
# manage /etc/localtime yourself, set this to "".

TIMEZONE="Europe/Berlin"

# If you wish to pass any other arguments to hwclock during bootup,
# you may do so here.

CLOCK_OPTS=""

# If you want to set the Hardware Clock to the current System Time (software
# clock) during shutdown, then say "yes" here.

CLOCK_SYSTOHC="no"


### ALPHA SPECIFIC OPTIONS ###

# If your alpha uses the SRM console, set this to "yes".
SRM="no"

# If your alpha uses the ARC console, set this to "yes".
ARC="no"
EOF

#############################################################################################
################################## /etc/rc.conf #############################################
#############################################################################################
echo "- Enabling unicode support in /etc/rc.conf" >> /root/template-doc/change.log

cat << EOF > /etc/rc.conf
# /etc/rc.conf: Global startup script configuration settings

# UNICODE specifies whether you want to have UNICODE support in the console.
# If you set to yes, please make sure to set a UNICODE aware CONSOLEFONT and
# KEYMAP in the /etc/conf.d/consolefont and /etc/conf.d/keymaps config files.

UNICODE="yes"

# Set EDITOR to your preferred editor.
# You may use something other than what is listed here.

EDITOR="/bin/nano"
#EDITOR="/usr/bin/vim"
#EDITOR="/usr/bin/emacs"
EOF

#############################################################################################
################################## /etc/conf.d/keymaps ######################################
#############################################################################################
echo "- Selected de-latin1-nodeadkeys as default keymap in /etc/conf.d/keymaps" >> /root/template-doc/change.log

cat << EOF > /etc/conf.d/keymaps
# /etc/conf.d/keymaps

# Use KEYMAP to specify the default console keymap.  There is a complete tree
# of keymaps in /usr/share/keymaps to choose from.

KEYMAP="de-latin1-nodeadkeys"


# Should we first load the 'windowkeys' console keymap?  Most x86 users will
# say "yes" here.  Note that non-x86 users should leave it as "no".

SET_WINDOWKEYS="no"


# The maps to load for extended keyboards.  Most users will leave this as is.

EXTENDED_KEYMAPS=""
#EXTENDED_KEYMAPS="backspace keypad euro"


# Tell dumpkeys(1) to interpret character action codes to be
# from the specified character set.
# This only matters if you set UNICODE="yes" in /etc/rc.conf.
# For a list of valid sets, run 'dumpkeys --help'

DUMPKEYS_CHARSET=""
EOF

#############################################################################################
################################## Locales ##################################################
#############################################################################################
echo "- Enabled and generated the following locales: en_US ISO-8859-1, en_US.UTF-8 UTF-8, de_DE ISO-8859-1, de_DE.UTF-8 UTF-8 and de_DE@euro ISO-8859-15 (etc/locale.gen)" >> /root/template-doc/change.log

cat << EOF > /etc/locale.gen
# /etc/locale.gen: list all of the locales you want to have on your system
#
# The format of each line:
# <locale> <charmap>
#
# Where <locale> is a locale located in /usr/share/i18n/locales/ and
# where <charmap> is a charmap located in /usr/share/i18n/charmaps/.
#
# All blank lines and lines starting with # are ignored.
#
# For the default list of supported combinations, see the file:
# /usr/share/i18n/SUPPORTED
#
# Whenever glibc is emerged, the locales listed here will be automatically
# rebuilt for you.  After updating this file, you can simply run 'locale-gen'
# yourself instead of re-emerging glibc.

#en_US ISO-8859-1
#en_US.UTF-8 UTF-8
#ja_JP.EUC-JP EUC-JP
#ja_JP.UTF-8 UTF-8
#ja_JP EUC-JP
#en_HK ISO-8859-1
#en_PH ISO-8859-1
#de_DE ISO-8859-1
#de_DE.UTF-8 UTF-8
#de_DE@euro ISO-8859-15
#es_MX ISO-8859-1
#fa_IR UTF-8
#fr_FR ISO-8859-1
#fr_FR@euro ISO-8859-15
#it_IT ISO-8859-1

en_US ISO-8859-1
en_US.UTF-8 UTF-8
de_DE ISO-8859-1
de_DE.UTF-8 UTF-8
de_DE@euro ISO-8859-15
EOF

locale-gen

#############################################################################################
################################## Portage auf Vordermann bringen ###########################
#############################################################################################

#Returnwert von nicht null erzeugen
ls /tmp/$$/$$ >/dev/null 2>&1

until [ $? -eq 0]; do
	clear
	eselect profile list
	echo ""
	echo ""
	echo "Please choose profile number"
	read input_profile
	eselect profile set ${input_profile}
done

emerge --sync
emerge -u portage
emerge -u gentoolkit

dialog --yesno "Emerge sys-apps/iproute2 (Recommended for IPv6)?" 0 0
if [ $? -eq 0 ]; then
	emerge -u sys-apps/iproute2
fi
