{ inputs }:
let
  # Default git configuration used across all systems
  defaultGit = {
    userEmail = "139995236+fern1co@users.noreply.github.com";
    userName = "FerCarbajal";
  };

  # Default username for NixOS systems
  defaultUserName = "fernando-carbajal";

  # Shared home-manager configuration imported by all systems
  homeManagerShared = import ./shared/home-manager.nix { inherit inputs;};
in
{
# mkDarwin: Creates a nix-darwin (macOS) system configuration
#
# Arguments:
#   git: Git user configuration (optional, defaults to defaultGit)
#   username: macOS username (optional, defaults to "fernando.carbajal")
#   system: System architecture (required, e.g., "aarch64-darwin" or "x86_64-darwin")
#   configPath: Path to the machine-specific configuration file (required)
#
# Returns: A nix-darwin system configuration
#
# Example:
#   mkDarwin {
#     system = "aarch64-darwin";
#     configPath = ./darwin/my-mac/configuration.nix;
#     username = "myuser";
#   }
mkDarwin = {
    git ? defaultGit,
    username ? "fernando.carbajal",
    system,
    configPath,
  }:
  inputs.nix-darwin.lib.darwinSystem {
    inherit system;
    modules = [
        # Import the machine-specific configuration
        (import configPath { inherit inputs username; })

        # Enable sops-nix for secrets management
        inputs.sops-nix.darwinModules.sops

        # Configure home-manager for macOS
        inputs.home-manager.darwinModules.home-manager {
          # Create backups when home-manager overwrites files
          home-manager.backupFileExtension = "backup";
          # Use system-level nixpkgs
          home-manager.useGlobalPkgs = true;
          # Install packages to user environment
          home-manager.useUserPackages = true;

          # Configure home-manager for the specified user
          home-manager.users.${username} = { pkgs, ... }: {
            imports = [
                # Catppuccin theming
                inputs.catppuccin.homeModules.catppuccin
                # Sops secrets for home-manager
                inputs.sops-nix.homeManagerModules.sops
                # Shared home-manager configuration
                (homeManagerShared {inherit git;})
            ];
          };
        }
    ];
  };

# mkNixos: Creates a NixOS system configuration
#
# Arguments:
#   git: Git user configuration (optional, defaults to defaultGit)
#   username: Linux username (optional, defaults to defaultUserName)
#   system: System architecture (required, e.g., "x86_64-linux" or "aarch64-linux")
#   configPath: Path to the machine-specific configuration file (required)
#
# Returns: A NixOS system configuration
#
# Example:
#   mkNixos {
#     system = "x86_64-linux";
#     configPath = ./nixos/my-server/configuration.nix;
#     username = "myuser";
#   }
mkNixos = {
    git ? defaultGit,
    username ? defaultUserName,
    system,
    configPath,
  }:
  inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
        # Import the machine-specific configuration
        (import configPath { inherit inputs username; })

        # Enable sops-nix for secrets management
        inputs.sops-nix.nixosModules.sops

        # Configure home-manager for NixOS
        inputs.home-manager.nixosModules.home-manager
        {
          # Create backups when home-manager overwrites files
          home-manager.backupFileExtension = "backup";
          # Use system-level nixpkgs
          home-manager.useGlobalPkgs = true;
          # Install packages to user environment
          home-manager.useUserPackages = true;

          # Configure home-manager for the specified user
          home-manager.users."${username}" = { pkgs, ... }: {
            imports = [
              # Sops secrets for home-manager
              inputs.sops-nix.homeManagerModules.sops
              # Catppuccin theming
              inputs.catppuccin.homeModules.catppuccin
              # NixOS-specific home-manager config
              (import ./nixos/home-manager.nix)
              # Shared home-manager configuration
              (homeManagerShared {inherit git;})
            ];
          };
        }
    ];
  };

# mkDigitalOceanImage: Creates a DigitalOcean-compatible system image
#
# This function generates a pre-configured image that can be uploaded to
# DigitalOcean for rapid droplet deployment using nixos-generators.
#
# Arguments:
#   git: Git user configuration (optional, defaults to defaultGit)
#   username: Linux username (optional, defaults to defaultUserName)
#   system: System architecture (optional, defaults to "x86_64-linux")
#   configPath: Path to configuration (optional, defaults to digitalocean config)
#
# Returns: A DigitalOcean image that can be built with:
#   nix build .#digitalOceanImage
#
# The resulting image will be in ./result/ and can be uploaded to DigitalOcean.
mkDigitalOceanImage = {
    git ? defaultGit,
    username ? defaultUserName,
    system ? "x86_64-linux",
    configPath ? ./nixos/digitalocean/configuration.nix,
  }:
  inputs.nixos-generators.nixosGenerate {
    inherit system;
    # Use DigitalOcean format
    format = "do";
    modules = [
      # Import the machine-specific configuration (usually digitalocean/configuration.nix)
      (import configPath { inherit inputs username; })

      # Enable sops-nix for secrets management
      inputs.sops-nix.nixosModules.sops

      # Configure home-manager for the DigitalOcean image
      inputs.home-manager.nixosModules.home-manager
      {
        # Create backups when home-manager overwrites files
        home-manager.backupFileExtension = "backup";
        # Use system-level nixpkgs
        home-manager.useGlobalPkgs = true;
        # Install packages to user environment
        home-manager.useUserPackages = true;

        # Configure home-manager for the specified user
        # Note: Minimal configuration for server deployment
        home-manager.users."${username}" = { pkgs, ... }: {
          imports = [
            # DigitalOcean-specific home configuration
            (import ./nixos/digitalocean/home.nix)
            # Sops secrets for home-manager
            inputs.sops-nix.homeManagerModules.sops
          ];
        };
      }
    ];
  };
}
