{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  nix.gc = {
    automatic = true;
    persistent = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };
}
