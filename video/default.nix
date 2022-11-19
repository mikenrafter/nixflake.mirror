inputs: with inputs; with builtins;
{
  environment.systemPackages = [( lib.hiPrio (
    locked.writeShellScriptBin "gpu"
"\
${readFile ./intel.sh }\
${readFile ./nvidia.sh}\
exec \"$@\""
  ))];

  hardware.opengl.enable = true;
  imports = [
    ./nvidia.nix
    ./intel.nix
  ];
}
