# Remote disk decryption via SSH during initrd
# See initrd-ssh.md for setup and usage instructions.
{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.initrd-ssh;
  caPubKeyFile = pkgs.writeText "ssh-ca.pub" cfg.caPubKey;
in
{
  options.services.initrd-ssh = {
    enable = mkEnableOption "SSH server in initrd for remote disk decryption";

    port = mkOption {
      type = types.port;
      default = 22;
      description = "Port for the initrd SSH server";
    };

    hostKeyPath = mkOption {
      type = types.path;
      default = "/etc/secrets/initrd/ssh_host_ed25519_key";
      description = "Path to the initrd SSH host key";
    };

    hostCertPath = mkOption {
      type = types.path;
      default = "/etc/secrets/initrd/ssh_host_ed25519_key-cert.pub";
      description = "Path to the initrd SSH host certificate (signed by CA)";
    };

    caPubKey = mkOption {
      type = types.str;
      description = "SSH CA public key content for user authentication";
    };
  };

  config = mkIf cfg.enable {
    boot.initrd.network = {
      enable = true;
      udhcpc.enable = true;
      ssh = {
        enable = true;
        port = cfg.port;
        hostKeys = [ cfg.hostKeyPath ];
        # CA key is not actually used for auth but we need to make this array nonempty
        authorizedKeyFiles = [ caPubKeyFile ];
        extraConfig = ''
          TrustedUserCAKeys /etc/ssh/ssh-ca.pub
          HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
        '';
      };
    };

    boot.initrd.secrets = {
      "/etc/ssh/ssh-ca.pub" = "${caPubKeyFile}";
      "/etc/ssh/ssh_host_ed25519_key-cert.pub" = cfg.hostCertPath;
    };
  };
}
