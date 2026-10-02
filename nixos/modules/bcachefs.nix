{
  fileSystems."/".options = [ "discard" ];

  services.bcachefs.autoScrub.enable = true;
}
