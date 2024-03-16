inputs: with inputs; with lib; let
  enable = true;
  pkgs = locked;
in (if enable then rec {
  services.xserver.videoDrivers = [ "nvidia" ];
  specialisation.external-display.configuration = {
    system.nixos.tags = [ "external-display" ];
    hardware.nvidia.prime.offload.enable   = mkForce false;
    hardware.nvidia.powerManagement.enable = mkForce false;
  };
  specialisation.no-nvidia.configuration = {
    system.nixos.tags = [ "unfree-nvidia" ];
    hardware.nvidia.open = mkForce false;
    # services.xserver.videoDrivers = mkForce [ "intel" ];
  };
  hardware.nvidia = {
    open = true; # let's test it out :]
    prime = {
      offload.enable = true;
      intelBusId  = "PCI:00:02:0";
      nvidiaBusId = "PCI:01:00:0";
    };
    powerManagement.enable = true;
    #powerManagement.finegrained = true;
    package = config.boot.kernelPackages.nvidia_x11;
    modesetting.enable = true;
  };
  environment.sessionVariables = rec {
    CUDA_PATH = "${pkgs.cudatoolkit}";
    # LD_LIBRARY_PATH = "${pkgs.linuxPackages.nvidia_x11}/lib:${pkgs.ncurses5}/lib";
    EXTRA_LDFLAGS = "-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib";
    EXTRA_CCFLAGS = "-I/usr/include";
  };
  environment.systemPackages = [
    pkgs.cudatoolkit
  ];
} else {})
