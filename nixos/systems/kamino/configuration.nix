{
  lib,
  pkgs-unstable,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.extraModprobeConfig = ''
    options usbhid mousepoll=1
  '';

  # Network drivers needed for initrd SSH (find yours with: lspci -k | grep -A3 -i ethernet)
  boot.initrd.availableKernelModules = [
    "r8169"      # Realtek Gigabit Ethernet
    "igc"        # Intel 2.5G Ethernet (common on newer boards)
    "atlantic"   # Aquantia/Marvell AQtion NICs
  ];

  # Enable initrd SSH for remote disk decryption
  services.initrd-ssh.enable = true;

  nixpkgs.config.allowUnfree = true;
  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama-cuda;
    acceleration = "cuda";
    host = "0.0.0.0";
  };

  networking.hostName = "kamino";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
