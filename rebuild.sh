#!/bin/sh
doas nixos-rebuild boot --flake "$HOME/nixflake/.#" &&
nix build . && ./result/activate
