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

  # Reset failure state before upgrade to avoid getting stuck in a failure loop
  systemd.services.nixos-upgrade-reset-failures = {
    description = "Reset failed units before NixOS upgrade";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.systemd}/bin/systemctl reset-failed restic-backups-scarifBackup.service nixos-upgrade.service || true'";
    };
  };

  # Retry once after 5 minutes on failure, notify only after both attempts fail
  systemd.services.nixos-upgrade = {
    wants = [ "nixos-upgrade-reset-failures.service" ];
    after = [ "nixos-upgrade-reset-failures.service" ];
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5min";
    };
    unitConfig = {
      StartLimitIntervalSec = "15min";
      StartLimitBurst = 2;
    };
    onFailure = [ "nixos-upgrade-notify-failure.service" ];
  };

  # Ensure restic backup failures don't block nixos-upgrade
  systemd.services.restic-backups-scarifBackup.serviceConfig.SuccessExitStatus = lib.mkDefault "0 4";

  systemd.services.nixos-upgrade-notify-failure = {
    description = "Notify on NixOS upgrade failure";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.curl}/bin/curl -d 'NixOS upgrade failed on ${config.networking.hostName}' ntfy.sh/nicolaschan_alerts";
    };
  };
}
