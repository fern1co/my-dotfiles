{ inputs }:
let
  defaultGit = {
  };
  defaultUserName = "fernando.carbajal";
  homeManagerNixos = import ./nixos/home-manager.nix { inherit inputs; };
  homeManagerShared = import ./shared/home-manager.nix { inherit inputs; };
in
{
mkDarwin = { username ? defaultUserName }: { system }:
  inputs.nix-darwin.lib.darwinSystem {
    inherit system;
    modules = [
      	(import ./darwin/configuration.nix { inherit username; })
        inputs.home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = { pkgs, ... }: {
            imports = [
              homeManagerShared
            ];
            # home.file."Library/Application Support/k9s/skin.yml".source = ../config/k9s/skin.yml;
          };
        }
    ];
  };
mkNixos = { username ? defaultUserName } : { system }:
  inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      (import ./nixos/hardware/${system}.nix)
        (import ./nixos/configuration.nix { inherit username; })
        (import ./nixos/configuration-desktop.nix {inherit username; })

        inputs.home-manager.nixosModules.home-manager 
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."${username}" = { pkgs, ... }: {
            imports = [
              (homeManagerNixos {})
                (homeManagerShared {})
            ];
          };
        }
    ];
  };
}
