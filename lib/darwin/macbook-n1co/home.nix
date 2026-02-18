# Home-manager configuration for macbook-n1co
{ lib, inputs, username }:{ pkgs, ... }:
{
  imports = [
    ../../../modules/home-manager/tmux-sessionizer.nix
  ];

  # tmux session manager
  programs.tmuxSessionizer = {
    enable = true;
    projectDirs = [ "~/Documents/DevOps" "~/Documents/Development" ];
    enableFzf = true;
    enableRofi = false;
    enableSpotlight = true;
    defaultTerminal = "${pkgs.kitty}/bin/kitty";
  };
}
