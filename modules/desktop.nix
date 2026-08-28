{ inputs, ... }: {
  flake.nixosModules.desktop = { pkgs, config, lib, ... }: {
    programs.niri.enable = true;
    programs.xwayland.enable = true;
    programs.dconf.enable = true;
    services.dbus.enable = true;

    services.displayManager.defaultSession = "niri";
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri-session";
          user = "greeter";
        };
      };
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = [ "gtk" ];
        };
      };
    };

    environment.systemPackages = with pkgs; [
      tuigreet
      brightnessctl
      gvfs
      gparted
      pavucontrol
      usbutils
      pciutils
      bluez-tools
    ];
  };

  flake.homeModules.desktop = { pkgs, config, lib, ... }: {
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

    home.packages = with pkgs; [
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
    ];

    home.file = {
      ".config/niri".source = ./../dotfiles/niri;
      ".config/waybar".source = ./../dotfiles/waybar;
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
  };
}
