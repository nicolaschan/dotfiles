{
  hostCertPub,
  caPub,
}: {
  services.openssh = {
    enable = true;
    extraConfig = ''
      HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
      TrustedUserCAKeys /etc/ssh/ssh-ca.pub
    '';
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      Macs = [
        "hmac-sha2-512-etm@openssh.com"
        "hmac-sha2-256-etm@openssh.com"
        "umac-128-etm@openssh.com"
        "hmac-sha2-512" # For compatibility with passforios
      ];
    };
  };

  environment.etc."ssh/ssh_host_ed25519_key-cert.pub".text = hostCertPub;
  environment.etc."ssh/ssh-ca.pub".text = caPub;
  environment.etc."ssh/ssh_known_hosts".text = "@cert-authority * ${caPub}";
}
