inputs: with inputs;
with utility;
with builtins;
with lib;
let
selections = # {
  concatLists ( with bundles;
                            [
  (unfree      locked unfree)
  (core        frozen   free)
  (etc         frozen   free)
  (code        frozen   free)
  (editors     frozen   free)
  (fonts       frozen   free)
  (extras      frozen   free)
  (vm          frozen   free)
  (xorg        frozen   free)
  (hacking     frozen   free)
  (games       frozen   free)
  (experiments frozen   free)
  (misc        frozen   free)
  (haskell     frozen   free)
  ] ++       ( with  media; [
  (managing    frozen   free)
  (capturing   frozen   free)
# (creating    frozen   free)
  (viewing     frozen   free)
  ])++       ( with  utils; [
  (terminals   frozen   free)
  (debuggers   frozen   free)
  (security    frozen   free)
  (shells      frozen   free)
  (cli         frozen   free)
  (gui         frozen   free)
   dynamic     # files
   custom      # custom-builds
  ])
  ); # }
# { file tracking
dynamic = [
  (pattern-map frozen "*.policy" ./polkit  "share/polkit-1/actions")
  (blind-map   frozen  ./scripts "bin")
  (blind-map   frozen  ./scripts "scripts") # alternate
# (blind-map   frozen  ./apps    "share/applications")
];
# TODO: add from old config
static = lists.foldl (a: b: a // b) {} (
  # config/dot/ -> ~/.config
  map dot-config [
    "deadd/"
  ] ++
  # config/     -> ~/
  map basic-conf [
    ".vimrc"
    ".profile"
    ".path.fish"
    ".path.sh"
  ]
);
# }
# custom packages {
custom = map (x: lib.hiPrio (import x inputs)) [
  ./programs/nvim.nix
  ./programs/quickemu.nix
  ./programs/notify-send.py
# ./programs/stable-diffusion # TODO
# ./programs/yi.nix
# ./programs/dolphin-emu.nix
];
#}
in rec {
  programs = {
    nix-index.enable = true;
    nix-index.enableFishIntegration = true;
    nix-index.enableBashIntegration = true;
  #  dconf.enable = true;
  };
  home.packages = selections;
  home.file = static;
  # theming {
  #xsession.windowManager.command = "${config.home.profileDirectory}/scripts/wm";
  #xsession.enable = true;
  #xsession.numlock.enable = true;
  # gtk
  gtk = {
    enable = true;
    theme.name = "Equilux"; #"Sweet-mars"; # "Equilux";
    theme.package = frozen.equilux-theme; #.sweet; #.equilux-theme;
    iconTheme.package = frozen.gnome3.gnome-themes-extra;
    iconTheme.name = "Adwaita";
  };
  # qt {
  #qt.enable = true;
  #qt.platformTheme = "gtk";
  #}
  # cursor theme
  home.pointerCursor = {
    x11.enable       = true;
    package          = free.phinger-cursors;
    #efaultCursor    = "left_ptr";
    name             = "phinger-cursors";
    size             = 16;
  };
  #}
  fonts.fontconfig.enable = true;
    services = {
      #opensnitch-ui.enable = true;
      #udiskie = {
      #  enable = true;
      #  automount = true;
      #  notify = true;
      #  tray = "always";
      #};
      # caffeine-ng used instead
      #caffeine.enable = false;
      #pasystray.enable = true;
      #blueman.enable = true;
      #blueman-applet.enable = true;
      #screen-locker = {
      #  enable = true;
      #  lockCmd = "${frozen.xsecurelock}/bin/xsecurelock";
      #  inactiveInterval = 1;
      #};
    };
  # env vars {
  home.sessionVariables = {
    EDITOR = "hx"; # custom script pointing to nvim
    BROWSER = "junction"; # not in nix repos yet :/
    PAGER = "more";
    XDG_DATA_DIRS = concatStringsSep ":" (map (profile: "${profile}/share") [ "/nix/var/nix/profiles/default" config.home.profileDirectory "/usr"]);
    QT_QPA_PLATFORMTHEME = "qt5ct";
    NUX_EXCEPTION = "/scripts"; # passed to grep
  };
  home.sessionPath = [
  "~/.local/bin"
  "~/appimages"
  "${config.home.profileDirectory}/scripts"
  ];
  #}
  # install manpages for packages too
  home.extraOutputsToInstall = ["doc" "info" "devdoc"];
}



# things to look into {
# # generate emulator config
#androidenv.emulateApp {
#  name = "emulate-MyAndroidApp";
#  platformVersion = "28";
#  abiVersion = "x86"; # armeabi-v7a, mips, x86_64
#  systemImageType = "google_apis_playstore";
#}
#`environment.etc.nixpkgs.source = inputs.nixpkgs;` to link the flake's nixpkgs to `/etc/nixpkgs`, and add `nixpkgs=/etc/nixpkgs` to `nix.nixPath`
#
#if you want something approximating environment.etc.<name>.source under Home Manager, you could use xdg.dataFile.<name>.source
#then you could use ~/.local/share/nixpkgs
#services.printing.drivers = with pkgs; [ gutenprint gutenprintBin epson-201106w epson-alc1100 epson-escpr epson-escpr2 epson-workforce-635-nx625-series epson_201207w ]
#}
