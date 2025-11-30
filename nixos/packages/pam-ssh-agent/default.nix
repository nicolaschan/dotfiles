{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  pam,
  openssl,
}:
rustPlatform.buildRustPackage rec {
  pname = "pam-ssh-agent";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "nicolaschan";
    repo = "pam-ssh-agent";
    rev = "4c46a43dcd5c1ecbbe5b929895dea11d32f424b6";
    hash = "sha256-9Nta4FhBztcUU7DAS881lw/u/odT/MY5F76UfAVrj+Q=";
  };

  cargoHash = "sha256-eFKUKbraKvCuZiCCT0FURNqlJd8UPGr/+gO5hCfNj90=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    pam
    openssl
  ];

  # For patching tests/data/test.sh for to fix the tests
  postPatch = ''
    patchShebangs tests
  '';

  meta = with lib; {
    description = "A PAM module that authenticates using the ssh-agent";
    longDescription = ''
      A PAM authentication module that determines the identity of a user based on a
      signature request and response sent via the ssh-agent protocol to a potentially
      remote ssh-agent. This is useful for granting escalated privileges on a remote
      system accessed using SSH with agent forwarding enabled.
    '';
    homepage = "https://github.com/nresare/pam-ssh-agent";
    license = with licenses; [asl20 mit];
    maintainers = [];
    platforms = platforms.linux;
  };
}
