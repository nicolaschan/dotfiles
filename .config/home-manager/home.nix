{
  config,
  pkgs,
  insanity,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "nicolas";
  home.homeDirectory = "/home/nicolas";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  fonts.fontconfig.enable = true;

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    alejandra
    anki
    asdf-vm
    asciiquarium
    audacity
    b3sum
    bat
    blender
    chromium
    devenv
    direnv
    distrobox
    dive
    docker-slim
    dogdns
    dotacat
    dust
    # easyeffects
    fastfetch
    fd
    fish
    fzf
    gcc # for neovim
    ghostty
    gimp
    git
    git-absorb
    gnome-tweaks
    gnome-terminal
    gnupg
    gping
    helix
    helvum
    httpie
    htop
    hyperfine
    inkscape
    insanity.packages.${system}.default
    iperf
    jetbrains.idea-community-bin
    just
    jq
    k9s
    killall
    kondo
    konsole
    kubectl
    lm_sensors
    lsd
    mtr
    microsoft-edge
    mosh
    musescore
    neovim
    nil
    # nodejs # for github copilot on neovim
    nushell
    ollama
    pass
    pinentry-curses
    podman-tui
    podman-compose
    prismlauncher
    pv
    qrencode
    restic
    ripgrep
    ripgrep-all
    screen
    shellcheck
    sshfs
    starship
    stow
    speedtest-cli
    tealdeer
    texlivePackages.latex-fonts
    thunderbolt
    tmux
    tokei
    traceroute
    tree
    unzip
    vim
    vscode
    wasmtime
    wezterm
    wget
    wireguard-tools
    wl-clipboard
    zed-editor
    zip
    zoxide

    # Fonts
    cascadia-code
    inter
    noto-fonts-cjk-sans

    # breaks emojis in konsole
    noto-fonts
    noto-fonts-emoji

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/nicolas/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "nvim";
  };

  nixpkgs.config.allowUnfree = true;

  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        settings = {
          "accessibility.typeaheadfind.enablesound" = false;
        };
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
