#/bin/env bash
[ -z "$1" ] && echo 'pass in device (e.g. /dev/nvme0n1)...' && exit
[ -z "$2" ] && echo 'pass in root dir...' && exit
[ -z "$3" ] && echo 'pass in username...' && exit
[ `id -u` -ne 0 ] && echo 'run as root...' && exit
[ "$4" != "UNDERSTOOD" ] && echo "you may irreparably damage your system with this program..." && echo "" && echo "" && echo "add \"UNDERSTOOD\" to continue..." && exit
DEVICE=$1
ROOT=$2
YOU=$3
[ "${ROOT::1}" != "/" ] && ROOT="/mnt/$ROOT" || ROOT="/mnt$ROOT"
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

echo running cryptsetup
cryptsetup --verify-passphrase -v luksFormat "$DEVICE"p2
cryptsetup open "$DEVICE"p2 enc

echo formatting boot partition
mkfs.vfat -n boot "$DEVICE"p1

echo creating swap partition
mkswap "$DEVICE"p3
swapon "$DEVICE"p3

echo formatting root partition
mkfs.btrfs /dev/mapper/enc

croote () {
	btrfs subvolume create $1
}

create () {
	create $1
	chown $YOU $1
}

engage () {
	mkdir $1
	mount -o subvol=$1,compress=zstd,noatime /dev/mapper/enc $1
}

alias link='ln -s'

echo mounting btrfs to $ROOT
umount $ROOT
mount -t btrfs /dev/mapper/enc $ROOT || exit

cd $ROOT
create home/
mkdir  home/$YOU
cd home/$YOU

echo creating desktop
create desk
link   desk Desktop

echo creating documents
echo creating program documents
create cog
link   cog Documents
mkdir  cog/virt
echo creating my documents
create doc
link   Documents/keep

echo creating audio
create aux
mkdir  aux/music
link   aux/music Music

echo creating downloads
echo creating ephemeral downloads
create temp
link   temp down
link   temp Downloads
echo creating kept downloads
create keep
link   keep down/keep

echo creating etc
create config
link   config .config
create nixflake
create help
link   help Help
create pic
link   pic Pictures
create vid
link   vid Videos
create wall
link   wall Wallpapers

echo creating games
create games
link   games Games
cd games
create steam
create epic
link   epic ../Documents/Heroic
link   epic ../Documents/Legendary
create gog
create emu
mkdir  emu/dolphin
mkdir  emu/yuru
cd ..

echo creating etc
create presets
link   presets Templates
#reate /bin -> nix store

echo creating data
cd $ROOT
croote data
cd data
croote ssd
croote hdd
croote raid

echo creating root dirs
cd $ROOT
croote saves # snapshots
croote nix   # nix, duh
croote root
# manually do log
btrfs subvolume create log


echo creating readonly snapshot, rolled-back to upon every boot
btrfs subvolume snapshot -r root blank

echo unmounting
sudo umount $ROOT

echo remounting
mount -o subvol=root,compress=zstd,noatime /dev/mapper/enc $ROOT
engage home
engage desk
engage cog
engage doc
engage aux
engage temp
engage keep
engage config
engage help
engage nixflake
engage pic
engage vid
engage wall
engage games
engage epic
engage steam
engage emu
engage gog
engage presets
engage data
engage raid
engage hdd
engage ssd
#ngage root
engage nix   # nix, duh
engage saves # snapshots
mkdir -p $ROOT/var/log
mount -o subvol=log,compress=zstd,noatime /dev/mapper/enc $ROOT/var/log


echo mount boot
mkdir boot
mount "$DISK"p1 boot

echo generating nixos hardware config...
mkdir volumes
nixos-generate-config --root $ROOT
cp $ROOT/etc/nixos/hardware-configuration.nix volumes/
