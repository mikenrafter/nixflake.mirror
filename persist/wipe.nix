inputs: with inputs; with builtins;
# TODO: add counter-based system to alternate wipes
# e.g. volatile, yet cluttered locations such as $HOME
let
  # for keeping files
  keep     = subvol: name: path: "cp -rfp /mnt/saves/${name}/1/${path} /mnt/${subvol}/${path} && echo kept ${path}";
  keeps    = subvol: name: paths: concatStringsSep "\n" (map (keep subvol name) paths);
  remember = subvol: name: to-keep:
  let path = "/mnt/saves/${name}";
  in ''
    echo "remember ${subvol} ${name} (${path})"
    echo "saves [ ${name} ]  {"
    if     [ -d ${path}/3 ]; then
      btrfs subvolume delete ${path}/3
    fi; if [ -d ${path}/2 ]; then
      mv ${path}/2 ${path}/3
      btrfs subvolume delete ${path}/2
    fi; if [ -d ${path}/1 ]; then
      mv ${path}/1 ${path}/2
      btrfs subvolume delete ${path}/1
    fi

    echo "snapshot"
    btrfs subvolume snapshot /mnt/${subvol} ${path}/1


    btrfs subvolume list -o /mnt/${subvol} |
    cut -f9 -d' ' |
    while read subvolume; do
      echo "deleting /$subvolume subvolume..."
      btrfs subvolume delete "/mnt/$subvolume"
    done


    echo "delete"
    btrfs subvolume delete /mnt/${subvol}

    echo "restore"
    btrfs subvolume snapshot /mnt/saves/${name}/blank /mnt/${subvol}

    echo "copy 'keeps'"
    ${keeps subvol name to-keep}

    echo "saves [ ${name} ]  }"
  '';
in {
 # Note `lib.mkBefore` is used instead of `lib.mkAfter` here.
  boot.initrd.postDeviceCommands = lib.mkBefore ''
    mkdir -p /mnt

    # / -> /mnt for manipulating btrfs subvolumes.
    mount -o subvol=/ /dev/mapper/main /mnt

    # /root's subvolumes:
    #  -   /var/lib/machines
    #  -   /srv
    #
    # Removing these is necessary for `btrfs delete` to work.
    #
    # Probably related to systemd-nspawn, but unsure, no issues in deletion
    # so far, except for benign-looking errors from systemd-tmpfiles.

    ${remember "root" "root" [ "etc/shadow" ]}
    ${remember ("home/"+user+"/temp") "temp" []}

    # After rollback, unmount and continue to boot.
    umount /mnt
  '';
}
