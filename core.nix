inputs: with inputs;
with utility;
with builtins;

let
extraUnfree = [
  "steam-original" "steam"
];
in # {
flip builtins.removeAttrs [ "unfreePackages" ]
#}
rec {
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (getName pkg) (extraUnfree // (builtins.attrNames unfreePkgs));
  environment.systemPackages =
  (with frozen; [ #{
  manix nixdoc              # nix documentation
  ]) #}
  ++
  (with free; [ #{

  # ultra basic necessities, should home-manager fail, these will still be here
  # {
  alacritty neovim vim
  fish dash bash            # main shell & sh + bash, for compatability
  wget curl git
  sudo doas
  qutebrowser
  nitrokey-app              # nitrokey!
  nitrokey-udev-rules       # ^ w/out root
  #}

  # nix stuff {
  nixos-install-tools       # for complete dominion of all the drives!
  nix-bundle                # https://github.com/matthewbauer/nix-bundle
  nix-diff                  # explain why two nix derivations differ
  #}
  # core system {
  btrfs-progs cryptsetup
  coreutils                 # don't piss GNU+Stallman off!
  libtool                   # more gnu tools
  lsof strace               # identify open files
  usbutils                  # lsusb+
  #}
  # userspace {
  xterm                     # basic terminal, as a backup only
  gnome.gnome-keyring       # Keyring, manages DBs other than pw-managers
  libsecret                 # secret storage
  gnome.gnome-keyring       # secret storage
  gnome.libgnome-keyring    # secret storage
  gnome.seahorse            # secret management
  #}
  # resource management {
  auto-cpufreq              # dynamic CPU frequency scaler
  earlyoom                  # oomKiller sucks! But this doesn't.
  freefall                  # anti HDD death
  #}


  ]) #}
  ++ unfreePackages;
  #}
  unfreePackages = with unfree; [
  ];
  programs = {
    steam.enable = true;
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };


  };
}
