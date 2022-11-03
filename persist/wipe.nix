inputs: with inputs;
{
 # Note `lib.mkBefore` is used instead of `lib.mkAfter` here.
  boot.initrd.postDeviceCommands = lib.mkBefore ''
    mkdir -p /mnt

    # / -> /mnt for manipulating btrfs subvolumes.
    mount -o subvol=/ /dev/mapper/enc /mnt

    # /root's subvolumes:
    #  -   /var/lib/machines
    #  -   /srv
    #
    # Removing these is necessary for `btrfs delete` to work.
    #
    # Probably related to systemd-nspawn, but unsure, no issues in deletion
    # so far, except for benign-looking errors from systemd-tmpfiles.

    btrfs subvolume list -o /mnt/root |
    cut -f9 -d' ' |
    while read subvolume; do
      echo "deleting /$subvolume subvolume..."
      btrfs subvolume delete "/mnt/$subvolume"
    done

    if [ -d /mnt/saves/3 ]; then
      echo "saves   -- 3"
      btrfs subvolume delete /mnt/saves/3
    fi; if [ -d /mnt/saves/2 ]; then
      echo "saves 2 -> 3"
      mv /mnt/saves/2 /mnt/saves/3
      btrfs subvolume delete /mnt/saves/2
    fi; if [ -d /mnt/saves/1 ]; then
      echo "saves 1 -> 2"
      mv /mnt/saves/1 /mnt/saves/2
      btrfs subvolume delete /mnt/saves/1
    fi

    echo "saves 0 -> 1"
    btrfs subvolume snapshot /mnt/root /mnt/saves/1

    echo "saves   -- 0"
    btrfs subvolume delete /mnt/root

    echo "saves - -> 0"
    btrfs subvolume snapshot /mnt/blank /mnt/root

    # After rollback, unmount and continue to boot.
    umount /mnt
  '';
}
