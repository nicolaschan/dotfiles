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
    owner = "nresare";
    repo = "pam-ssh-agent";
    rev = "6158b51161c50774b195e0ea4debbf3ac9dbadf2";
    hash = "sha256-x2//dLpfppGRXtxJFQqWoCx64WJkCMM8Tisei731YtU=";
  };

  cargoHash = "sha256-eFKUKbraKvCuZiCCT0FURNqlJd8UPGr/+gO5hCfNj90=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    pam
    openssl
  ];

  checkFlags = [
    "--skip=cmd::tests::test_run"
    "--skip=filter::tests::test_read_public_keys"
  ];

  # The build produces libpam_ssh_agent.so
  # We need to install it to the correct location
  postInstall = ''
    # Create the directory for PAM modules
    mkdir -p $out/lib/security

    # Move the library to the PAM modules directory
    mv $out/lib/libpam_ssh_agent.so $out/lib/security/pam_ssh_agent.so
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
