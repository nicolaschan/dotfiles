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

    # Systemd stage 1 initrd (the NixOS default since 25.11) brings up DHCP via
    # systemd-networkd, not the legacy scripted udhcpc. Match every wired NIC so
    # a lease is obtained before remote unlock, regardless of interface name.
    #
    # Deconfigure the NIC before switch-root. The upstream default (keep the
    # config) assumes stage 2 also runs systemd-networkd; we run NetworkManager,
    # which sees the already-configured interface as externally managed and
    # never starts DHCP or writes DNS.
    boot.initrd.network.flushBeforeStage2 = true;

    boot.initrd.systemd.network = {
      enable = true;
      networks."10-initrd-dhcp" = {
        matchConfig.Type = "ether";
        networkConfig.DHCP = "yes";
      };
    };

    boot.initrd.secrets = {
      "/etc/ssh/ssh-ca.pub" = "${caPubKeyFile}";
      "/etc/ssh/ssh_host_ed25519_key-cert.pub" = cfg.hostCertPath;
    };
  };
}
