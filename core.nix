inputs: with inputs;
with utility;
with builtins;

let
extraUnfree = [
  "steam-original" "steam"
];
in removeHelpers rec {
  nixpkgs.config.allowUnfreePredicate = pkg: elem (getName pkg) (extraUnfree // (attrNames _unfree));
  environment.systemPackages =
  (with frozen; [ #{
  manix nixdoc              # nix documentation
  ntfs3g                    # *cries*
  mtpfs                     # android connection
  # TODO - look @
  # linuxPackages.nvidia_x11_stable_open
  ]) #}
  ++
  # ultra basic necessities, should home-manager fail, these will still be here
  (bundles.system frozen free)
  ++ _unfree;
  _unfree = with unfree; [
  ];
  programs = {
    #steam.enable = true;
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
