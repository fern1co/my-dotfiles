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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, ... }:
    let
    mkDarwin = self.lib.mkDarwin {};
    mkNixos = self.lib.mkNixos {};
    # Import host configurations
    hosts = import ./hosts.nix;
  in
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        darwinConfigurations = {
            aarch64 = self.lib.mkDarwin {
                system = "aarch64-darwin";
                configPath = ./lib/darwin/configuration.nix;
            };
            x86_64 = self.lib.mkDarwin { 
                system = "x86_64-darwin";
                configPath = ./lib/darwin/configuration.nix;
            };
            macbook-pro = self.lib.mkDarwin {
                system = "x86_64-darwin";
                configPath = ./lib/darwin/macbook-pro/configuration.nix;
                username = "fcarbajalm07";
            };
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
          digitalocean = self.lib.mkNixos {
              system = "x86_64-linux";
              configPath = ./lib/nixos/digitalocean/configuration.nix;
              username = "ferock";
          };
        };


        lib = import ./lib { inherit inputs; };

        deploy.nodes.digitalocean = {
          hostname = hosts.digitalocean.hostname;
          profiles.system = {
            sshUser = hosts.digitalocean.sshUser;
            path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.digitalocean;
            user = hosts.digitalocean.deployUser;
          };
        };
      };

      systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];

      perSystem = { config, self', inputs', pkgs, system, lib, ... }: {
        packages = lib.optionalAttrs (system == "x86_64-linux") {
          digitalOceanImage = self.lib.mkDigitalOceanImage {
            username = "ferock";
            inherit system;
          };
        };

        # Comprehensive checks for all configurations
        checks = lib.mkMerge [
          # Deploy-rs checks for deployment configurations
          (inputs.deploy-rs.lib.${system}.deployChecks self.deploy)

          # Darwin configuration checks (only on darwin systems)
          (lib.optionalAttrs (lib.hasInfix "darwin" system) {
            darwin-aarch64 = self.darwinConfigurations.aarch64.system;
            darwin-x86_64 = self.darwinConfigurations.x86_64.system;
            darwin-macbook-pro = self.darwinConfigurations.macbook-pro.system;
          })

          # NixOS configuration checks (only on linux systems)
          (lib.optionalAttrs (lib.hasInfix "linux" system) {
            nixos-n1co = self.nixosConfigurations.n1co.config.system.build.toplevel;
            nixos-home_laptop = self.nixosConfigurations.home_laptop.config.system.build.toplevel;
            nixos-digitalocean = self.nixosConfigurations.digitalocean.config.system.build.toplevel;
          })
        ];

        # Formatter for `nix fmt`
        formatter = pkgs.alejandra;

        apps.deploy = {
          type = "app";
          program = "${inputs.deploy-rs.packages.${system}.default}/bin/deploy";
        };
      };

    };
}
