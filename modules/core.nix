{ inputs, ... }: {
  flake.nixosModules.core = { pkgs, config, lib, ... }: {
    imports = [
      inputs.home-manager.nixosModules.default
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.trusted-users = [ "root" "shaheer" ];
    nix.settings.http2 = false;
    nix.settings.build-dir = "/home/nix-build";

    systemd.services.nix-daemon.environment.TMPDIR = "/home/nix-build";
    systemd.tmpfiles.rules = [
      "d /home/nix-build 0755 root root -"
    ];

    time.timeZone = "Asia/Kolkata";
    i18n.defaultLocale = "en_IN";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "en_IN";
      LC_IDENTIFICATION = "en_IN";
      LC_MEASUREMENT = "en_IN";
      LC_MONETARY = "en_IN";
      LC_NAME = "en_IN";
      LC_NUMERIC = "en_IN";
      LC_PAPER = "en_IN";
      LC_TELEPHONE = "en_IN";
      LC_TIME = "en_IN";
    };

    users.users.shaheer = {
      isNormalUser = true;
      description = "shaheer";
      extraGroups = [ "networkmanager" "wheel" "bluetooth" "video" "audio" ];
      shell = pkgs.zsh;
    };

    nixpkgs.config.allowUnfree = true;

    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;

    environment.systemPackages = with pkgs; [
      vim
      wget
      git
      unzip
      zip
      fastfetch
      tree
      htop
    ];

    programs.zsh.enable = true;
    system.stateVersion = "24.11";

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs; };
      users.shaheer = {
        imports = [
          inputs.self.homeModules.core
          inputs.self.homeModules.hardware
          inputs.self.homeModules.desktop
          inputs.self.homeModules.dev
          inputs.self.homeModules.apps
        ];
      };
    };
  };

  flake.homeModules.core = { pkgs, config, lib, ... }: {
    home.username = "shaheer";
    home.homeDirectory = "/home/shaheer";
    home.stateVersion = "24.11";

    programs.home-manager.enable = true;

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

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "/home/shaheer/nixos-config";
    };

    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-gnome3;
      defaultCacheTtl = 3600;
      maxCacheTtl = 86400;
      enableSshSupport = true;
      enableZshIntegration = true;
    };

    programs.gpg.enable = true;
  };
}
