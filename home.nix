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
# (vm          frozen   free)
  (xorg        frozen   free)
  (hacking     frozen   free)
  (flossGames  frozen   free)
  (experiments frozen   free)
# (misc        frozen   free)
# [haskell     frozen   free]
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
#   "deadd/"
  ] ++
  # config/     -> ~/
  map basic-conf [
#   ".vimrc"
#   ".profile"
#   ".path.fish"
#   ".path.sh"
  ]
);
# }
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
      EDITOR = "nvim"; # custom script pointing to nvim
      BROWSER = "re.sonny.Junction"; # not in nix repos yet :/
      PAGER = "nvimpager";
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
}
