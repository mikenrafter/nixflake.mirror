{ free, unfree, ... }:

{
  home.stateVersion = "21.11"; # TODO after 22.05 upgrade
  # programs = {
  #   dconf.enable = true;
  # };
  home.packages =
  (with free; [ #{
  # core {
  bitwarden                 # password manager, it's that simple :)
  nitrogen                  # wallpaper manager
#?picom                     # compositor
  xsecurelock               # secure lockscreen
  xss-lock                  # lockscreen as screensaver
  #}

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
}
