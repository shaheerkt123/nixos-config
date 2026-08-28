{ inputs, ... }: {
  flake.nixosModules.android = { pkgs, config, lib, ... }: {
    nixpkgs.overlays = [
      inputs.android-nixpkgs.overlays.default
    ];
  };

  flake.homeModules.android = { pkgs, config, lib, ... }: {
    imports = [
      inputs.android-nixpkgs.hmModule
    ];

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

    home.packages = with pkgs; [
      android-studio
    ];

    home.sessionVariables = {
      ANDROID_HOME = "${config.android-sdk.path}";
      ANDROID_DATA = "${config.android-sdk.path}";
    };
  };
}
