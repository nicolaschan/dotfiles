#!/usr/bin/env bash

nix-shell -p stow --run "stow -v --override='../.*' ."
nix run home-manager/master -- switch
