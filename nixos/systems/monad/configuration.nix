{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking.hostName = "monad"; # Define your hostname.
  networking.hostId = "4dc56713";

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  swapDevices = [
    {
      device = "/swapfile";
      size = 64 * 1024; # 64 GB
    }
  ];

  # T7 SSD
  fileSystems."/mnt/ssd-t7-2tb" = {
    device = "/dev/disk/by-uuid/6548f0d5-d3d5-4885-aa27-634b757b0b46";
    fsType = "btrfs";
    options = [
      "nofail"
      "x-systemd.automount"
    ];
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Disable suspend targets
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.git = {
    isNormalUser = true;
    uid = 1002;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPlM2ilPhTvNX0DoYiU+o3+HRsU3dtHGcZ0igWf3cqR4 nicolas@xn--h98h"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtEyrE++I+HzN3nrCVqEWdyVxPikPJ6XzoFxnLxk4ML nicolas@monad"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/onxpCkv8FBts5mNzNBO921r20i3ZBGbrfKgUnET81 nicolas@iphone_pass"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cudatoolkit
    # cudaPackages.fabricmanager
    libnvidia-container
    linuxPackages.nvidia_x11
    nvtopPackages.nvidia
    runc
  ];

  environment.sessionVariables = {
    LD_LIBRARY_PATH = "/run/opengl-driver/lib:/run/opengl-driver-32/lib";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  boot.kernelPackages = pkgs.linuxPackages_6_12;

  hardware.bluetooth.powerOnBoot = true;

  boot.supportedFilesystems = [
    "zfs"
  ];
  boot.zfs.extraPools = ["scarif"];
  services.zfs.autoScrub.enable = true;

  # List services that you want to enable:
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = "--disable=traefik"; # --disable=metrics-server"; # --flannel-backend=vxlan";
  };

  systemd.services.k3s = {
    path = [
      "/run/current-system/sw" # for nvidia-container-cli
    ];
  };

  services.restic.backups = {
    kubeT7 = {
      passwordFile = "/home/nicolas/restic-passwords/monad-kube-t7";
      repository = "/scarif/backups/monad-kube-t7-restic";
      paths = ["/mnt/ssd-t7-2tb/kubernetes-storage"];
      extraBackupArgs = ["--exclude-caches"];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 2"
      ];
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
    };
    kubernetesStorage = {
      passwordFile = "/home/nicolas/restic-passwords/monad-kubernetes-storage";
      repository = "/scarif/backups/monad-kubernetes-storage-restic";
      paths = ["/var/lib/rancher/k3s"];
      extraBackupArgs = ["--exclude-caches"];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 2"
      ];
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
