inputs: with inputs;
{
  hardware.opengl.enable = true;
  imports = [
    ./nvidia.nix
    ./intel.nix
  ];
}
