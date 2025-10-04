{
  lib,
  stdenv,
  udevCheckHook,
}:
stdenv.mkDerivation {
  pname = "nuphy-udev-rules";
  version = "0-unstable-2025-10-03";
  
  src = [ ./nuphy.rules ];
  
  nativeBuildInputs = [
    udevCheckHook
  ];
  
  doInstallCheck = true;
  dontUnpack = true;
  
  installPhase = ''
    install -Dpm644 $src $out/lib/udev/rules.d/70-nuphy.rules
  '';
  
  meta = with lib; {
    description = "udev rules that give NixOS permission to communicate with Nuphy keyboards";
    platforms = platforms.linux;
    license = licenses.unfree;
    maintainers = [ ];
  };
}
