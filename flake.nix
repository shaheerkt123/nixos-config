{
  description = "Nixos config flake";

# configures the binary cache so we don't have to build from source
  nixConfig = {
    substituters = "https://cache.numtide.com";
    trusted-public-keys = "numtide.cacache.org-1:2dBdH9HDoBR837GHVn6g8pQ8Y7k="; # Ensures authenticity
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

    kickstart-nix-nvim.url = "github:shaheerkt123/nixvim-config";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    prismlauncher-cracked.url = "github:Diegiwg/PrismLauncher-Cracked";
    stylix.url = "github:danth/stylix";
  };

  outputs =
    { nixpkgs, ... }@inputs: {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./theme.nix
          inputs.stylix.nixosModules.stylix
          inputs.home-manager.nixosModules.default
          inputs.lanzaboote.nixosModules.lanzaboote
          {
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
