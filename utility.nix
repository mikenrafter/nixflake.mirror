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
    home = home-manager.lib.homeManagerConfiguration
    ( map (x: x // {extraSpecailArgs = args;}) users );
  }
else
  # TODO: see if there's a simpler way to do this
  # take config, override nixosConfig.<you>.modules
  { nixosConfigurations = config // (with config; {
  # with self+HM
    "${hostname}" = config."${hostname}" // { modules = "${hostname}".modules ++
      home-manager.nixosModules.home-manager {
      home-manager = {
        inherit users;
        extraSpecialArgs = args;
        useGlobalPkgs    = true;
        useUserPackages  = true;
      };
    };};
  });
  };
#}

}
