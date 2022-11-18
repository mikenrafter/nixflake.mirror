# Yet Another Nix Setup

## Features

- Encrypted, [impermanent](https://nixos.wiki/wiki/Impermanence) btrfs root with
  a clever subvolume layout to maximize snapshot and wiping flexibility.
  - 3 backup slots for each impermanent subvolume (allowing recovery of
    accidental wipes within 3 boots of incident)
- Modular configuration. (see [Map of Setup](#map-of-setup))
- Explicit shame-list of unfree software via secondary imports.
- [Bundles](#bundles)

## Bundles (see [Bundles.nix](./bundles.nix))

  - What it solves: Having the need for a set of software, but needing your
    drive space, and potentially not needing this software again for months.
  - Why solve this: My prior nix config's store ends up about 20GB in size. For
    every installation or update, it would take an eternity, and use up a lot of
    drive space. I have some software (such as blender) that I can go months
    without touching. But I don't want to have to clutter my git tree with
    commenting & uncommenting blender over months and months.
  - What it is: Lists or "bundles" of software taking a stable and unstable
    package set, returning `nix develop` and `environment.systemPackages`/`hm`
    compatible sets.
  - How to use: You can toggle these bundles inside your config via comments
    ```nix
    # before
    environment.systemPackages = [ blender krita ];
    # after ( to disable: replace ++ with ; # ++ )
    environment.systemPackages = [] ++ bundles.art;
    ```
    To use bundles ephemerally (ensure they're placed in devShells) and run
    ```sh
    # from your flake's directory
    nix develop '.#art'
    # or, if you've used this shell recently
    nix develop '.#art' --offline
    ```

## Map of Setup

### - Build Targets -

```
nixosSystem.{hostname} = ( core packages not provided by hm )
{*users}.ac..Pack...   = ? if hm separate, then users hm configs will be here
devShells.{bundle}     = ephemeral shells with groups of packages
```

### [Utility.nix](./utility.nix)

```
utility.nix
| def ... = define all helper functions used
```

Having common functions stored centrally Keeps It Simple, Stupid.

### [Flake.nix](./flake.nix)

```
flake.nix
| inputs           = stable, unstable, home-manager, etc
| | frozen, free   = stable and unstable versions without unfree allowed
| | locked, unfree = stable and unstable versions with unfree allowed
| outputs          = makeAtHome() # see utility.nix and the options below
| | standalone     = use nixos hm module or separate installation?
| | home           = hm config and all users + their hm setup
| | config         = lib.nixosSystem wrapper
| | | volumes      = intelligently handle a generated hardware-configuration.nix
| | | population   = home.users -> generate users with the correct groups
| | | ./system     = import system.nix
| | | ./persist    = import persist/
| | | ./cachix     = import cachix.nix
| | hostname       = (self explanatory)
| | devShells      = convert bundles into devShells (see bundles.nix)
```

### [System.nix](./system.nix)

```
system.nix
| ./core.nix     = core software sets
| ./hardware.nix = hardware-related settings
| ./audio        = pw/pulse/etc setup
| ./video        = nvidia/intel/etc setup
| ./keyboard.nix = keyboard setup
| ...            = ... standard nixos setup
```

### [Home.nix](./home.nix)

```
home.nix
| ./bundles.nix = import bundles and select desired sets
| ...           = ... standard hm setup
```

### [Cachix/](./cachix/) & [Cachix.nix](./cachix.nix)

- simply `cachix use xyz` copied

### [Persist/](./persist/)

```
persist/        # uses impermanence
| ./cache.nix   = ephemeral caches
| ./persist.nix = ephemeral & uncategorized
| ./wipe.nix    = create btrfs snapshots & wipe old
```
