{
  pkgs,
  insanity,
  ghostty,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "nicolas";
  home.homeDirectory = "/home/nicolas";

  stylix = {
    enable = true;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/ayu-dark.yaml";
    fonts.monospace = {
      package = pkgs.cascadia-code;
      name = "Cascadia Code NF";
    };
    fonts.sansSerif = {
      package = pkgs.inter;
      name = "Inter";
    };
    opacity.terminal = 0.84;
    targets = {
      btop.enable = true;
      ghostty.enable = true;
      firefox.enable = true;
      firefox.profileNames = ["default"];
    };
  };

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
    asciiquarium
    asdf-vm
    # audacity
    b3sum
    bat
    blender
    chromium
    devenv
    # darktable
    direnv
    distrobox
    dive
    dogdns
    dotacat
    drill
    dust
    # easyeffects
    fastfetch
    fd
    fish
    floorp-bin
    fzf
    gcc # for neovim
    gimp
    git
    git-absorb
    gnome-tweaks
    gnome-terminal
    gnupg
    gocryptfs
    gping
    helix
    helvum
    httpie
    hyperfine
    inkscape
    insanity.packages.${system}.default
    iperf
    # jetbrains.idea-community
    just
    jq
    k9s
    killall
    kondo
    kubectl
    lm_sensors
    lsd
    mtr
    mosh
    musescore
    # nodejs # for github copilot on neovim
    # ollama-cuda
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
    signal-desktop
    sshfs
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
    vscode
    wasmtime
    wezterm
    wget
    wireguard-tools
    wl-clipboard
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
    EDITOR = "nvim";
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

  programs.btop.enable = true;
  programs.ghostty = {
    enable = true;
    # package = ghostty.packages.${pkgs.system}.default;
    settings = {
      window-width = 120;
      window-height = 30;
    };
  };
  programs.htop.enable = true;
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    clipboard.providers.wl-copy.enable = true;
    opts = {
      number = true;
      relativenumber = true;
      expandtab = true;
      tabstop = 8;
      softtabstop = 0;
      shiftwidth = 2;
      autoindent = true;
      termguicolors = true;
    };
    plugins = {
      lsp = {
        enable = true;
        servers = {
          ruff.enable = true;
          nil_ls.enable = true;
        };
      };
      treesitter = {
        enable = true;
        settings.indent.enable = true;
      };
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          {name = "nvim_lsp";} # ←  drives language-server items
          {name = "path";} #  file paths
          {name = "buffer";} #  words already in the file
        ];
      };
      lspkind.enable = true;
      luasnip.enable = true;
    };
  };
  programs.starship.enable = true;
  programs.zed-editor = {
    enable = true;
    extensions = ["gleam" "nix" "xml"];
    extraPackages = [pkgs.nil pkgs.nixd];
    userSettings = {
      telemetry = {
        metrics = false;
      };
      language_models = {
        ollama = {
          api_url = "http://monad:11434";
        };
      };

      features.edit_prediction_provider = "copilot";
      features.copilot = true;
      # assistant.enabled = false;
      vim_mode = true;
      autosave = "on_focus_change";
      format_on_save = "on";
      formatter = "language_server";
      buffer_font_features = {
        calt = true;
        liga = true;
        ss01 = true;
        ss02 = true;
        ss03 = true;
        ss19 = true;
        ss20 = true;
      };
      lsp = {
        rust-analyzer = {
          initialization_options = {
            cargo.buildScripts.rebuildOnSave = true;
            procMacro.enable = true;
            checkOnSave = true;
          };
        };
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
