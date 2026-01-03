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

  # Retry once after 5 minutes on failure, notify only after both attempts fail
  systemd.services.nixos-upgrade = {
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5min";
    };
    unitConfig = {
      StartLimitIntervalSec = "15min";
      StartLimitBurst = 2;
    };
    onFailure = [ "nixos-upgrade-notify-failure.service" ];
    # Reset failure state of dependencies to avoid getting stuck in a failure loop
    preStart = ''
      ${pkgs.systemd}/bin/systemctl reset-failed restic-backups-scarifBackup.service || true
      ${pkgs.systemd}/bin/systemctl reset-failed nixos-upgrade.service || true
    '';
  };

  systemd.services.nixos-upgrade-notify-failure = {
    description = "Notify on NixOS upgrade failure";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.curl}/bin/curl -d 'NixOS upgrade failed on ${config.networking.hostName}' ntfy.sh/nicolaschan_alerts";
    };
  };
}
