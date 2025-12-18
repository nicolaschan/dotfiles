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

  # Notify on upgrade failure
  systemd.services.nixos-upgrade = {
    onFailure = [ "nixos-upgrade-notify-failure.service" ];
  };

  systemd.services.nixos-upgrade-notify-failure = {
    description = "Notify on NixOS upgrade failure";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.curl}/bin/curl -d 'NixOS upgrade failed on ${config.networking.hostName}' ntfy.sh/nicolaschan_alerts";
    };
  };
}
