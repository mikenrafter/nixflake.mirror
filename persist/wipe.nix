inputs: with inputs;
{
 # Note `lib.mkBefore` is used instead of `lib.mkAfter` here.
  boot.initrd.postDeviceCommands = lib.mkBefore ''
    mkdir -p /mnt

    # We first mount the btrfs root to /mnt
    # so we can manipulate btrfs subvolumes.
    mount -o subvol=/ /dev/mapper/enc /mnt

    # While we're tempted to just delete /root and create
    # a new snapshot from /root-blank, /root is already
    # populated at this point with a number of subvolumes,
    # which makes `btrfs subvolume delete` fail.
    # So, we remove them first.
    #
    # /root contains subvolumes:
    # - /root/var/lib/portables
    # - /root/var/lib/machines
    #
    # I suspect these are related to systemd-nspawn, but
    # since I don't use it I'm not 100% sure.
    # Anyhow, deleting these subvolumes hasn't resulted
    # in any issues so far, except for fairly
    # benign-looking errors from systemd-tmpfiles.

    btrfs subvolume list -o /mnt/root |
    cut -f9 -d' ' |
    while read subvolume; do
      echo "deleting /$subvolume subvolume..."
      btrfs subvolume delete "/mnt/$subvolume"
    done

    if [ -d /mnt/saves/3 ]; then
      btrfs subvolume delete /mnt/saves/3
      echo "overwriting root snapshot 3"
      btrfs subvolume snapshot /mnt/saves/2 /mnt/saves/3
    fi; if [ -d /mnt/saves/2 ]; then
      btrfs subvolume delete /mnt/saves/2
      echo "overwriting root snapshot 2"
      btrfs subvolume snapshot /mnt/saves/1 /mnt/saves/2
    fi; if [ -d /mnt/saves/1 ]; then
      btrfs subvolume delete /mnt/saves/1
    fi

    echo "overwriting root snapshot 1"
    btrfs subvolume snapshot /mnt/root /mnt/saves/1

    echo "deleting old root subvolume"
    btrfs subvolume delete /mnt/root

    echo "restoring blank /root subvolume..."
    btrfs subvolume snapshot /mnt/blank /mnt/root

    # Once we're done rolling back to a blank snapshot,
    # we can unmount /mnt and continue on the boot process.
    umount /mnt
  '';
}
