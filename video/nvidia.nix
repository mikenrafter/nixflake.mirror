inputs: with inputs; let
  enable = true;
in (if enable then rec {
  services.xserver.videoDrivers = [ "nvidia" ];
  specialisation.external-display.configuration = {
    system.nixos.tags = [ "external-display" ];
    hardware.nvidia.prime.offload.enable   = lib.mkForce false;
    hardware.nvidia.powerManagement.enable = lib.mkForce false;
  };
  specialisation.no-nvidia.configuration = {
    system.nixos.tags = [ "no-nvidia" ];
    hardware.nvidia = lib.mkForce {};
    services.xserver.videoDrivers = lib.mkForce [ "intel" ];
  };
  hardware.nvidia = {
    prime = {
      offload.enable = true;
      intelBusId  = "PCI:00:02:0";
      nvidiaBusId = "PCI:01:00:0";
    };
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidia_x11;
    modesetting.enable = true;
  };
} else {})
