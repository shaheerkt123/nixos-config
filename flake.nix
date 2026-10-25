{
  description = "Nixos config flake";

  # configures the binary cache so we don't have to build from source
  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    android-nixpkgs.url = "github:tadfisher/android-nixpkgs";
    kickstart-nix-nvim.url = "github:shaheerkt123/nixvim-config";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    prismlauncher-cracked.url = "github:Diegiwg/PrismLauncher-Cracked";
    stylix.url = "github:danth/stylix";
    clin.url = "github:reekta92/clin-rs";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      dendrite = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          inputs.stylix.nixosModules.stylix
          inputs.lanzaboote.nixosModules.lanzaboote
          inputs.home-manager.nixosModules.default
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              extraSpecialArgs = { inherit inputs; };
              users.shaheer = {
                imports = [ ./home.nix ];
              };
            };
          }
        ];
      };
      nixos = self.nixosConfigurations.dendrite;
      default = self.nixosConfigurations.dendrite;
    };
  };
}
