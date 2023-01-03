{
  inputs = {
    flake-utils.url = github:numtide/flake-utils;
    git-ignore-nix.url = github:IvanMalison/gitignore.nix/master;
  };
  outputs = { self, nixpkgs, flake-utils, git-ignore-nix }: # list out the dependencies
    let
      system = "x86_64-linux";
      npkgs = import nixpkgs {inherit system;};
      name = "yi";
      set  = "haskellPackages";
      bldr = "callCabal2nix";
      buildA = self: super: n: s: b: p: {
         ${n} = super.${s}.override (old: {
           overrides = super.lib.composeExtensions (old.overrides or (_: _: {}))
           (hself: hsuper: {
             ${n} = hself.${b} name (git-ignore-nix.lib.gitignoreSource p) { };
           });
         }); };
      buildB = self: super: n: s: b: p: {
        ${n} = with npkgs; stdenv.mkDerivation {
          name = n;
          src = p;
          nativeBuildInputs = deps npkgs;
          buildPhase = b;
        }; };

# sub-dependencies
deps = p: with p.${set}; [
  
];

      overlay = self: super: {}
// buildA self super name                 set               bldr            ./yi/yi-source/yi

// buildA self super "yi-core"            "haskellPackages" "callCabal2Nix" ./yi/yi-source/yi/yi-core
// buildA self super "yi-frontend-vty"    "haskellPackages" "callCabal2Nix" ./yi/yi-source/yi/yi-frontend-vty
// buildA self super "yi-frontend-pango"  "haskellPackages" "callCabal2Nix" ./yi/yi-source/yi/yi-frontend-pango
// buildA self super "yi-fuzzy-open"      "haskellPackages" "callCabal2Nix" ./yi/yi-source/yi/yi-fuzzy-open
// buildA self super "yi-ireader"         "haskellPackages" "callCabal2Nix" ./yi/yi-source/yi/yi-ireader
// buildA self super "yi-keymap-cua"      "haskellPackages" "callCabal2Nix" ./yi/yi-source/yi/yi-keymap-cua
// buildA self super "yi-keymap-emacs"    "haskellPackages" "callCabal2Nix" ./yi/yi-source/yi/yi-keymap-emacs
// buildA self super "yi-keymap-vim"      "haskellPackages" "callCabal2Nix" ./yi/yi-source/yi/yi-keymap-vim
// buildA self super "yi-language"        "haskellPackages" "callCabal2Nix" ./yi/yi-source/yi/yi-language
// buildA self super "yi-misc-modes"      "haskellPackages" "callCabal2Nix" ./yi/yi-source/yi/yi-misc-modes
// buildA self super "yi-mode-haskell"    "haskellPackages" "callCabal2Nix" ./yi/yi-source/yi/yi-mode-haskell
// buildA self super "yi-mode-javascript" "haskellPackages" "callCabal2Nix" ./yi/yi-source/yi/yi-mode-javascript
// buildA self super "yi-snippet"         "haskellPackages" "callCabal2Nix" ./yi/yi-source/yi/yi-snippet

// buildA self super "yi-rope"            "haskellPackages" "callCabal2Nix" ./yi/yi-source/yi/yi-rope
;
    in {inherit overlay;} // flake-utils.lib.eachDefaultSystem (system: # leverage flake-utils
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in {
        defaultPackage = pkgs.${name};
        devShell = pkgs.mkShell { # development environment
          packages = p: [ p.${name} ];
          buildInputs = deps pkgs;
        };
      });
}
