{ free, unfree, ... }:

{
  programs = {
    dconf.enable = true;
  };
  home.packages =
  (with free; [ #{
  # core {
  bitwarden                 # Password manager, it's that simple :)
  nitrogen                  # wallpaper manager
#?picom                     # compositor
  xsecurelock               # secure lockscreen
  xss-lock                  # lockscreen as screensaver
  #}

#Bcmake                     # for source builds
#Bbinutils                  # for source builds
#Bgcc                       # compiler

  #}
  ]) ++
  (with unfree; [ #{
  steam
  #}
  ]);
}
