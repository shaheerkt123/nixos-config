{ inputs, ... }: {
  flake.nixosConfigurations.dendrite = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      inputs.self.nixosModules.core
      inputs.self.nixosModules.hardware
      inputs.self.nixosModules.desktop
      inputs.self.nixosModules.dev
      inputs.self.nixosModules.apps

      ../../../hardware-configuration.nix
      ../../../theme.nix
      inputs.stylix.nixosModules.stylix
      inputs.lanzaboote.nixosModules.lanzaboote
    ];
  };
}
