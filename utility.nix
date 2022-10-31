{ home-manager, lib, system, ... }:
with builtins;
rec {
# conditional actions {
ifNix = mkIf nixos;
#}
# helpers {
an = n: attrsets.genAttrs [ n ];
flip = f: a: b: f b a;
empties = names: listToAttrs (map (n: {name=n; value={};}) names);
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
pattern-map = pkgs: p: f: t:  pkgs.runCommand "map" {} "mkdir -p $out/${t}; ln -s ${f}/${p} $out/${t}/";
blind-map   = pattern-map "*"; #link all files
# }
# niche shortcuts {
# shortcut for a common basic nixosSystem call
os = cfg: lib.nixosSystem (cfg // {inherit system;});
const = f: _: f;
#}
# home-manager integration {
# handle home-manager users intelligently
# home=pkgs & args
makeAtHome = { standalone ? true, home, hostname, config }:
if standalone then
  { nixosConfigurations = mapAttrs (const os) config; } //
    ( mapAttrs (username: imports:
      home-manager.lib.homeManagerConfiguration ({
        homeDirectory = "/home/${username}";
        extraSpecialArgs = home.args;
        configuration.imports = imports;
        inherit username system;
        inherit (home) pkgs;
       })
    ) home.users )
else
  # TODO: see if there's a simpler way to do this
  # take config, override nixosConfig.<you>.modules
  { nixosConfigurations = mapAttrs (const os) (config // (with config; {
    # with self+HM
    "${hostname}" = config."${hostname}" // { modules = "${hostname}".modules ++
      home-manager.nixosModules.home-manager {
        home-manager.users = mapAttrs (n: imports: {inherit imports;}) home.users;
        home-manager.extraSpecialArgs = home.args;
        home-manager.useGlobalPkgs    = true;
        home-manager.useUserPackages  = true;
      };
    };
  }));
  };
#}
# basic setup {
population = users: _: # _ is to make this a valid module (to be used in flake.nix)
  { users.users =
      listToAttrs (map (name:
        { inherit name; value = {
          isNormalUser = true;
          description = name;
          initialPassword = name;
          extraGroups = [ "networkmanager" "wheel" "video" "audio" "lp" "scanner" ];
        }; } )
        (attrNames users)
      );
  };
#}
# handle generated volume file {
volumes = file:
  let  # see format.sh
    mount = [ "compress=zstd" "noatime" ];
    #device = "/dev/disk/by-label/ROOT";
    device = "/dev/mapper/enc";
    #device = "/dev/disk/by-uuid/61fd7c9a-b926-4d24-b7a4-396fb5bca39b";
    fsType = "btrfs";
    all = import file (empties ["config" "lib" "pkgs"] // {modulesPath=./.;});
  in with all; {
    boot.initrd.luks.devices = all.boot.initrd.luks.devices;  # LUKS
    inherit swapDevices;  # swap
    fileSystems = mapAttrs (_: v:
      v // { inherit device fsType; } # device & fs
      #v // { inherit fsType; } # device & fs
        // (if hasAttr "options" v then
           { options = v.options ++ mount; }  # add the modes
           else { } )
    ) ( fileSystems // {  # the imported FS' but with extra options
       #"/" = fileSystems."/" // { options = fileSystems."/".options ++ [ "mode=755" ]; };
       "/var/log" = fileSystems."/var/log" // { neededForBoot = true; };
    } );
  };
#}
}
