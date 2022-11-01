{ config, lib, modulesPath, frozen, locked, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking = {
    useDHCP = lib.mkDefault true;
    interfaces = {
      enp8s0.useDHCP = lib.mkDefault true;
      wlp0s20f3.useDHCP = lib.mkDefault true;
    };
  };

  services.auto-cpufreq.enable = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware = {
    system76.kernel-modules.enable = true;
    system76.enableAll = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    bluetooth = {
      enable = true;
      hsphfpd.enable = true; # HSP & HFP daemon
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
  };
}
