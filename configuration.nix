{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  networking.firewall = {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };

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

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
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

  services.printing.enable = true;
  services.blueman.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  boot.kernelModules = [ "btusb" "ath10k_pci" ];

# Force loading firmware and fix power management drops
  boot.kernelParams = [ 
    "ath10k_core.skip_otp=y" 
  ];

  programs.zsh.enable = true;

  users.users.shaheer = {
    isNormalUser = true;
    description = "shaheer";
    extraGroups = [ "networkmanager" "wheel" "bluetooth" "video" ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    tuigreet
    brightnessctl
    gvfs
    gparted
    unzip
    zip
    fastfetch
    blueman
  ];

  programs.mtr.enable = true;

  system.stateVersion = "25.11";
}
