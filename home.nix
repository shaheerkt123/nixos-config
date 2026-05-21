{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home.username = "shaheer";
  home.homeDirectory = "/home/shaheer";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
      theme = "robbyrussell";
    };
    initContent = ''
      bindkey '^f' vi-forward-word
    '';
  };

  programs.git = {
    enable = true;
    userName = "shaheer";
    userEmail = "shaheerkt1234@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      commit.gpgSign = true;
      gpg.format = "ssh";
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
    };
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPGyojGoNze8VGrR/JqwZO7CJxoJt7KpTgYfy8ysAJ82";
      signByDefault = true;
    };
  };

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-qt;
    defaultCacheTtl = 3600;
    maxCacheTtl = 86400;
    enableSshSupport = false;
  };

  services.ssh-agent.enable = false;
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        identityAgent = "~/.bitwarden-ssh-agent.sock";
      };
    };
  };

  services.kdeconnect.enable = true;
  services.kdeconnect.indicator = true; # Enforces the system tray icon

  home.packages = with pkgs; [
    inputs.kickstart-nix-nvim.packages.${pkgs.system}.default
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.prismlauncher-cracked.packages.${pkgs.system}.default

    # Apps
    mpv
    thunar
    discord
    vscode
    thunderbird
    zettlr
    bitwarden-desktop
    loupe
    baobab

    # CLI Tools
    yazi
    lf
    fzf
    htop
    tree
    playerctl
    networkmanagerapplet
    gemini-cli

    # Development
    cargo
    rustc
    gcc
    gnumake
    go
    gopls
    python3
    yarn
    jdk25

    # Utils
    xwayland-satellite
    kdePackages.partitionmanager
  ];

  programs.alacritty.enable = true;

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "niri.service";
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=12";
        prompt = "'❯ '";
        terminal = "${pkgs.alacritty}/bin/alacritty";
        width = 30;
        horizontal-pad = 20;
        vertical-pad = 20;
        inner-pad = 10;
        line-height = 25;
      };
      colors = {
        background = "${config.lib.stylix.colors.base00}e6"; # 90% opacity
        text = "${config.lib.stylix.colors.base05}ff";
        match = "${config.lib.stylix.colors.base0D}ff";
        selection = "${config.lib.stylix.colors.base02}ff";
        selection-text = "${config.lib.stylix.colors.base05}ff";
        selection-match = "${config.lib.stylix.colors.base0D}ff";
        border = "${config.lib.stylix.colors.base0D}ff";
      };
      border = {
        width = 2;
        radius = 15;
      };
    };
  };

  stylix.targets.waybar.enable = false;
  stylix.targets.fuzzel.enable = false;

  home.file = {
    ".config/niri".source = ./dotfiles/niri;
    ".config/waybar".source = ./dotfiles/waybar;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen.desktop";
      "x-scheme-handler/http" = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
      "x-scheme-handler/about" = "zen.desktop";
      "x-scheme-handler/unknown" = "zen.desktop";
      "x-scheme-handler/discord" = [ "discord.desktop" ];
      "x-scheme-handler/vscode" = [ "code.desktop" ];
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_BROWSER = "zen";
    SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
    GOPATH = "$HOME/go";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/go/bin"
  ];
}
