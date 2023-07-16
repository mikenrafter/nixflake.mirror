inputs: with inputs; let
  enable = true;
in {
  sound.enable = !enable;
  security.rtkit.enable = enable;
  services = {
    pipewire = {
      # config.pipewire = {
      #   "context.properties" = {
      #     "link.max-buffers" = 64;
      #     #"link.max-buffers" = 16; # version < 3 clients can't handle more than this
      #     "log.level" = 2; # https://docs.pipewire.org/page_daemon.html
      #     #"default.clock.rate" = 48000;
      #     #"default.clock.quantum" = 1024;
      #     #"default.clock.min-quantum" = 32;
      #     #"default.clock.max-quantum" = 8192;
      #   };
      # };
      # enable
      audio.enable = enable;
      enable       = enable;

      # modernize
      #ystemWide         = true;
      socketActivation   = true;
      wireplumber.enable = true;

      # compatibility
      pulse.enable      = enable;
      jack.enable       = enable;
      alsa.enable       = enable;
      alsa.support32Bit = enable; # may be useful for games
    };
  };
}
