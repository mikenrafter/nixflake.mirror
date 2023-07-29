{ home-manager, lib, system, overlays, ... }:
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
elm  = items: i: if i > 0 then elm (tail items) (i - 1) else head items;
last = items: elm items (length items - 1);
#}
# import helpers {
ingest = x: import x {inherit system overlays;};
enslave = x: import x {
  inherit system overlays;
  config.allowUnfree = true;  # all evil software here...
};
#}
# mapping files {
basic-conf  = n: an n (x: {source=./config     + ("/" + x); target="./" + x;});
dot-config  = n: an n (x: {source=./config/dot + ("/" + x); target="./.config/" + x;});
pattern-map = pkgs: p: f: t:  pkgs.runCommand "map" {} "mkdir -p $out/${t}; ln -s ${f}/${p} $out/${t}/";
blind-map   = pkgs: pattern-map pkgs "*"; #link all files
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
{inherit devShells standalone;} // (

if standalone then
  { nixosConfigurations = mapAttrs (const os) config; } //
    ( mapAttrs (username: modules:
      home-manager.lib.homeManagerConfiguration ({
        inherit (home) pkgs;
        extraSpecialArgs = home.args;
        modules = modules ++ [{ home = {
          homeDirectory = "/home/${username}";
          inherit username;
          inherit (home) stateVersion;
        };}];
       })
    ) home.users )
else
  # TODO: see if there's a simpler way to do this
  # take config, override nixosConfig.<you>.modules
  { nixosConfigurations = mapAttrs (const os) (config // (with config; {
    # with self+HM
    "${hostname}" = config."${hostname}" // { modules = config."${hostname}".modules ++
      [ home-manager.nixosModules.home-manager {
        config = {
        #lib = home-manager.lib;
        home-manager.users = mapAttrs (n: imports: {inherit imports;}) home.users;
        home-manager.extraSpecialArgs = home.args;
        home-manager.useGlobalPkgs    = true;
        home-manager.useUserPackages  = true;
      }; } ];
    };
  }));
  }

);
#}
# basic setup {
population = users: groups: _: # _ is to make this a valid module (to be used in flake.nix)
  {
    fileSystems."/persist".neededForBoot = true;
    users.mutableUsers = false;
    users.users =
      listToAttrs (map (name:
        { inherit name; value = {
          isNormalUser = true;
          description = name;
          initialPassword = name;
          # Persisting user passwords
          passwordFile = "/persist/passwords/${name}";
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
    # applied wherever executable files shouldn't exist
    extra = [];# "remount" "noexec" ];
    all = import file (empties ["config" "lib" "pkgs"] // {modulesPath=./.;});
  in with all; {
    # LUKS, rename enc to main, retain any others
    boot.initrd.luks.devices = (removeAttrs all.boot.initrd.luks.devices ["enc"])
        // {main = all.boot.initrd.luks.devices.enc;};  # LUKS
    inherit swapDevices;  # swap
    fileSystems = mapAttrs (_: v: v
        # BTRFS mount options
        // (if v.fsType == "btrfs" then
             { options =
               # retain options, don't error on none
               (if hasAttr "options" v then v.options else [])
               ++ mount ++ extra; }  # add the modes
           else { } )
    ) ( fileSystems // {  # the imported FS' but with extra options
       "/persist" = fileSystems."/persist" // { neededForBoot = true; };
       "/var/log" = fileSystems."/var/log" // { neededForBoot = true; };
       #"/nix"     = fileSystems."/nix"     // { options       = mount;};
       ## TODO remove! Find a better solution...
       #"/home"    = fileSystems."/home"    // { options       = mount;};
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
# flatpak lambda {
flat = pkgs: space: let
  # this is an abuse of this function, but it gets the job done
  path = splitVersion space;
  name = strings.toLower (last path);
  in pkgs.writeShellScriptBin name "flatpak run ${space}";
#}
}
