{...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.extraModprobeConfig = ''
    options usbhid mousepoll=1
  '';

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/ae7e7c92-7bf6-4514-b0e4-3c7cd4d840e3";
      randomEncryption.enable = true;
    }
  ];

  networking.hostName = "xps"; # Define your hostname.

  # Block distracting websites
  networking.extraHosts = ''
    # 127.0.0.1 news.ycombinator.com
  '';

  services.restic.backups = {
    scarifBackup = {
      passwordFile = "/home/nicolas/.config/restic/password";
      repository = "sftp:git@monad:/scarif/backups/xps-restic";
      user = "nicolas";
      paths = [
        "/home/nicolas"
      ];
      extraBackupArgs = [
        "--exclude-caches"
        "--exclude=.cache"
        "--exclude=.local/share/containers"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 6"
      ];
      timerConfig = {
        OnCalendar = "20:00";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
      # backupPrepareCommand = "restic unlock -r sftp:git@monad:/scarif/backups/xps-restic --password-file /home/nicolas/.config/restic/password";
    };
  };

  systemd.services."restic-backups-scarifBackup" = {
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5min";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
