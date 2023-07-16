#!/bin/sh
doas nixos-rebuild switch --flake "$HOME/nixflake/.#" &&
nix build . && ./result/activate
