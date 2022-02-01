{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  # direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Fish
  programs.fish.enable = true;
  programs.fish.interactiveShellInit = ''
    set fish_greeting
    direnv hook fish | source
    alias ls=lsd
  '';

  # Git
  programs.git.enable = true;
  programs.git.userName = "Nicolas Chan";
  programs.git.userEmail = "nicolas@nicolaschan.com";

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "nicolas";
  home.homeDirectory = "/home/nicolas";

  home.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
  };

  home.packages = [
    pkgs.cascadia-code
    pkgs.chromium
    pkgs.devilspie2
    pkgs.dust
    pkgs.fd
    pkgs.firefox
    pkgs.fluxcd
    pkgs.fzf
    pkgs.gimp
    pkgs.git
    pkgs.gnome.gnome-tweaks
    pkgs.gnomeExtensions.transparent-topbar
    pkgs.gnomeExtensions.transparent-top-bar-adjustable-transparency
    pkgs.gnupg
    pkgs.htop
    pkgs.httpie
    pkgs.jq
    pkgs.killall
    pkgs.konsole
    pkgs.kubectl
    pkgs.ldns
    pkgs.lens
    pkgs.libvirt
    pkgs.lsd
    pkgs.multimc
    pkgs.neofetch
    pkgs.nerdfonts
    pkgs.nmap
    pkgs.tdesktop
    pkgs.pass
    pkgs.pavucontrol
    pkgs.pciutils
    pkgs.pdsh
    pkgs.pinentry
    pkgs.qemu_kvm
    pkgs.restic
    pkgs.ripgrep
    pkgs.screen
    pkgs.sops
    pkgs.terminator
    pkgs.torsocks
    pkgs.victor-mono
    pkgs.vim
    pkgs.virtmanager
    pkgs.vscode
    pkgs.zoxide
  ];

  services.syncthing.enable = true;
  services.gpg-agent.enable = true;

  services.gpg-agent.extraConfig = ''
    pinentry-program ${pkgs.pinentry}/bin/pinentry
  '';

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";
}
