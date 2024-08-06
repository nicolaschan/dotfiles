#!/usr/bin/env bash

git pull origin master
./install-nixos.sh
pushd .config/home-manager
nix flake update
git add .
git commit -m "Update flake.nix"
git push origin master
popd
