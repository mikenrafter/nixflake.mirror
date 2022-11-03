inputs: with inputs;
{
  imports = [
    impermanence.nixosModule
    ./one.nix
    ./wipe.nix
  ];
}
