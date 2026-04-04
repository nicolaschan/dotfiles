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

  # Add Foxconn/MediaTek MT7927 bluetooth USB ID (0489:e13a) to btusb driver.
  # This device is not yet in the upstream kernel's btusb device table, so the
  # driver binds generically and doesn't load MediaTek firmware. This patch adds
  # it to the MT7925 section so btmtk firmware loading is triggered properly.
  boot.kernelPatches = [
    {
      name = "btusb-mediatek-mt7927";
      patch = ./btusb-mt7927.patch;
    }
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

  # LUKS-encrypted swap partition
  boot.initrd.luks.devices."luks-275ae343-f162-482d-a35d-8b1912a1b964".device =
    "/dev/disk/by-uuid/275ae343-f162-482d-a35d-8b1912a1b964";
  swapDevices = [
    { device = "/dev/mapper/luks-275ae343-f162-482d-a35d-8b1912a1b964"; }
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
