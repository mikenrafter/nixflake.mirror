inputs: with inputs;
with utility;
with builtins;
with lib;

rec {
  #pecialArgs = { inherit free unfree frozen locked; };
  imports =
  [
  ./core.nix     # packages
  ./hardware.nix # hardware
  ./audio        # pipewire
  ./video        # intel & nvidia
  ./keyboard
  ];

  # booting & kernel
  boot = rec {
    # kernel things
    kernelPackages = locked.linuxPackages_latest; # unfree for nvidia... :/
    kernelModules = [ "kvm-intel" ];
    kernelParams = [  ];
    extraModulePackages = with kernelPackages; [ system76 system76-power system76-acpi system76-io ];
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    initrd.kernelModules = 
      [ # utilize with virtual machines...
        # "nvidia_drm" # I think...

      ];

    # boot things
    loader = {
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";

      timeout = 2;

      systemd-boot = {
        enable = true;
        configurationLimit = 20; # 20 generations back...
      };

      grub = {
        #enable = true;
        version = 2;
        efiSupport = true;
      # efiInstallAsRemovable = true;
        device = "nodev"; # nodev for dualboot full compatibility...
        useOSProber= true;
        configurationLimit = 20; # 20 generations back...
      };
    };
  };


  nixpkgs = {
    config.allowUnfreePredicate = pkg: builtins.elem (getName pkg) [
    "steam-original" "steam"
    ];
  };

  virtualisation = {
    docker.enable = true;
    podman.enable = true;
    lxd = {
      enable = true;
      recommendedSysctlSettings = true;
    };
  };

  networking.hostName = "warrANTI"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";
  console.font = lib.mkDefault "${free.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  services = {
    xserver = {
      enable = true;
      displayManager = {
        lightdm.enable = true;
	lightdm.greeters.gtk.indicators = 
  	[
          "~host"
          "~spacer"
          "~clock"
          "~spacer"
          "~session"
          "~language"
          "~a11y"
          "~power"
        ];
	defaultSession = "xfce"; # "none+xmonad";
      };
      desktopManager.xfce.enable = true;
      # windowManager.xmonad.enable = true;
      libinput = {
        enable = true;
        touchpad.tapping = true;
        touchpad.naturalScrolling = false; # DO NOT BE A MONSTER!
      };
    };
    usbguard.enable = false;
    usbguard.presentDevicePolicy = "allow"; # for setup
  };
  xdg = {
    sounds.enable = true;
  };

  # enable doas, over sudo
  security.doas.enable = true;
  security.doas.extraConfig = ''
    # permit keepenv :wheel
    permit setenv { XAUTHORITY LANG LC_ALL } :wheel
    permit persist :wheel
    permit :wheel as root cmd nixos-rebuild args switch
  '';

  system = {
    autoUpgrade = {
      enable = true; # TODO determine: only for system-config, not flakes/HM?
      channel = "https://nixos.org/channels/nixos-unstable";
    };
  };

  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 21d";
    };
    package = free.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false; # TODO <- this is temp

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

# TODO: https://git.sr.ht/~misterio/nix-config/tree/main/item/templates
