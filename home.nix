{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.android-nixpkgs.hmModule
  ];

  android-sdk = {
    enable = true;

    path = "${config.xdg.dataHome}/Android"; 

    packages = sdkPkgs: with sdkPkgs; [
      cmdline-tools-latest
        build-tools-35-0-0
        platform-tools
        platforms-android-35
        emulator 
    ];
  };

  programs = {
    home-manager.enable = true;

    zsh = {
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

    git = {
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

    gpg.enable = true;

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/shaheer/nixos-config"; # sets NH_OS_FLAKE variable for you
    };

    alacritty.enable = true;

    waybar = {
      enable = true;
      systemd = {
        enable = true;
        targets = [ "niri.service" ];
      };
    };

    fuzzel = {
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
          background = "${config.lib.stylix.colors.base00}d9"; # 85% opacity
          text = "${config.lib.stylix.colors.base05}ff";
          match = "${config.lib.stylix.colors.base0D}ff";
          selection = "${config.lib.stylix.colors.base02}ff";
          selection-text = "${config.lib.stylix.colors.base05}ff";
          selection-match = "${config.lib.stylix.colors.base0D}ff";
          border = "${config.lib.stylix.colors.base0D}59"; # 35% opacity for better visibility
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
  };

  services = {
    gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-qt;
      defaultCacheTtl = 3600;
      maxCacheTtl = 86400;
      enableSshSupport = true;
      enableZshIntegration = true;
    };

    ssh-agent.enable = false;

    cliphist = {
      enable = true;
      systemdTargets = [ "niri.service" ];
    };
  };

  stylix = {
    targets.waybar.enable = false;
    targets.fuzzel.enable = false;
  };

  home = {
    username = "shaheer";
    homeDirectory = "/home/shaheer";
    stateVersion = "25.11";

    packages = with pkgs; [
      inputs.kickstart-nix-nvim.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.prismlauncher-cracked.packages.${pkgs.stdenv.hostPlatform.system}.default
        (pkgs.writeShellScriptBin "agy" ''
         exec ${
         inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
         }/bin/agy "$@"
         '')

# Apps
        mpv
        thunar
        discord
        antigravity
        opencode
        pass
        keepassxc
        qbittorrent
        thunderbird
        sublime4
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
        swaybg

# Development
        android-studio
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
        wl-clipboard
        polkit_gnome
        xhost
        inotify-tools
        ];

    file = {
      ".config/niri".source = ./dotfiles/niri;
      ".config/waybar".source = ./dotfiles/waybar;
      ".gnupg/sshcontrol".text = ''
      134031545C93095D93D9484C9D957B1F6408C7C1
      '';
    };

    sessionVariables = {
      EDITOR = "nvim";
      DEFAULT_BROWSER = "zen";
      GOPATH = "$HOME/go";
      ANDROID_HOME = "${config.android-sdk.path}";
      ANDROID_DATA = "${config.android-sdk.path}";
    };

    sessionPath = [
      "${config.home.homeDirectory}/go/bin"
    ];
  };

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
}
