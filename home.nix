inputs: with inputs;
with utility;
with builtins;
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
  ])
  ); # }
in rec {

  #programs = {
  #  dconf.enable = true;
  #};
  home.packages = selections;
# { file tracking
#files = [
#  (pattern-map frozen "*.policy" ./polkit  "share/polkit-1/actions")
#  (blind-map              ./scripts "bin")
#  (blind-map              ./scripts "scripts") # alternate
#  (blind-map              ./apps    "share/applications")
#];
#}
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
}
