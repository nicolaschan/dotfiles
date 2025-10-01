{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
}
