{
  pkgs,
  ...
}:

{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.desktopManager.cosmic.enable = true;

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

  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    cascadia-code
  ];

  security.rtkit.enable = true;
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

    # extraConfig.pipewire = {
    #   "context.properties" = {
    #    "default.clock.rate" = 48000;
    #    "default.clock.quantum" = 1024;
    #    "default.clock.min-quantum" = 32;
    #    "default.clock.max-quantum" = 8192;
    #   };
    # };
  };

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

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server
  };
}
