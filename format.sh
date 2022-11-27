#/bin/env bash

ALL="$@"
START=`pwd`

# functions {
function croote {
	for x in ${@}; do
		btrfs subvolume create $x
		sleep 0.1
	done
}
function create {
	croote ${@}
	for x in ${@}; do
		chown $YOU $x
	done
}
function engage {
	for x in ${@}; do
		mkdir -p $x
		mount -o subvol=$PREFIX$x,compress=zstd,noatime $DEVICE $x && echo mounted $x
		umount $x
		sleep 0.1
		mount -o subvol=$PREFIX$x,compress=zstd,noatime $DEVICE $x && echo mounted $x
		sleep 0.1
	done
}
function engage_ {
	mkdir -p $2
	mount -o subvol=$1,compress=zstd,noatime $DEVICE $2 && echo mounted $1
	sleep 0.1
}
function link {
	ln -s $1 $2
}
function unmount {
	pushd /
	echo unmounting
	umount -RA "$OLD"1
	umount -RA "$DEVICE"1
	umount -RA /dev/mapper/enc
	popd
}
function close {
	unmount
	cryptsetup close /dev/mapper/enc
}
#}

# handle arguments and launch {
echo ensuring toolchain access
if [ -z "$out" ]; then
	exec nix-shell -p cryptsetup nixos-install-tools btrfs-progs gparted --command "exec bash $0 $ALL"
else
	# argument checks & safety measures {
	[ -z "$1" ] && echo 'pass in device prefix (e.g. /dev/nvme0n1p or /dev/sda)...' && exit
	[ -z "$2" ] && echo 'pass in mount point...' && exit
	[ -z "$3" ] && echo 'pass in username...' && exit
	[ "$4" != "UNDERSTOOD" ] && echo "you may irreparably damage your system with this program..." && echo "" && echo "" && echo "add \"UNDERSTOOD\" to continue..." && exit
	[ `id -u` -ne 0 ] && echo 'run as root...' && exit
	
	DEVICE=$1
	ROOT=$2
	YOU=$3
	[ "${ROOT::1}" != "/" ] || ROOT="/mnt"
	
	#}
	close
	echo make your partitions...
	gparted || exit
fi
#}
# safety measures {
echo ""
echo "! STOP ! Ensure that you have 3 partitions on $DEVICE:"
echo " - EFI  (FAT32 ~ 300MB)"
echo " - ROOT (unformatted ~ REMAINING-RAM)"
echo " - SWAP (swp ~ RAM)"
echo ""
read -p "press enter..."
echo ""
lsblk --fs
echo ""
read -p "if this looks right, press enter..."
echo ""
echo running on $DEVICE under $ROOT for $YOU and I hold no liability...
echo ""
read -p "press enter to continue..."

#}
# encryption {
echo running cryptsetup
cryptsetup --verify-passphrase -v luksFormat "$DEVICE"2
cryptsetup config "$DEVICE"2 --label ROOT
cryptsetup open "$DEVICE"2 enc
#}
# formatting {
echo formatting boot partition
mkfs.vfat -n BOOT "$DEVICE"1

echo creating swap partition
mkswap "$DEVICE"3
swapon "$DEVICE"3
e2label "$DEVICE"3 SWAP

# new $DEVICE usage...
OLD=$DEVICE
DEVICE=/dev/mapper/enc

echo formatting root partition
mkfs.btrfs -f $DEVICE

#}
# body {
mkdir -p $ROOT

echo mounting btrfs to $ROOT
mount -t btrfs $DEVICE $ROOT

cd $ROOT

# subvolume creation {
echo creating core subvolumes
croote saves persist nix
croote root log

pushd persist
croote lxd
popd # persist

croote data
pushd data
croote ssd hdd raid
popd # data

echo "----------"
create home
mkdir -p home/$YOU
pushd    home/$YOU

create config
create nixflake

create desk

echo creating program documents
create cog
echo creating my documents
create doc

echo creating audio
create aux

echo creating ephemeral downloads
create temp
echo creating kept downloads
create keep

echo creating misc
create pic vid
create wall presets
create help

echo creating games
create games
pushd games
create steam epic gog emu
popd # games


popd # home


mkdir -p saves/temp
mkdir -p saves/root
mkdir -p root/boot/efi
btrfs subvolume snapshot -r home/$YOU/temp saves/temp/blank # downloads
btrfs subvolume snapshot -r root           saves/root/blank # /

#}
# mounting process {
#unmount
echo remounting
ROOT=$ROOT/root
cd $ROOT

# already "mounted", but give nix-generate-config a nudge...
mount -o subvol=root,compress=zstd,noatime $DEVICE $ROOT
mount "$OLD"1 boot/efi

PREFIX=""

engage_ log $ROOT/var/log
engage saves nix persist # core
engage home data

#}
# linking process {
echo linking
pushd  $ROOT/home/$YOU
link   presets Templates
link   config .config
link   help Help

link   desk Desktop
link   cog Documents
mkdir  cog/virt
link   doc Documents/keep
mkdir  aux/music
link   aux/music Music
link   temp net
link   temp Downloads
link   keep net/keep
link   pic Pictures
link   vid Videos
link   wall Wallpapers
link   games Games
pushd games
link   epic ../Documents/Heroic
link   epic ../Documents/Legendary
mkdir  emu/dolphin
mkdir  emu/yuru
popd # games
popd # home

#}
# hardware {
echo generating nixos hardware config...
pushd $ROOT/home/$YOU/nixflake
mkdir volumes
nixos-generate-config --root $ROOT
rm volumes/default.nix
cp -f $ROOT/etc/nixos/hardware-configuration.nix volumes/default.nix
echo $ROOT/etc/nixos/hardware-configuration.nix -\> volumes/default.nix
popd # nixflake
#}
# copy config {
echo copy current config
cp -r  $START home/$YOU/
chown -R $YOU home/$YOU
#}
# passwords {
mkdir persist/passwords
pushd persist/passwords
echo "enter $YOU & root's password (visible!):"
nix-shell --run 'mkpasswd -m SHA-512 -s' -p mkpasswd > temp
cp temp root
mv temp $YOU
popd # passwords }
# closing remarks {
read -p "disconnect? [y/N] " DIS
if [ "$DIS" == "y" ]; then close; fi

echo ""
echo ""
echo ""
echo ""
echo "remember to modify $ROOT/home/v0id/nixflake/volumes/default.nix"
echo ""
echo ""
echo ""
echo ""
#}

#}
