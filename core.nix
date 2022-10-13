{ free, unfree, ... }:

{
  environment.systemPackages =
  (with free; [ #{

  # nix stuff {
  nixos-install-tools       # for complete dominion of all the drives!
  nix-bundle                # https://github.com/matthewbauer/nix-bundle
  manix nixdoc              # nix documentation
  nix-diff                  # explain why two nix derivations differ
  #}
  # core system {
  coreutils                 # don't piss GNU+Stallman off!
  libtool                   # more gnu tools
  lsof strace               # identify open files
  usbutils                  # lsusb+
  fish dash bash            # main shell & sh + bash, for compatability
  vim                       # editor le supreme
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

  #}
  ]) ++
  (with unfree; [ #{
  
  #}
  ]);
}
