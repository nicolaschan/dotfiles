{
  pkgs,
  ...
}:

{
  services.udev.packages = [ pkgs.openrgb ];

  systemd.services.openrgb-off = {
    description = "Turn off RGB lighting";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "nicolas";
      ExecStart = "${pkgs.openrgb}/bin/openrgb --device 0 --mode off";
    };
  };

  environment.systemPackages = [ pkgs.openrgb ];
}
