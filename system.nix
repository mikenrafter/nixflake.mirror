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
  ./stealth      # device field randomization
  ./security     # defenses
  ];

  # booting & kernel
  boot = rec {
    # kernel things
    # unfree for nvidia... :/
    kernelPackages = locked.linuxKernel.packages.linux_6_1;
    kernelModules = [ "kvm-intel" ];
    kernelParams = [  ];
    extraModulePackages = with kernelPackages; [ system76 system76-power system76-io v4l2loopback ];
    # extraModulePackages = with kernelPackages; [ system76 system76-power system76-acpi system76-io v4l2loopback ];
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
        # enable = true;
        # version = 2;
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
    "steam-original" "steam" "steam-run"
    ];
    config.allowInsecurePredicate = pkg: builtins.elem (getName pkg) [
    # TODO determine if electron will ever grow up
    "electron"
    "snapmaker"
    ];
  };

  virtualisation = {
    # virtualbox.host = {
    #   enable = true;
    #   enableExtensionPack = true;
    #   ^^^ "Oracle_VM_VirtualBox_Extension_Pack"
    # };
    # docker.enable = true;
    podman.enable = true;
    lxd = {
      enable = true;
      recommendedSysctlSettings = true;
    };
  };

  networking  = {
    hostName = "warrANTI";
    networkmanager = {
      enable = true;
    };
    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  };

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";
  console.font = mkDefault "${free.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  services = {
  # printing {
  printing.enable = true;
  avahi.enable = true;
  avahi.nssmdns = true;
  # for a WiFi printer
  avahi.openFirewall = true;
  # }

  gnome.gnome-keyring = {
    enable = true;
  };
 #physlock = {
 #  enable = true;
 #  lockOn.extraTargets = [
 #    "display-manager.service"
 #  ];
 #};
  tailscale = {
    enable = true;
    # openFirewall = true;
    # extraUpFlags = [
    #   "--exit-node=localhost"
    #   ];
  };
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
      defaultSession = "none+xmonad";
    };
    #esktopManager.plasma5.enable = true;
    desktopManager.xfce.enable = true;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      flake = {
        enable = true;
        #refix = "unstable";
        #ompiler = "ghc924";
      };
    };
    libinput = {
      enable = true;
      touchpad.tapping = true;
      touchpad.naturalScrolling = false; # DO NOT BE A MONSTER!
    };
  };
  flatpak = {
    enable = true;
  };
  blueman = {
    enable = true;
  };
  psd = { # profile-sync-daemon
    enable = true;
    resyncTimer = "25m";
  };
  udev.packages = with free; [
  android-udev-rules
  ];
  };
  xdg = {
    sounds.enable = true;
    portal = {
      enable = true;
      extraPortals = with free; [ xdg-desktop-portal-gtk ];
    };
  };

  # let's be pragmatic...
  # programs.nix-ld.enable = true;
  # programs.nix-ld.libraries = with free; [
    # Add any missing dynamic libraries for unpackaged 
    # programs here, NOT in environment.systemPackages
  # ];

  programs.slock.enable = true;
  # enable doas, over sudo
  security.doas.enable = true;
  # TODO come back to this
  security.doas.extraConfig = ''
    # permit keepenv :wheel
    permit setenv { XAUTHORITY LANG LC_ALL } :wheel
    permit persist :wheel
    permit :wheel as root cmd nixos-rebuild args switch
  '';

  system = {
    autoUpgrade = {
      enable = true;
      flake = inputs.self.outPath;
      flags = [
        "--update-input"
        "stable"
        "--update-input"
        "unstable"
        "-L" 
      ];
      dates = "09:00";
      randomizedDelaySec = "45min";
    };
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      auto-allocate-uids = true;
      # TODO determine if this' problematic
      # always-allow-substitutes = true;
      # speed up builds
      keep-failed = true;
      keep-going = true;
      keep-outputs = true;
      plugin-files = [
        # place nix-doc here (not nixDoc)
      ];
      # TODO does this break things?
      pure-eval = true;
      sandbox = mkForce true;
      # TODO make a list of non-root users for build security
      # build-users = [];
      # TODO maybe use?
      # use-xdg-base-directories = true;
      # seriously nix, shut up
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 21d";
    };
    package = free.nixVersions.stable;
    extraOptions = "experimental-features = nix-command flakes dynamic-derivations auto-allocate-uids";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = true; # TODO explore this further

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

# TODO: https://git.sr.ht/~misterio/nix-config/tree/main/item/templates
