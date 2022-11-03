inputs: with inputs;
with utility;
with builtins;
let
options = {
  unfree = s: u: # {
  with s; [
  #steam
  #lutris
  polymc                    # minecraft isn't FOSS
  ]; #}
  core = s: u: # {
  with u; [
  bitwarden                 # password manager, it's that simple :)
  nitrogen                  # wallpaper manager
#?picom                     # compositor
  xsecurelock               # secure lockscreen
  xss-lock                  # lockscreen as screensaver
  ]; #}
  etc = s: u: # {
  with u; [
  s.firefox                 # FF meh, librewolf tho
# brave                     # backup browsers
  chromium                  # backup browsers
  browsh                    # TUI browser
  thunderbird               # Mozillas mail client
  mailspring                # email client
  libreoffice               # office suite
#Bgodot                     # game engine
  legendary-gl #Bheroic     # "epic" game yoinking
  pidgin                    # chat client
  tut                       # TUI mastodon client
  element-desktop           # matrix client
  cinny                     # matrix client
  emote                     # emoji picker
  ]; #}
  code = s: u: # {
  with s; [
  nim                       # nim compiler
  jdk                       # java runtime
  python27                  # python interpreter 2.7
  python3                   # python interpreter 3.*
  poetry                    # python package-manager
  yarn                      # JS dep-manager | coc.vim needs it

  cabal2nix                 # haskell packager
  ]; #}
  editors = s: u: # {
  with s; [
# nvimpager                 # why not?
  amp kakoune               # similar to vim
  micro                     # similar to nano
  notepadqq                 # GUI text editor
  nano gnome.gedit          # basic AF editor
  sc-im                     # command-line spreadsheet program
  languagetool              # proofread tool
  ]; #}
  fonts = s: u: # {
  with u; [
  (nerdfonts.override {
    fonts = [
    "Mononoki"
    "Meslo"
    "FiraCode"
    "Terminus"
    ];
  })

  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  liberation_ttf
  #s.mplus-outline-fonts
  dina-font
  (hiPrio proggyfonts)
  uw-ttyp0
  tamzen
  powerline-fonts
  # not sure this one belongs here :shrug:
  fontforge-gtk
  ]; #}
  extras = s: u: # {
  with u; [
  sl                        # to fix ls typos, of course
#Bbsod
  pipes                # wine but better XD
  vitetris                  # epic terminal-based tetris game
#Belectricsheep             # A p2p artwork creating screensaver
  breeze-icons              # icon theme
  libsForQt5.qtstyleplugins # let QT themes apply properly
  adwaita-qt                # blend QT into gnome's style
  qt5ct                     # theming for stuff inside xorg
  xsettingsd                # application settings, alternative to gsettingsd
  lxappearance              # theming
  touchegg                  # touch gestures
  ]; #}
  vm = s: u: # {
  with u; [
  dolphinEmuMaster          # wii/gamecube emulator (near-git version)
  rpcs3                     # ps3 emulator
#Banbox                     # Android APK runner
# virt-manager              # VM manager
  virtualbox                # VM host
  qemu-utils                # qemu tools
  (hiPrio qemu)         # VM method
  qemu_kvm                  # VM qumu bridge
# kvm                       # VM method
#Blibguestfs                # for accessing guest fs's
  # IDK, kvm stuff...
  bridge-utils
# virt-viewer
  dnsmasq
  vde2
  netcat
  edk2
  OVMF
# OVMFFull
  libvirt
# virtlyst
# swtpm
# swtpm-tpm2
  ]; #}
  xorg = s: u: # {
  with u;
  (with xorg; [
  libXrandr                 # res change lib
  xrandr                    # change your resolution
  xprop                     # x properties
  xwininfo                  # like xprop
  xev                       # input tester
  ]) ++ [
  autorandr                 # display manager
  xdotool                   # virtual keypress util
  wmctrl                    # window manager functions
  greetd.greetd             # greeter!
  greetd.tuigreet           # greeter!
  greetd.dlm                # greeter!
  greetd.gtkgreet           # greeter!
  ]; #}
  hacking = s: u: # {
  with u; [
# keybase kbfs keybase-gui  # less secure, but screw it
# torbrowser                # heck yeah
  cutter                    # cut TCP/IP connections
  wireshark                 # monitor network packages
  ]; #}
  flossGames = s: u: # {
  with u; [
  superTuxKart              # super-tux-kart!
#Bxonotic                   # gud FPS
  _2048-in-terminal
  _0verkill
  cuyo
  #(lib.hiPrio u1.dolphin-emu-primehack)
  ]; #}
  experiments = s: u: # {
  with u; [
  undistract-me pacman

  # temp etc
  sqlite
  mate.engrampa
  busybox unzip

#Bcmake                     # for source builds
#Bbinutils                  # for source builds
#Bgcc                       # compiler

  goldberg-emu              # separate things from steam :)
  ]; #}
  haskell = s: u: # {
  with u;
  # ghcWithHoogle > ghcWithPackages -> haddock
    let f = haskell.lib.appendConfigureFlag;
    in haskellPackages.ghcWithHoogle (p: with p; [
  xmonad                    # wm
  xmonad-contrib            # xmonad stuff
# xmonad-extras             # xmonad-contrib++ # needs transition to flakes
  xmonad-utils              # xmonad more more stuff stuff
# DescriptiveKeys           # xmonad stuff more in the more of the stuff
f xmobar "-f all_extensions"# xmobar addition for xmonad
# control-bool

  random-fu                 # functions for use in xmonad
#?text                      # useful functions for working w/ json

#Tyi-custom                 # haskellEditor
  ]); #}
  media = {
  managing = s: u: # {
    with u; [
    pavucontrol               # pulseaudio manager
    playerctl                 # manage media easier
    easyeffects               # apply effects to audio in pw
    qpwgraph helvum carla     # pipewire, testing stuff
  ]; #}
  capturing = s: u: # {
    with u; [
    maim                      # screenshot tool
    scrot                     # super simple screenshot utility
    flameshot                 # screenshot utility
    capture                   # A "no BS" CLI simple screen capture utility
    obs-studio                # OBS itself
  # obs-v4l2sink              # OBS virtual camera - merged into OBS
  # obs-move-transition       # OBS move items upon transition
  # obs-wlrobs                # OBS wayland screen captures
  ]; #}
  creating = s: u: # {
    with u; [
    blender                   # 3d editor ftw
    cura                      # 3d slicer
    avidemux                  # a very basic video editor
  # olive-editor              # a more complex video editor
    kdenlive                  # a more complex video editor
  #tardour                    # music.mp3
    audacity                  # modify.mp3
    gimp                      # modify.img
    krita                     # paint.img
    akira-unstable            # SVGs.img
  ]; #}
  viewing = s: u: # {
    with u; [
    # TODO: LBRY
    celluloid mpv vlc         # multimedia players
    minitube yt-dlp           # view youtube videos
    gpodder vocal             # podcast clients

  #Tcpod                      # an electron podcast client in need of some love
  #Bnuclear                   # music streamer
  #Bnewsflash                 # RSS reader
  ]; #}
  };
};

selections = # {
  concatLists ( with options;
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
  (flossGames  frozen   free)
  (experiments frozen   free)
# [haskell     frozen   free]
  ] ++       ( with  media; [
  (managing    frozen   free)
  (capturing   frozen   free)
  (creating    frozen   free)
  (viewing     frozen   free)
  ])
  ); # }

in rec {

  #programs = {
  #  dconf.enable = true;
  #};
  home.packages = selections;
#{ file tracking
#files = [
#  (pattern-map frozen "*.policy" ./polkit  "share/polkit-1/actions")
#  (blind-map              ./scripts "bin")
#  (blind-map              ./scripts "scripts") # alternate
#  (blind-map              ./apps    "share/applications")
#];
#}
}
