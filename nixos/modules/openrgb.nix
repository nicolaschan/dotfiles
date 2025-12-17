{
  config,
  pkgs,
  ...
}:

{
  services.hardware.openrgb = {
    enable = true;
    # openrgb package overlay defined in overlays.nix
    package = pkgs.openrgb;
    startupProfile = "off";
  };

  # Copy the profile to /var/lib/OpenRGB/
  systemd.tmpfiles.rules = [
    "C /var/lib/OpenRGB/off.orp 0644 root root - ${../resources/openrgb/off.orp}"
  ];

  environment.systemPackages = [ pkgs.openrgb ];
}
