{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.libinput.enable = true;
  services.libinput.touchpad.disableWhileTyping = false;

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
}
