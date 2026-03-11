{
  config,
  pkgs,
  ...
}:

{
  # Use kernel 6.18 until NVIDIA drivers support 6.19
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia-container-toolkit.enable = true;

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
