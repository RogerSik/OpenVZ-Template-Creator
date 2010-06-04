#!/bin/bash
#
# OpenVZ Template OS Creator
# http://github.com/RogerSik/OpenVZ-Template-Creator
# gentoo part by: v1tzl1 (http://github.com/v1tzl1/OpenVZ-Template-Creator)

env-update && source /etc/profile
cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

rc-update add net.venet0 default
rc-update add sshd default

mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun
mknod /dev/fuse c 10 229

# Network
echo "hostname" > /etc/hostname
echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts

#############################################################################################
################################## /etc/fstab ###############################################
#############################################################################################
cat << EOF > /etc/fstab
proc  /proc       proc    defaults    0    0
none  /dev/pts    devpts  rw          0    0
EOF

#############################################################################################
################################## /etc/conf.d/clock ########################################
#############################################################################################
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
# For a list of valid sets, run `dumpkeys --help`

DUMPKEYS_CHARSET=""
EOF

# Thats all

umount /dev
umount /proc
