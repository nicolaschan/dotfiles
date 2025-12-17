{
  config,
  pkgs,
  ...
}:

{
  nixpkgs.overlays = [
    (final: prev: {
      openrgb = prev.openrgb.overrideAttrs (old: rec {
        version = "candidate_1.0rc2";
        src = old.src.override {
          rev = "release_${version}";
          hash = "sha256-vdIA9i1ewcrfX5U7FkcRR+ISdH5uRi9fz9YU5IkPKJQ=";
        };
        patches = [];
        postPatch = ''
          patchShebangs scripts/build-udev-rules.sh
          substituteInPlace OpenRGB.pro \
            --replace-quiet "systemd_service" ""
        '';
        postInstall = ''
          substituteInPlace $out/lib/udev/rules.d/60-openrgb.rules \
            --replace-quiet "/usr/bin/env" "${prev.coreutils}/bin/env"
        '';
        installTargets = [ ];
      });
    })
  ];
}
