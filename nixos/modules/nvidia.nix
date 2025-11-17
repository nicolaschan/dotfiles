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
  hardware.nvidia-container-toolkit.mount-nvidia-executables = true;

  environment.systemPackages = with pkgs; [
    nvidia-container-toolkit
  ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
  };

  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.kernelModules = [
    "nvidia"
    "i2c-dev"
    "i2c-i801"
  ];
  hardware.i2c.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
}
