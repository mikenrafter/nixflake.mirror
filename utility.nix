{ home-manager, lib, system, ... }:
with builtins;
with lib;
rec {
# conditional actions {
ifNix = mkIf nixos;
#}
# helpers {
an = n: attrsets.genAttrs [ n ];
flip = f: a: b: f b a;
empties = names: listToAttrs (map (n: {name=n; value={};}) names);
removeHelpers = set: removeAttrs set (filter (n: substring 0 1 n == "_") (attrNames set));
ln = item: "L ${item} - - - - /persist${item}";
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
os = cfg: nixosSystem (cfg // {inherit system;});
const = f: _: f;
#}
# home-manager integration {
# handle home-manager users intelligently
# home=pkgs & args
makeAtHome = { standalone ? true, home, hostname, config, devShells ? {} }:
{inherit devShells;} // (

if standalone then
  { inherit devShells; nixosConfigurations = mapAttrs (const os) config; } //
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
  {  inherit devShells; nixosConfigurations = mapAttrs (const os) (config // (with config; {
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
  }

);
#}
# basic setup {
population = users: groups: _: # _ is to make this a valid module (to be used in flake.nix)
  { users.users =
      listToAttrs (map (name:
        { inherit name; value = {
          isNormalUser = true;
          description = name;
          initialPassword = name;
          extraGroups = [ "networkmanager" "wheel" "video" "audio" "lp" "scanner" ] ++ groups;
        }; } )
        (attrNames users)
      );
  };
#}
# handle generated volume file {
volumes = file:
  let  # see format.sh
    mount = [ "compress=zstd" "noatime" ];
    all = import file (empties ["config" "lib" "pkgs"] // {modulesPath=./.;});
  in with all; {
    boot.initrd.luks.devices = all.boot.initrd.luks.devices;  # LUKS
    inherit swapDevices;  # swap
    fileSystems = mapAttrs (_: v: v
        // (if hasAttr "options" v then
           { options = v.options ++ mount; }  # add the modes
           else { } )
    ) ( fileSystems // {  # the imported FS' but with extra options
       "/persist" = fileSystems."/persist" // { neededForBoot = true; };
       "/var/log" = fileSystems."/var/log" // { neededForBoot = true; };
           # /boot/efi explicitly doesn't need those mount options
    } ) // {inherit (fileSystems) "/boot/efi";};
  };
#}
  # make bundles into devshells {
   # :: Import MkShell -> Name -> [Packages] -> DevShell [Packages]
   shell = p: name: list: let
   names = map (a: a.name) list;
   in p.mkShell {
     buildInputs = list;
     shellHook = "echo [ ${name} ]:\n"
               + (concatStringsSep "" (map (n: "echo ${n}\n") names));
   };
   # :: NameSpace -> Import (Maybe Stable) -> Import (Maybe Unstable)
   #              -> {Packages} -> [DevShell [Packages]]
   bundle = parent: s: u: set:
     mapAttrs (n: v: let
         namespace = parent+(if parent == "" then "" else ".")+n;
       in if typeOf v == "set"
       then bundle  namespace  s u v
       else shell s namespace (v s u)
     ) set;
  #}
}
