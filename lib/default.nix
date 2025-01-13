{ inputs }:
let
  defaultGit = {
    userEmail = "139995236+fern1co@users.noreply.github.com";
    userName = "FerCarbajal";
  };
  defaultUserName = "fernando-carbajal";
  homeManagerShared = import ./shared/home-manager.nix { inherit inputs;};
in
{
mkDarwin = {
    git ? defaultGit,
    username ? defaultUserName,
    system
  }:
  inputs.nix-darwin.lib.darwinSystem {
    inherit system;
    modules = [
      	(import ./darwin/configuration.nix { inherit username; })
        inputs.home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = { pkgs, ... }: {
            imports = [
              homeManagerShared {inherit git;}
            ];
            # home.file."Library/Application Support/k9s/skin.yml".source = ../config/k9s/skin.yml;
          };
        }
    ];
  };
mkNixos = {
    git ? defaultGit,
    username ? defaultUserName,
    system,
  }:
  inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
        (import ./nixos/configuration.nix { inherit inputs username; })

        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${username}" = { pkgs, ... }: {
            imports = [
              inputs.catppuccin.homeManagerModules.catppuccin
              inputs.anyrun.homeManagerModules.anyrun
              (import ./nixos/home-manager.nix)
                (homeManagerShared {inherit git;})
            ];
          };
        }
    ];
  };
}
