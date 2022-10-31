#/bin/env bash

ALL="$@"
START=`pwd`

echo ensuring toolchain access
if [ -z "$out" ]; then
	exec nix-shell -p cryptsetup nixos-install-tools btrfs-progs gparted --command "exec bash $0 $ALL"
else
	# argument checks & safety measures {
	[ -z "$1" ] && echo 'pass in device (e.g. /dev/nvme0n1)...' && exit
	[ -z "$2" ] && echo 'pass in root dir...' && exit
	[ -z "$3" ] && echo 'pass in username...' && exit
	[ `id -u` -ne 0 ] && echo 'run as root...' && exit
	[ "$4" != "UNDERSTOOD" ] && echo "you may irreparably damage your system with this program..." && echo "" && echo "" && echo "add \"UNDERSTOOD\" to continue..." && exit
	
	DEVICE=$1
	ROOT=$2
	YOU=$3
	[ "${ROOT::1}" != "/" ] && ROOT="/mnt/$ROOT" || ROOT="/mnt"
	
	#}
	echo make your partitions...
	echo unmounting \& disconnecting
	cd $START
	umount -RA "$DEVICE"p1
	umount -RA /dev/mapper/enc
	cryptsetup close /dev/mapper/enc
	gparted || exit
fi
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
echo ensuring $ROOT and $DEVICE are disconnected
umount -RA $DEVICE
cryptsetup close /dev/mapper/enc


echo running cryptsetup
cryptsetup --verify-passphrase -v luksFormat "$DEVICE"p2
cryptsetup config "$DEVICE"p2 --label ROOT
cryptsetup open "$DEVICE"p2 enc
#}
# formatting {
echo formatting boot partition
mkfs.vfat -n BOOT "$DEVICE"p1

echo creating swap partition
mkswap "$DEVICE"p3
swapon "$DEVICE"p3
e2label "$DEVICE"p3 SWAP

# new $DEVICE usage...
OLD=$DEVICE
DEVICE=/dev/mapper/enc

echo formatting root partition
mkfs.btrfs -f $DEVICE

#}
# functions {
function croote {
	btrfs subvolume create $1
}
function create {
	croote $1
	chown $YOU $1
}
function engage {
	for x in ${@}; do
		mkdir -p $x
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

#}

echo mounting btrfs to $ROOT
cd $START
umount -RA "$OLD"p1
umount -RA $DEVICE
mount -t btrfs $DEVICE $ROOT
cd $ROOT
mkdir boot/efi
mount "$OLD"p1 boot/efi

echo ""

# subvolume creation {
cd $ROOT
croote saves # snapshots
croote nix   # nix, duh
croote root
# manually do log
croote log
croote persist

create home
echo created first subvolume successfully
mkdir -p home/$YOU
cd       home/$YOU

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

create pic
create vid
create wall

create games
cd games
create steam
create epic
create gog
create emu
cd $ROOT/home/$YOU

create presets
create config
create nixflake
create help

cd $ROOT
croote data
croote data/ssd
croote data/hdd
croote data/raid


btrfs subvolume snapshot -r root blank

#}

echo unmounting
cd $START
umount -RA "$OLD"p1
umount -RA $DEVICE

# mounting process {
echo remounting

cd $ROOT

mount -o subvol=root,compress=zstd,noatime $DEVICE $ROOT

mkdir -p boot/efi
mount "$OLD"p1 boot/efi

PREFIX=""

engage saves # snapshots
engage nix   # nix, duh

engage_ log $ROOT/var/log

engage persist

engage home
cd home/$YOU

PREFIX=home/$YOU/
engage desk cog doc aux temp keep pic vid wall

engage games
cd games
PREFIX=home/$YOU/games/
engage steam epic gog emu
cd ..


PREFIX=home/$YOU/
engage presets config nixflake help

cd $ROOT
engage data
cd data
PREFIX=data/
engage ssd hdd raid

PREFIX=""

# remount for some reason???
cd $ROOT
mkdir  saves nix persist home
engage saves nix persist home

#}
# linking process {
echo linking
cd     $ROOT/home/$YOU
link   desk Desktop
link   cog Documents
mkdir  cog/virt
link   doc Documents/keep
mkdir  aux/music
link   aux/music Music
link   temp down
link   temp Downloads
link   keep down/keep
link   pic Pictures
link   vid Videos
link   wall Wallpapers
link   games Games
cd games
link   epic ../Documents/Heroic
link   epic ../Documents/Legendary
mkdir  emu/dolphin
mkdir  emu/yuru
cd $ROOT/home/$YOU
link   presets Templates
link   config .config
link   help Help
cd $ROOT

#}
# hardware {
echo generating nixos hardware config...
cd $ROOT/home/$YOU/nixflake
mkdir volumes
nixos-generate-config --root $ROOT &&
cp -f $ROOT/etc/nixos/hardware-configuration.nix volumes/default.nix &&
echo $ROOT/etc/nixos/hardware-configuration.nix -\> volumes/default.nix &&
rm $ROOT/etc/nixos/hardware-configuration.nix || echo HARDWARE CONFIG FAILED!

#}

echo copy current config
cd $START
cp -ri $START  $ROOT/home/$YOU/
cd ..

chown $YOU $ROOT/home/$YOU/**
chown $YOU $ROOT/home/$YOU/.**
chown $YOU $ROOT/home/$YOU

sleep 5

read -p "disconnect? [y/N] " DIS
if [ "$DIS" == "y" ]; then
	echo unmounting \& disconnecting
	cd $START
	umount -RA "$OLD"p1
	umount -RA $DEVICE
	cryptsetup close $DEVICE
fi

echo ""
echo ""
echo ""
echo ""
echo "remember to modify $root/home/v0id/nixflake/volumes/default.nix"
echo ""
echo ""
echo ""
echo ""

