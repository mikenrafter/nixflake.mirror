{ home-manager, lib, system, ... }: with builtins; with lib; {
# conditional actions {
ifNix = mkIf nixos;
#}
# helpers {
an = n: attrsets.genAttrs [ n ];
#}
# import helpers {
ingest = x: import x {inherit system;};
enslave = x: import x {
  inherit system;
  config.allowUnfree = true;  # all evil software here...
};
#}
# mapping files {
basic-conf  = an (x: {source=./config     + ("/" + x); target="./" + x;});
dot-config  = an (x: {source=./config/dot + ("/" + x); target="./.config/" + x;});
pattern-map = p: f: t:  libs.runCommand "map" {} "mkdir -p $out/${t}; ln -s ${f}/${p} $out/${t}/";
blind-map   = pattern-map "*"; #link all files
# }

# handle home-manager users intelligently
makeAtHome = { args, hostname, standalone ? true, users, config }:
if standalone then
  { nixosConfigurations = config;
#   home = home-manager.lib.homeManagerConfiguration
#   (users.v0id // {extraSpecialArgs = args;}); # TEMP
#   { users = ( mapAttrs (_: x: x // {extraSpecialArgs = args;}) users ); inherit system; configuration=users; homeDirectory="/home/v0id"; username="v0id";}
  }
else
  # TODO: see if there's a simpler way to do this
  # take config, override nixosConfig.<you>.modules
  { nixosConfigurations = config // (with config; {
    # with self+HM
    "${hostname}" = config."${hostname}" // { modules = "${hostname}".modules ++
      home-manager.nixosModules.home-manager {
        home-manager.users = users;
        home-manager.extraSpecialArgs = args;
        home-manager.useGlobalPkgs    = true;
        home-manager.useUserPackages  = true;
      };
    };
  });
  };
#}

}
