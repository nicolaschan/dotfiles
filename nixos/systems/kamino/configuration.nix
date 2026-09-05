{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "610.57.04";
    sha256_64bit = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
    sha256_aarch64 = "sha256-QCefrMBCmpOwuOyXv1k5Gj0iB2CYlPgnG3JToUw/j54=";
    openSha256 = "sha256-rQHOOOY4KL92Ww3KDwh+j4eGU7oNAH8LutZC5wmFnPo=";
    settingsSha256 = "sha256-ZEMo8I8Zc2Tq6RVDNYpAH+f094dUaZiBqO+5f6lIjRI=";
    persistencedSha256 = "sha256-aXmD2VY1RLlgAnlHhOUMWzvMyhI6JTClcFLm4imF/mA=";
  };

  boot.extraModprobeConfig = ''
    options usbhid mousepoll=1
  '';

  boot.blacklistedKernelModules = [ "btusb" ];

  # Network drivers needed for initrd SSH (find yours with: lspci -k | grep -A3 -i ethernet)
  boot.initrd.availableKernelModules = [
    "r8169" # Realtek Gigabit Ethernet
    "igc" # Intel 2.5G Ethernet (common on newer boards)
    "atlantic" # Aquantia/Marvell AQtion NICs
  ];

  # Enable initrd SSH for remote disk decryption
  services.initrd-ssh.enable = true;

  nixpkgs.config.allowUnfree = true;
  services.ollama = {
    enable = true;
    package = pkgs-unstable.ollama-cuda;
    # package = (pkgs-unstable.ollama.override {acceleration = "cuda";}).overrideAttrs (old: rec {
    #   version = "0.32.13";
    #   src = pkgs-unstable.fetchFromGitHub {
    #     owner = "ollama";
    #     repo = "ollama";
    #     rev = "v${version}";
    #     hash = "sha256-KSvw7LsvpUVeSm9BKJ4wIp/fWGHjMp8bOTMUpFJCDmw=";
    #   };
    #   vendorHash = "sha256-HMwoaFBMbpoy8f0I+O+i7kIa9BslLu3FcVWeaIOkpvs=";
    # });
    host = "0.0.0.0";
    environmentVariables = {
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
    };
  };

  # LUKS-encrypted swap partition
  boot.initrd.luks.devices."luks-275ae343-f162-482d-a35d-8b1912a1b964".device = "/dev/disk/by-uuid/275ae343-f162-482d-a35d-8b1912a1b964";
  swapDevices = [
    {device = "/dev/mapper/luks-275ae343-f162-482d-a35d-8b1912a1b964";}
  ];

  networking.hostName = "kamino";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
