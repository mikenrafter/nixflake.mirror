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
    #powerManagement.finegrained = true;
    package = config.boot.kernelPackages.nvidia_x11;
    modesetting.enable = true;
  };
  environment.systemPackages = [
    (free.writeShellScriptBin "gpu" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec "$@"
    '')
  ];
} else {})
