{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # required for docker.enableNvdia
  };

  hardware.nvidia-container-toolkit.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.finegrained = false;
    open = false;
  };

  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelModules = [
    "nvidia"
    "i2c-dev"
    "i2c-i801"
  ];
  hardware.i2c.enable = true;
  # services.hardware.openrgb.enable = true;

  hardware.nvidia.nvidiaSettings = true;
  # hardware.nvidia.nvidiaPersistenced = true;

  services.xserver.videoDrivers = [ "nvidia" ];
}
