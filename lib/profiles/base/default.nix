# Base profile - Common configuration for all systems
# This module provides fundamental settings shared across all machines
{ config, pkgs, lib, ... }:

{
  # Enable flakes and nix-command
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Optimize storage
    auto-optimise-store = true;
  };

  # Essential system packages present on all systems
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    htop
    neovim
  ];

  # Basic environment variables
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}
