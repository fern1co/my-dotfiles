# Development profile - Tools for software development
# Common development tools and environment setup
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Version control
    git
    git-lfs
    gh

    # Build tools
    gcc
    gnumake

    # Container tools
    docker-compose

    # Text editors and IDEs
    neovim

    # Language servers and formatters
    nil # Nix LSP
    nixpkgs-fmt
    statix
    #alejandra

    # Debugging and profiling
    gdb
    # valgrind - Broken on macOS, only available on Linux

    # Network tools
    netcat
    nmap

    # File management
    ripgrep
    fd
    jq

    # System monitoring
    btop
  ];

  # Git LFS is installed via environment.systemPackages
  # Git configuration should be done in home-manager, not system level

  # Note: Docker configuration removed from this profile
  # - macOS: Use Docker Desktop (installed outside Nix)
  # - NixOS: Enable virtualisation.docker in host-specific config or homelab profile
}
