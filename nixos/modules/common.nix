{
  lib,
  pkgs,
  inputs,
  ...
}: {
  boot.supportedFilesystems = ["bcachefs"];
  boot.kernelPackages = lib.mkOverride 1100 pkgs.linuxPackages_latest;
  boot.kernelParams = ["usbhid.mousepoll=1"];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.configurationLimit = 10;

  # Programs
  programs.fish.enable = true;
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    pam_u2f
    pam_ssh_agent_auth
  ];

  # nix-ld
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
    libraries = with pkgs; [
      # Add any missing dynamic libraries for unpackaged programs here
      stdenv.cc.cc
      zlib
      glib
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      libpinyin
      rime
    ];
  };

  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };
  console.keyMap = "dvorak";

  # Enable rssh to use ssh agent for sudo
  # If not available, use physical yubikey
  # If not available, use fingerprint
  # Fallback to password
  services.pcscd.enable = true;
  security.pam.rssh.enable = true;
  security.pam.u2f.settings.cue = true;
  security.pam.services = {
    sudo = {
      u2fAuth = true;
      rssh = true;
      fprintAuth = true;
      rules.auth = let
        pamSshAgent = pkgs.callPackage ../packages/pam-ssh-agent {};
      in {
        pamSshAgent = {
          order = 100;
          control = "sufficient";
          modulePath = "${pamSshAgent}/lib/libpam_ssh_agent.so";
          settings.file = "/etc/ssh/authorized_keys.d/%u";
          settings.ca_keys_file = "/etc/ssh/ssh-ca.pub";
        };
      };
    };
  };

  # Add wooting udev rules
  services.udev.packages = [
    pkgs.wooting-udev-rules
    (pkgs.callPackage ../packages/nuphy-udev-rules {})
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "dvorak";
  };

  # Thunderbolt support
  services.hardware.bolt.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

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
      # enableNvidia = true;
    };
    containerd = {
      enable = true;
    };
  };

  # User configuration
  users.users.nicolas = {
    isNormalUser = true;
    linger = true;
    uid = 1000;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "input"
      "uinput"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    packages = with pkgs; [
      tree
    ];
    openssh.authorizedKeys.keys = [
      "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBDgWXcT8lPSDFOBCSGYwaUzal+1B0rPPuR5s9f4rpnY53KnIc8KnvonV4/0OrSLiAPndTyq8vMN5mv3x6zNbnpgAAAALdGVybWl1cy5jb20= nicolas@terminus-iphone"
    ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  system.autoUpgrade.enable = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nix.gc = {
    automatic = true;
    persistent = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
}
