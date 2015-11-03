#!/bin/bash

# This script can be launch by user with accesses to /dev/sdX devices.
# users requires to be in "disk" group on Debian based system:
#  usermod -a -G disk [username]

export LANG=C

function umount_sdX_if_needed
{
	DEV=$1

	for part in $(cat /etc/mtab | grep "$DEV" | cut -d " " -f 1 -)
	do
		echo "Umount $part"
		umount $part
	done
}

# ##############################
# ##### Script entry point #####
# ##############################

#[ $UID -eq 0 ] && {
#	echo "Does not allowed to be launched as root."
#	echo "Configure '$USER' account to access /dev/sdX devices instead"
#	echo "Abording."
#	exit 1
#}

# Check tools dependency
(which mkfs.ext3 > /dev/null && which mkfs.vfat > /dev/null) || {
	echo "mkfs.vfat or mkfs.ext3 tool missing."
	echo "Abording."
	exit 1
}
MKFS_EXT3=$(which mkfs.ext3)
MKFS_VFAT=$(which mkfs.vfat)

# Check usage
[ ! $# -eq 3 ] && {
	echo "Usage: `basename $0` [board-name] [/dev/sdX] [build-dir]"
	echo "   will look for images in [build-dir]/tmp/deploy/images/[board-name]/"
	exit 1
}

# Catch args...
BOARD=$1
DEV=$2
BUILDDIR=$3

# ... and check them
[ ! -d $BUILDDIR ] && {
	echo "Invalid board name (dir $BUILDDIR) not found. Abording."
	exit 1
}

# Check images directory presence
IMGDIR="$BUILDDIR/tmp/deploy/images/$BOARD"
if [ ! -d $IMGDIR ]; then
	echo "Images files not found:"
	echo "   $IMGDIR directory not found."
	echo "Abording."
	exit 1
fi

# Check kernel file presence
KERNEL=$(ls -1 $IMGDIR/uImage)
[ -f $KERNEL ] || {
	echo "Unexpected error. \"uImage\" file not found."
	echo "  please check $IMGDIR content."
	exit 1
}

# Check device tree binary file presence
DTB=$(ls -1 $IMGDIR/uImage*.dtb | tail -1)
[ -f $DTB ] || {
	echo "Unexpected error. \"uImage*.dtb\" file pattern dont match."
	echo "  please check $IMGDIR content."
	exit 1
}

# Check rootfs file presence
ROOTFS=$(ls -1 $IMGDIR/*rootfs.tar.bz2 | tail -1)
[ -f $ROOTFS ] || {
	echo "Unexpected error. \"*rootfs.tar.bz2\" file pattern dont match."
	echo "  please check $IMGDIR content."
	exit 1
}

# Check modules file presence
MODULES=$(ls -1 $IMGDIR/modules*.tgz | tail -1)
[ -f $MODULES ] || {
	echo "Unexpected error. \"modules*.tgz\" file pattern dont match."
	echo "  please check $IMGDIR content."
	exit 1
}


echo "Ready to prepare SD-Card"
echo "---------------"
echo "Kernel file = $KERNEL"
echo "Device tree = $DTB"
echo "RootFS file = $ROOTFS"
echo "Module file = $MODULES"
echo
echo "Destination devices: $DEV"
echo
echo "Press a key to confirm informations above or Ctrl+C to abort..."
read
echo

# ##############################
# ### Real stuff starts here ###
# ##############################
umount_sdX_if_needed $DEV

# TODO: prepare partition table on /dev/sdX here.

# -----
MNTDIR=$(mktemp -d)
#MNTDIR=/tmp/tmp.omNt6AnNd1
mkdir -p $MNTDIR/part1
mkdir -p $MNTDIR/part2
echo "-- Temporary mount point directory $MNTDIR created"

# -----
echo "-- Format ${DEV}1 to VFAT"
$MKFS_VFAT ${DEV}1 || {
	echo "Please check '$USER' is allowed to access $DEV"
	echo "Abording"
	exit 1
}
echo "-- Format ${DEV}2 to EXT3"
$MKFS_EXT3 ${DEV}2

# -----
echo "-- Mount partitions for copy to SD"

mount ${DEV}1 $MNTDIR/part1 || {
	echo "Please check '$USER' is allowed to access $DEV"
	echo "Abording"
	exit 1
}
mount ${DEV}2 $MNTDIR/part2
cat /etc/mtab | grep "$DEV"

# -----
echo "-- Copy Kernel+dtb to SD part 1"
cp -v $KERNEL $DTB $MNTDIR/part1

# -----
echo "-- Untar rootfs+modules to SD part 2"
ROOTDIR=$PWD
cd $MNTDIR/part2
tar xpjf $ROOTDIR/$ROOTFS
tar xpzf $ROOTDIR/$MODULES
cd $ROOTDIR

# -----
echo "-- Sync and umount $DEV partitions"
sync
umount $MNTDIR/part1
umount $MNTDIR/part2

# -----
echo "-- Cleanup temporary stuff"
rm -Rf $MNTDIR

echo "-- Finished."

