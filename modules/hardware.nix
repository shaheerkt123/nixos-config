{ inputs, ... }: {
  flake.nixosModules.hardware = { pkgs, config, lib, ... }: {
    boot.loader.systemd-boot.enable = false;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.timeout = 3;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    networking.hostName = "dendrite";
    networking.networkmanager.enable = true;
    networking.firewall = {
      allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
      allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
    };

    hardware.enableRedistributableFirmware = true;
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

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

    systemd.services.systemd-tpm2-setup.enable = false;
    programs.mtr.enable = true;
  };

  flake.homeModules.hardware = { pkgs, config, lib, ... }: {
    # No specific home-manager hardware config for now
  };
}
