# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}:
let
  unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.supportedFilesystems = [ "bcachefs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "usbhid.mousepoll=1" ];
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
    127.0.0.1 lobste.rs
  '';

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.hyprland.enable = true;

  services.udev.extraRules = ''
    # Disable mouse debounce
    ACTION=="add|change", KERNEL=="event[0-9]*", SUBSYSTEM=="input", ENV{ID_INPUT_MOUSE}=="1", ENV{LIBINPUT_ATTR_DEBOUNCE_DELAY}="0"
  '';
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Disable Debouncing for All Mice]
    MatchUdevType=mouse
    AttrEventCode=-BTN_LEFT
    AttrEventCode=-BTN_RIGHT
    AttrEventCode=-BTN_MIDDLE
    AttrDebouncePreset=disabled
  '';

  services.libinput = {
    mouse = {
      accelProfile = "flat";
      accelSpeed = "0";
      clickMethod = "none";
      naturalScrolling = false;
      tapping = false;
      tappingButtonMap = "lrm";
    };
  };

  # Enable kanata for keyboard remapping
  hardware.uinput.enable = true;
  services.kanata = {
    enable = false;
    keyboards.default = {
      extraDefCfg = "process-unmapped-keys yes";
      config = ''
        (defsrc caps)
        (deflayermap (default-layer)
          caps (tap-hold-press 0 200 esc lctl))
      '';
    };
  };

  # Add wooting udev rules
  services.udev.packages = [ pkgs.wooting-udev-rules ];

  # Enable sound with pipewire.
  # services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.sudo.extraRules = [
    {
      users = [ "nicolas" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  services.libinput.touchpad.disableWhileTyping = false;

  # Enable fingerprint reader support
  services.fprintd = {
    enable = true;
    tod.enable = true;
    tod.driver = pkgs.libfprint-2-tod1-goodix;
  };
  nixpkgs.overlays = [
    (final: prev: {
      libfprint-tod = prev.libfprint-tod.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or [ ]) ++ [
          prev.cmake
          prev.nss
          prev.pkg-config
        ];
      });
    })
  ];

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
      backupPrepareCommand = "restic unlock";
    };
  };

  systemd.services."restic-backups-scarifBackup" = {
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5min";
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nicolas = {
    isNormalUser = true;
    description = "Nicolas Chan";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "uinput"
    ];
    shell = pkgs.fish;
    packages = with pkgs; [
      vscode
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    cascadia-code
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server
  };

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

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
