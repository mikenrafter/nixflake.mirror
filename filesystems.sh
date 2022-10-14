#/bin/env bash
# argument checks & safety measures {
[ -z "$1" ] && echo 'pass in device (e.g. /dev/nvme0n1)...' && exit
[ -z "$2" ] && echo 'pass in root dir...' && exit
[ -z "$3" ] && echo 'pass in username...' && exit
[ `id -u` -ne 0 ] && echo 'run as root...' && exit
[ "$4" != "UNDERSTOOD" ] && echo "you may irreparably damage your system with this program..." && echo "" && echo "" && echo "add \"UNDERSTOOD\" to continue..." && exit

START=`pwd`
DEVICE=$1
ROOT=$2
YOU=$3
[ "${ROOT::1}" != "/" ] && ROOT="/mnt/$ROOT" || ROOT="/mnt"

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
echo ensuring $ROOT and $DEVICE are disconnected
umount -RA $ROOT
cryptsetup close /dev/mapper/enc


echo running cryptsetup
cryptsetup --verify-passphrase -v luksFormat "$DEVICE"p2
cryptsetup open "$DEVICE"p2 enc
#}
# formatting {
echo formatting boot partition
mkfs.vfat -n boot "$DEVICE"p1

echo creating swap partition
mkswap "$DEVICE"p3
swapon "$DEVICE"p3

# new $DEVICE usage...
OLD=$DEVICE
DEVICE=/dev/mapper/enc

echo formatting root partition
mkfs.btrfs $DEVICE

#}
# functions {
function croote {
	btrfs subvolume create $1 && echo created $1
}
function create {
	croote $1
	chown $YOU $1
}
function engage {
	mkdir $1 2>/dev/null
	mount -o subvol=$1,compress=zstd,noatime $DEVICE $1 2>/dev/null
}
function link {
	ln -s $1 $2
}

#}

echo mounting btrfs to $ROOT
cd $START
umount $ROOT
mount -t btrfs $DEVICE $ROOT

echo ""

# subvolume creation {
echo creating root dirs
cd $ROOT
croote saves # snapshots
croote nix   # nix, duh
croote root
# manually do log
croote log
croote persist

echo creating home
create home/
echo created first subvolume successfully
mkdir  home/$YOU
cd     home/$YOU

echo creating desktop
create desk

echo creating documents
echo creating program documents
create cog
echo creating my documents
create doc

echo creating audio
create aux

echo creating downloads
echo creating ephemeral downloads
create temp
echo creating kept downloads
create keep

echo creating pictures
create pic
create vid
create wall

echo creating games
create games
cd games
create steam
create epic
create gog
create emu
cd $ROOT/home/$YOU

echo creating etc
create presets
create config
create nixflake
create help

echo creating data
cd $ROOT
croote data
croote data/ssd
croote data/hdd
croote data/raid


echo creating readonly snapshot, rolled-back to upon every boot
btrfs subvolume snapshot -r root blank

#}

echo unmounting
cd $START
umount -RA $ROOT

# mounting process {
echo remounting
mount -o subvol=root,compress=zstd,noatime $DEVICE $ROOT

engage saves # snapshots
engage nix   # nix, duh

mkdir -p $ROOT/var/log
mount -o subvol=log,compress=zstd,noatime $DEVICE $ROOT/var/log

engage persist

engage home/
cd     home/$YOU

engage desk

engage cog
engage doc

engage aux

engage temp
engage keep

engage pic
engage vid
engage wall

engage games
cd games
engage steam
engage epic
engage gog
engage emu
cd $ROOT/home/$YOU

engage presets
engage config
engage nixflake
engage help

engage data
cd $ROOT/data
engage ssd
engage hdd
engage raid


echo mounting boot
cd $ROOT
# /boot/efi is standard, /boot - less so
mkdir -p boot/efi
mount "$OLD"p1 boot/efi

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

echo generating nixos hardware config...
cd $ROOT/home/$YOU/nixflake
mkdir volumes
nixos-generate-config --root $ROOT &&
cp $ROOT/etc/nixos/hardware-configuration.nix volumes/ &&
echo $ROOT/etc/nixos/hardware-configuration.nix -\> volumes/ &&
rm $ROOT/etc/nixos/hardware-configuration.nix || echo HARDWARE CONFIG FAILED!

sleep 5

echo unmounting \& disconnecting
cd $START
umount -RA $ROOT
cryptsetup close $DEVICE
