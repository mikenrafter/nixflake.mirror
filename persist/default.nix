inputs: with inputs;
{
  imports = [
    impermanence.nixosModule
    ./wipe.nix

    ./cache.nix
    ./persist.nix
  ];
}
