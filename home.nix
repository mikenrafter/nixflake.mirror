inputs: with inputs;
with utility;
with builtins;

rec {

  #programs = {
  #  dconf.enable = true;
  #};
  home.packages =
  (with free; [ #{
  # core {
  bitwarden                 # password manager, it's that simple :)
  nitrogen                  # wallpaper manager
#?picom                     # compositor
  xsecurelock               # secure lockscreen
  xss-lock                  # lockscreen as screensaver
  #}

  firefox chromium
  python3 poetry
  undistract-me pacman pavucontrol

  # temp etc
  sqlite
  thunderbird
  mate.engrampa

#Bcmake                     # for source builds
#Bbinutils                  # for source builds
#Bgcc                       # compiler

  goldberg-emu              # separate things from steam :)

  #}
  ]) ++
  (with unfree; [ #{
  #steam lutris
  #}
  ]);
#{ file tracking
#files = [
#  (pattern-map frozen "*.policy" ./polkit  "share/polkit-1/actions")
#  (blind-map              ./scripts "bin")
#  (blind-map              ./scripts "scripts") # alternate
#  (blind-map              ./apps    "share/applications")
#];
#}
}
