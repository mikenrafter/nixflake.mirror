inputs: with inputs;
{
  hardware.opengl.extraPackages = with frozen; [
    intel-media-driver # LIBVA_DRIVER_NAME=iHD
    vaapiIntel         # LIBVA_DRIVER_NAME=i965
    vaapiVdpau
    libvdpau-va-gl
  ];
}
