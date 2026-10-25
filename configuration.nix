{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./theme.nix
  ];

  # Nix and Flakes settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" "shaheer" ];
  nix.settings.http2 = false;
  nix.settings.build-dir = "/home/nix-build";

  systemd.services.nix-daemon.environment.TMPDIR = "/home/nix-build";
  systemd.tmpfiles.rules = [
    "d /home/nix-build 0755 root root -"
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    inputs.android-nixpkgs.overlays.default
  ];

  # Bootloader & Secure Boot (Lanzaboote)
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # Hardware & Kernel
  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
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
  boot.kernelParams = [
    "ath10k_core.skip_otp=y"
    "btusb.enable_autosuspend=0"
  ];

  # Networking
  networking.hostName = "dendrite";
  networking.networkmanager.enable = true;
  networking.firewall = {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };

  # Localization
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

  # User account
  users.users.shaheer = {
    isNormalUser = true;
    description = "shaheer";
    extraGroups = [ "networkmanager" "wheel" "bluetooth" "video" "audio" ];
    shell = pkgs.zsh;
  };

  # Sound & Printing
  services.printing.enable = true;
  services.blueman.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Display & Window Manager (Niri + Greetd)
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

  # Security & Keyring
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # Programs
  programs.zsh.enable = true;
  programs.mtr.enable = true;
  systemd.services.systemd-tpm2-setup.enable = false;

  # System Packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    unzip
    zip
    fastfetch
    tree
    htop
    tuigreet
    brightnessctl
    gvfs
    gparted
    pavucontrol
    usbutils
    pciutils
    bluez-tools
  ];

  system.stateVersion = "24.11";
}
