# Home-manager modules loader
# Import this file to load all home-manager modules automatically
#
# Usage in home-manager configuration:
#   imports = [ ../../modules/home-manager ];

{ ... }:

{
  imports = [
    ./dev-environment.nix
    ./terminal.nix
    ./tmux-sessionizer.nix
  ];
}
