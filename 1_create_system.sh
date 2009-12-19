#!/bin/bash
#
# Template OS Creator
#
echo "Where to create the system? (default /mnt/dice)"
read input_path

echo "Create and clear the path"
mkdir input_path
rm -rf $input_path/* 

# clear umount
umount $input_path/dev
umount $input_path/proc
umount $input_path//sys

echo "Download and installatioon the latest debootstrap"
wget http://files.yoschi.cc/debs/debootstrap.deb
dpkg -i debootstrap.deb && rm debootstrap.deb

clear
echo "What distri want you install?"
echo "Supported:"
echo "Ubuntu Hardy/Karmic"
read input_distri

echo "i386 or amd64?"
read input_arch

debootstrap --arch $input_arch $input_distri $input_path

wget http://files.yoschi.cc/vpsmem
chmod +x vpsmem
mv vpsmem /mnt/dice/usr/local/bin

#mount -o bind /dev /mnt/dice/dev
mount -t proc none $input_path/proc # because openssh-server will not configured to the end
#mount -t sysfs none /mnt/dice/sys

chroot $input_path
