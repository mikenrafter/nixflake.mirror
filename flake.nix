{
  description = "My new NixOS configuration";
  inputs = {
    unstable.url = github:nixos/nixpkgs/nixos-unstable;
    stable  .url = github:nixos/nixpkgs/nixos-22.05;
    home-manager = {
      # TODO: when 22.05 isn't latest, upgrade
      url = github:nix-community/home-manager/release-21.11;
      inputs.nixpkgs.follows = "stable";
    };
  };
  outputs = inputs@{ ... }: with inputs;
    let # basics {
      hostname = "warrANTI";
      user = "v0id";
      system = "x86_64-linux";
      lib = stable.lib;
      attrs = { inherit hostname user system lib; };
      utility = import ./utility.nix (inputs // attrs // {inherit lib;});
    in with utility; let #}
      # inputs {
      unfree = enslave unstable;
      locked = enslave   stable;
      free   = ingest  unstable;
      frozen = ingest    stable;
      #}
      args = inputs // attrs // { # extra args for use with all submodules
        # sets
        # include self for sublet use - utilize laziness
        #nherit args;
        # inputs
        inherit inputs
          free   frozen
          unfree locked;
        # attributes
        inherit nixos;
      };
      nixos = true;
  in makeAtHome {
   inherit args hostname;
   standalone = true;

   users = {
     "${user}" = { ... }: {
       imports = [ ./home.nix ];
       home.stateVersion = "21.11"; # TODO: when 22.05 isn't latest, upgrade
     };
   };

   config = {
     specialArgs = args;
     "${hostname}" = lib.nixosSystem {
       #pecialArgs = args;
       inherit system;
       modules = [ ./system.nix ]; # home-manager is added here
     };
   };
};
}
