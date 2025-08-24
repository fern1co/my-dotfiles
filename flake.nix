{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager";
    nixvim = {
    	url = "github:nix-community/nixvim";
	    inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ self, flake-parts, ... }:
    let
    mkDarwin = self.lib.mkDarwin {};
    mkNixos = self.lib.mkNixos {};
  in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        darwinConfigurations = {
          aarch64 = self.lib.mkDarwin { system = "aarch64-darwin"; };
          x86_64 = self.lib.mkDarwin { system = "x86_64-darwin"; };
        };


        nixosConfigurations = {
          n1co = self.lib.mkNixos {
              system = "x86_64-linux";
              configPath = ./lib/nixos/n1co-work/configuration.nix;
          };
          home_laptop = self.lib.mkNixos { 
              system = "x86_64-linux";
              configPath = ./lib/nixos/home-laptop/configuration.nix;
          };
        };


        lib = import ./lib { inherit inputs; };
      };

      systems = [ "aarch64-darwin" "aarch64-linux" "x86-64-darwin" "x86-64-linux" ];

    };
}
