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
  };

  outputs = inputs@{ self, flake-parts, ... }:
    let
    mkDarwin = self.lib.mkDarwin {};
    mkNixos = self.lib.mkNixos {};
  in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        darwinConfigurations = {
          aarch64 = mkDarwin { system = "aarch64-darwin"; };
          x86_64 = mkDarwin { system = "x86_64-darwin"; };
        };

        lib = import ./lib { inherit inputs; };

        nixosConfigurations = {
          x86_64 = mkNixos { system = "x86_64-linux"; };
        };
      };

      systems = [ "aarch64-darwin" "aarch64-linux" "x86-64-darwin" "x86-64-linux" ];

    };
}
