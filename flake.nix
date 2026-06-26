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

    # Add the official Numtide LLM agents flake for antigravity-cli
    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";

    android-nixpkgs.url = "github:tadfisher/android-nixpkgs";
    kickstart-nix-nvim.url = "github:shaheerkt123/nixvim-config";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    prismlauncher-cracked.url = "github:Diegiwg/PrismLauncher-Cracked";
    stylix.url = "github:danth/stylix";
  };

  outputs = { nixpkgs, ... }@inputs: {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./theme.nix
          inputs.stylix.nixosModules.stylix
          inputs.home-manager.nixosModules.default
          inputs.lanzaboote.nixosModules.lanzaboote
          {
            nixpkgs.overlays = [
              inputs.android-nixpkgs.overlays.default
            ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              users.shaheer = {
                imports = [ ./home.nix ];
              };
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
      };
    };
}
