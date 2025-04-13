# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.configurationLimit = 10;

  networking.hostName = "monad"; # Define your hostname.
  networking.hostId = "4dc56713";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

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
    options = ["nofail" "x-systemd.automount"];
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };
  console.keyMap = "dvorak";

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "dvorak";
  };
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services.hardware.bolt.enable = true;

  security.sudo.extraRules = [
    {
      users = ["nicolas"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true; # required for docker.enableNvdia
  };

  nixpkgs.config.allowUnfree = true;

  hardware.nvidia-container-toolkit.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.finegrained = false;
    open = false;
  };

  boot.blacklistedKernelModules = ["nouveau"];
  boot.kernelModules = ["nvidia"];

  hardware.nvidia.nvidiaSettings = true;
  # hardware.nvidia.nvidiaPersistenced = true;

  services.xserver.videoDrivers = ["nvidia"];

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nicolas = {
    isNormalUser = true;
    linger = true;
    uid = 1000;
    extraGroups = ["wheel" "docker"]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    packages = with pkgs; [
      tree
    ];
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIO4fOS9m+QoMnYVO9r/8zQn5bGaaJt4ILvQI2VW83a05AAAABHNzaDo= nicolas@xps"
      "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBDgWXcT8lPSDFOBCSGYwaUzal+1B0rPPuR5s9f4rpnY53KnIc8KnvonV4/0OrSLiAPndTyq8vMN5mv3x6zNbnpgAAAALdGVybWl1cy5jb20= nicolas@terminus-iphone"
    ];
  };

  users.users.git = {
    isNormalUser = true;
    uid = 1002;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPlM2ilPhTvNX0DoYiU+o3+HRsU3dtHGcZ0igWf3cqR4 nicolas@xn--h98h"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAtEyrE++I+HzN3nrCVqEWdyVxPikPJ6XzoFxnLxk4ML nicolas@monad"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO/onxpCkv8FBts5mNzNBO921r20i3ZBGbrfKgUnET81 nicolas@iphone_pass"
    ];
  };

  users.users.aditya = {
    isNormalUser = true;
    linger = true;
    uid = 1001;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILnZy5ZNXuks76CqlE+Kd+NKEPM9Fwtr0jPFtuERBopP aditya@sf.intranet.lol"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cudatoolkit
    # cudaPackages.fabricmanager
    docker
    git
    libnvidia-container
    linuxPackages.nvidia_x11
    nvidia-container-toolkit
    nvtopPackages.nvidia
    runc
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
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

  programs.fish.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.package = pkgs.nix-ld-rs;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    glib
    # Add any missing dynamic libraries for unpackaged programs here
  ];

  virtualisation = {
    containers = {
      enable = true;
    };
    podman = {
      enable = true;
      # dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    docker = {
      enable = true;
      enableNvidia = true;
    };
    containerd = {
      enable = true;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_6_12;

  boot.kernelParams = [
    "pcie_aspm=off" # Disable Active State Power Management
    "pcie_port_pm=off" # Disable PCIe port power management
    "acpi_osi=\"!Windows 2020\"" # Use Linux-specific ACPI implementation
  ];
  boot.extraModprobeConfig = ''
    options usbcore autosuspend=-1
    options xhci_hcd quirks=0x80
  '';
  boot.kernel.sysctl = {
    "vm.dirty_ratio" = 6;
    "vm.dirty_background_ratio" = 3;
  };
  hardware.bluetooth.powerOnBoot = true;

  boot.supportedFilesystems = ["zfs"];
  boot.zfs.extraPools = ["scarif"];
  services.zfs.autoScrub.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
        "hmac-sha2-512" # For compatibility with passforios
      ];
    };
  };

  # Enable k3s
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = "--disable=traefik --flannel-backend=vxlan";
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
      pruneOpts = ["--keep-daily 7" "--keep-weekly 2"];
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
      pruneOpts = ["--keep-daily 7" "--keep-weekly 2"];
      timerConfig = {
        OnCalendar = "daily";
        RandomizedDelaySec = "1h";
        Persistent = true;
      };
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

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

  system.autoUpgrade.enable = true;

  nix. extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.gc = {
    automatic = true;
    persistent = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
