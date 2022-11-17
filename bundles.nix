_: # these can be used in permanent package sets, or can be accessed ephemerally
#    by doing: `nix develop '.#media.creating'` for example
{
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
  s.librewolf               # top-notch browser
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
# python27                  # python interpreter 2.7
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
  pipes                     # wine but better XD
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
  vitetris                  # epic terminal-based tetris game
  superTuxKart              # super-tux-kart!
  xonotic                   # gud FPS
  _2048-in-terminal
  _0verkill
  cuyo
  #(lib.hiPrio u.dolphin-emu-primehack)
  ]; #}
  misc = s: u: # {
  with u; [
  cointop                   # crypto tracker
#Mstonks                    # stocks tracker - in Arch Repos only, atm
  ]; #}
  experiments = s: u: # {
  with u; [
  undistract-me pacman

  # temp etc
  sqlite-interactive
  mate.engrampa
  #busybox
  unzip
  xclip

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
  # obs-move-transition       # OBS move items upon transition
  # obs-wlrobs                # OBS wayland screen captures
  ]; #}
  creating = s: u: # {
    with u; [
    blender                   # 3d editor ftw
    cura                      # 3d slicer
    avidemux                  # a very basic video editor
    olive-editor              # a more complex video editor
    kdenlive                  # a more complex video editor
    ardour                    # music.mp3
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
  #Bnuclear                   # music streamer (in need of some love)
  #Bnewsflash                 # RSS reader
  ]; #}
  };
  utils = {
  terminals = s: u: # {
    with u; [
    st                        # my terminals
  #Balacritty                 # my terminals
  #Btermite                   # my terminals
  ];
  #}
  debuggers = s: u: # {
    with u; [
    cgdb gdb pwndbg edb       # general debuggers suite :)
    bench                     # CLI benchmarking tool
  # pydb                      # python debugger
    bashdb                    # bash debugger
    delve                     # golang debugger
  ];
  #}
  security = s: u: # {
    with u; [
    # open VPN solutions
    openvpn gnome.networkmanager-openvpn
    # proton vpn solution
    protonvpn-cli #protonvpn-gui
    # wireguard vpn stuff
    boringtun wg-bond wireguard-tools
    firejail                  # sandbox applications, particularly useful with web browsers
    usbguard                  # anti badusb
    tor torsocks              # online protection
    macchanger                # randomize your mac address
    s.vulnix                  # vuln scanner
    sshguard                  # anti ssh attacks
    ferm                      # complex firewall management
    firehol                   # "a firewall for humans"
    opensnitch
    opensnitch-ui             # another firewall??
  ];
  #}
  shells = s: u: # {
    with u; [
    any-nix-shell             # connect nix-shell with yours
    zsh                       # Zsh because it's useful I guess...
    bash bashInteractive      # Bash shell for easier scripting
  ];
  #}
  cli = s: u: # {
    with u; [
    bottom htop               # system monitors
    ftop                      # file-top
    nix-top                   # nix watcher

    hostname                  # the ability to modify your hostname | un-nix?
    bat exa fd                # better coreutils in rust
    lzip gzip bzip2 xz        # zippers
    curl wget                 # downloaders
    more less                 # pagers
    git git-annex             # version control + file management solution
    wally-cli qmk             # mechanical keyboard stuff
    archivemount              # mount archives (via FUSE)

    xclip                     # clipboard util

    rsync                     # powerful file copy/share
    ffsend                    # file share for use with FF
    fzf                       # fuzzy finder tool
    btrfs-progs               # betterfs tools
    screen                    # multiplex/session manager
    neofetch pfetch           # show off your system
    pandoc                    # conversion tool

    flootty                   # collab TTY
  ];
  #}
  gui = s: u: # {
    with u; [
    xdragon                   # drag-n-drop utility
    czkawka                   # file duplicate management tool
    transmission-gtk          # torrent tool! also has cli
    sxiv                      # simple x image viewer
    clipit                    # clipboard manager
#   parcellite                # clipboard manager
    xzoom                     # screen magnifier   : These work well
    colorpicker               # hex value of pixel : together.
    brightnessctl             # manage brightness
#   remmina                   # remote connection client
    cinnamon.warpinator       # LAN file sharer
    xfce.thunar gvfs          # file manager + trash support
    conky                     # snazzy
    deadd-notification-center # notification system
    gxmessage                 # dialog system
    caffeine-ng               # stop screen-locking
    blueman                   # bluetooth tray
    networkmanagerapplet      # network tray
    stalonetray               # better system tray
#   trayer                    # system tray
    mate.engrampa             # Archive tool GUI
#   ark                       # Archive tool GUI
    qalculate-gtk             # nice calculator
    kmplot                    # plotting software (graphing calc)
    tilem                     # TI# calculator emulator (needs ROM file)
    usermount                 # automatically mount drives as they appear
    gnome.dconf-editor        # dconf editor, duh
    drawing                   # basic drawing tool - like G-drawings
    drawio                    # flowcharts!!!!
    weston                    # basic wayland compositor, for mucking and dev
];
#}
  };
}
