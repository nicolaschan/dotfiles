{
  config,
  lib,
  pkgs,
  ...
}:

{
  system.autoUpgrade = {
    enable = true;
    flake = "github:nicolaschan/dotfiles?dir=nixos";
    flags = [ "--refresh" ];
    dates = "15:00 UTC";
    allowReboot = false;
    randomizedDelaySec = "30min";
  };
}
