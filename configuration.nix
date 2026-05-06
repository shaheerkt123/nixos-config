{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  # 2. Enable Lanzaboote and point to your keys
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
      # This starts the TUI login screen
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri";
      user = "greeter";
    };
  };
};

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
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

  hardware.bluetooth.enable = true;

hardware.graphics = {
  enable = true;
  enable32Bit = true; # Necessary for many older game libraries
};

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.shaheer = {
    isNormalUser = true;
    description = "shaheer";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

# Enable the Polkit service itself
  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    alacritty # terminal
    fuzzel
    waybar
    xwayland-satellite
    tuigreet
    awww # wallpaper daemon
    vim
    wget
    git
    thunderbird
    cargo
    baobab # disk analyzer
    rustc
    gcc
    lf
    yazi
    thunar # file manager
    tree
    gvfs # for mounting USBs
    loupe # image viewer
    zsh-syntax-highlighting
    zsh-autosuggestions
    fzf
    gparted
    kdePackages.partitionmanager
    discord
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    zettlr 
    neovim
    bitwarden-desktop
    htop
    gcc
    gnumake
    go
    gopls
    python3
    yarn
    vscode
    unzip
    zip
    jdk25
    inputs.prismlauncher-cracked.packages.${pkgs.system}.default
    fastfetch
  ];

fonts.packages = with pkgs; [
  # The most common set for Waybar icons
  nerd-fonts.symbols-only 
  # Or a specific font if you prefer (e.g., JetBrainsMono)
  nerd-fonts.jetbrains-mono
];

fonts.fontconfig = {
  enable = true;
  defaultFonts = {
    monospace = [ "JetBrainsMono Nerd Font" "Noto Color Emoji" ];
    sansSerif = [ "DejaVu Sans" "Noto Color Emoji" ];
  };
};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;

    # Keep this empty or remove pinentryPackage here
    # so Home Manager's pinentry-kwallet takes over.
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
