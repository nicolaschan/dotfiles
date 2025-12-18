{
  lib,
  config,
  ...
}: let
  cfg = config.services.wakeOnLan;
in {
  options.services.wakeOnLan = {
    enable = lib.mkEnableOption "Wake-on-LAN support";
    interface = lib.mkOption {
      type = lib.types.str;
      description = "Network interface to enable Wake-on-LAN on";
      example = "enp5s0";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.interfaces.${cfg.interface}.wakeOnLan = {
      enable = true;
      policy = ["phy" "unicast" "magic"];
    };
  };
}
