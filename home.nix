{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    inputs.android-nixpkgs.hmModule
  ];

  home.username = "shaheer";
  home.homeDirectory = "/home/shaheer";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # Shell (Zsh)
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
      ];
      theme = "robbyrussell";
    };
    initContent = ''
      bindkey '^f' vi-forward-word
    '';
  };

  # Git
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "shaheer";
        email = "shaheerkt123@users.noreply.github.com";
      };
      init.defaultBranch = "main";
      commit.gpgSign = true;
      gpg.format = "openpgp";
    };
    signing = {
      key = "F1CE2C4445FCB25E";
      signByDefault = true;
    };
  };

  # GPG & SSH
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-gnome3;
    defaultCacheTtl = 3600;
    maxCacheTtl = 86400;
    enableSshSupport = true;
    enableZshIntegration = true;
  };

  # Nh helper
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/shaheer/nixos-config";
  };

  # Terminal & UI
  programs.alacritty.enable = true;

  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      targets = [ "niri.service" ];
    };
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=13";
        prompt = "' ❯  '";
        terminal = "${pkgs.alacritty}/bin/alacritty";
        width = 45;
        lines = 10;
        horizontal-pad = 25;
        vertical-pad = 20;
        inner-pad = 12;
        line-height = 30;
        fields = "name,generic,comment,exec";
        icons-enabled = "yes";
      };
      colors = {
        background = "${config.lib.stylix.colors.base00}d9";
        text = "${config.lib.stylix.colors.base05}ff";
        match = "${config.lib.stylix.colors.base0D}ff";
        selection = "${config.lib.stylix.colors.base02}ff";
        selection-text = "${config.lib.stylix.colors.base05}ff";
        selection-match = "${config.lib.stylix.colors.base0D}ff";
        border = "${config.lib.stylix.colors.base0D}59";
        prompt = "${config.lib.stylix.colors.base0D}ff";
        placeholder = "${config.lib.stylix.colors.base04}ff";
        counter = "${config.lib.stylix.colors.base04}ff";
        input = "${config.lib.stylix.colors.base05}ff";
      };
      border = {
        width = 2;
        radius = 15;
        selection-radius = 10;
      };
    };
  };

  services.cliphist = {
    enable = true;
    systemdTargets = [ "niri.service" ];
  };

  stylix = {
    targets.waybar.enable = false;
    targets.fuzzel.enable = false;
  };

  # Android SDK
  android-sdk = {
    enable = true;
    path = "${config.xdg.dataHome}/Android";
    packages = sdkPkgs: with sdkPkgs; [
      cmdline-tools-11-0
      build-tools-35-0-0
      platform-tools
      platforms-android-35
      emulator
    ];
  };

  # Dotfiles & File Links
  home.file = {
    ".config/niri".source = ./dotfiles/niri;
    ".config/waybar".source = ./dotfiles/waybar;
    ".local/share/jdks/jdk21".source = pkgs.jdk21;
    ".gnupg/sshcontrol".text = ''
      134031545C93095D93D9484C9D957B1F6408C7C1
    '';
  };

  # Session Variables
  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_BROWSER = "zen";
    QT_QPA_PLATFORM = "wayland";
    GOPATH = "$HOME/go";
    ANDROID_HOME = "${config.android-sdk.path}";
    ANDROID_DATA = "${config.android-sdk.path}";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/go/bin"
  ];

  # MIME Apps
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

  # User Services
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    Unit = {
      Description = "polkit-gnome-authentication-agent-1";
      Wants = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  systemd.user.services.copy-screenshot-to-clipboard = {
    Unit = {
      Description = "Copy screenshots to clipboard automatically";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = pkgs.writeShellScript "copy-screenshot" ''
        mkdir -p "${config.home.homeDirectory}/Pictures/Screenshots"
        ${pkgs.inotify-tools}/bin/inotifywait -m -e close_write --format '%w%f' "${config.home.homeDirectory}/Pictures/Screenshots" | while read file; do
          if [ -f "$file" ]; then
            ${pkgs.wl-clipboard}/bin/wl-copy -t image/png < "$file"
          fi
        done
      '';
      Restart = "always";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  # Packages
  home.packages = with pkgs; [
    # Flake inputs
    inputs.kickstart-nix-nvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    (pkgs.symlinkJoin {
      name = "prismlauncher-cracked-wrapped";
      paths = [ inputs.prismlauncher-cracked.packages.${pkgs.stdenv.hostPlatform.system}.default ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/prismlauncher \
          --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ffmpeg ]}
      '';
    })
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
    inputs.clin.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Applications
    discord
    kdePackages.merkuro
    tmux
    opencode
    pass
    keepassxc
    qbittorrent
    thunderbird
    seahorse
    tor-browser
    android-studio

    # Desktop & Utilities
    mpv
    thunar
    loupe
    baobab
    xwayland-satellite
    wl-clipboard
    polkit_gnome
    xhost
    inotify-tools
    playerctl
    networkmanagerapplet
    swaybg
    ffmpeg
    yazi
    lf
    fzf

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
  ];
}
