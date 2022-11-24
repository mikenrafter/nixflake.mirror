{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/5F01-0D91";
      fsType = "vfat";
    };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/persist/lxd" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=lxd" ];
    };

  boot.initrd.luks.devices."enc".device = "/dev/disk/by-uuid/cd08e823-f71f-4a26-9eb5-501c29f854f3";

  fileSystems."/saves" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=saves" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=log" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=persist" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/home/v0id/desk" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/desk" ];
    };

  fileSystems."/home/v0id/cog" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/cog" ];
    };

  fileSystems."/home/v0id/doc" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/doc" ];
    };

  fileSystems."/home/v0id/aux" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/aux" ];
    };

  fileSystems."/home/v0id/temp" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/temp" ];
    };

  fileSystems."/home/v0id/keep" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/keep" ];
    };

  fileSystems."/home/v0id/pic" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/pic" ];
    };

  fileSystems."/home/v0id/vid" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/vid" ];
    };

  fileSystems."/home/v0id/wall" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/wall" ];
    };

  fileSystems."/home/v0id/games" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/games" ];
    };

  fileSystems."/home/v0id/games/steam" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/games/steam" ];
    };

  fileSystems."/home/v0id/games/epic" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/games/epic" ];
    };

  fileSystems."/home/v0id/games/gog" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/games/gog" ];
    };

  fileSystems."/home/v0id/games/emu" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/games/emu" ];
    };

  fileSystems."/home/v0id/presets" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/presets" ];
    };

  fileSystems."/home/v0id/config" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/config" ];
    };

  fileSystems."/home/v0id/nixflake" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/nixflake" ];
    };

  fileSystems."/home/v0id/help" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=home/v0id/help" ];
    };

  fileSystems."/data/ssd" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=data/ssd" ];
    };

  fileSystems."/data/hdd" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=data/hdd" ];
    };

  fileSystems."/data/raid" =
    { device = "/dev/disk/by-uuid/00874501-669c-499a-8d95-921af8d0804c";
      fsType = "btrfs";
      options = [ "subvol=data/raid" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/660d11bd-d830-4b6a-8102-c392f2d0497d"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp8s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
