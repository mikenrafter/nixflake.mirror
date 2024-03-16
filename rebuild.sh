#!/usr/bin/env bash 
set -e
pushd ~/nixflake/
git diff -U0 **
echo "NixOS Rebuilding..."
nixos-rebuild build --flake '.#' $@ |& tee -a nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
rm result
nix build . $@ |& tee -a nixos-switch.log || (cat nixos-switch.log | grep --color error && false)
echo "HomeManager Activating..."
./result/activate
echo "NixOS Activating..."
doas nixos-rebuild switch --flake '.#' $@
gen=$(nixos-rebuild list-generations | grep current)
# TODO, find a better solution here. This does not work when messing with things locally. Having something to roll back to in the nix config makes sense, but discipline plus current workflow overrule this.
# git commit -am "$gen"
popd
