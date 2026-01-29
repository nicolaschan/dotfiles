{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.dynamic-wallpaper;
in {
  options.modules.dynamic-wallpaper = {
    enable = mkEnableOption "dynamic wallpaper switching based on sunrise/sunset";

    latitude = mkOption {
      type = types.float;
      default = 37.77;
      description = "Latitude for sunrise/sunset calculation";
    };

    longitude = mkOption {
      type = types.float;
      default = -122.42;
      description = "Longitude for sunrise/sunset calculation";
    };

    dayWallpaper = mkOption {
      type = types.str;
      description = "Path to the daytime wallpaper";
      example = "~/wallpapers/day.png";
    };

    nightWallpaper = mkOption {
      type = types.str;
      description = "Path to the nighttime wallpaper";
      example = "~/wallpapers/night.png";
    };
  };

  config = mkIf cfg.enable {
    services.darkman = {
      enable = true;
      settings = {
        lat = cfg.latitude;
        lng = cfg.longitude;
        usegeoclue = false;
      };
      darkModeScripts = {
        wallpaper = ''
          ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/background/picture-uri "'file://${cfg.nightWallpaper}'"
          ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/background/picture-uri-dark "'file://${cfg.nightWallpaper}'"
        '';
      };
      lightModeScripts = {
        wallpaper = ''
          ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/background/picture-uri "'file://${cfg.dayWallpaper}'"
          ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/background/picture-uri-dark "'file://${cfg.dayWallpaper}'"
        '';
      };
    };
  };
}
