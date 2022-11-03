inputs: with inputs;
let
  remember = subvol: name:
  let path = "/mnt/saves/${name}";
  in ''
    if [ -d ${path}/3 ]; then
      echo "saves [ ${name} ]   -- 3"
      btrfs subvolume delete ${path}/3
    fi; if [ -d ${path}/2 ]; then
      echo "saves [ ${name} ] 2 -> 3"
      mv ${path}/2 ${path}/3
      btrfs subvolume delete ${path}/2
    fi; if [ -d ${path}/1 ]; then
      echo "saves [ ${name} ] 1 -> 2"
      mv ${path}/1 ${path}/2
      btrfs subvolume delete ${path}/1
    fi

    echo "saves [ ${name} ] 0 -> 1"
    btrfs subvolume snapshot /mnt/${subvol} ${path}/1

    echo "saves [ ${name} ]   -- 0"
    btrfs subvolume delete /mnt/${name}

    echo "saves [ ${name} ] - -> 0"
    btrfs subvolume snapshot /mnt/blank/${name} /mnt/${subvol}
  '';
in {
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

    ${remember "root" "root"}
    ${remember ("/home/"+user+"/temp") "temp"}

    # After rollback, unmount and continue to boot.
    umount /mnt
  '';
}
