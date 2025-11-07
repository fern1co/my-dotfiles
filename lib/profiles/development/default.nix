# Development profile - Tools for software development
# Common development tools and environment setup
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Version control
    git
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
    alejandra

    # Debugging and profiling
    gdb
    valgrind

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

  # Docker configuration (disabled by default, enable in host config or homelab profile)
  virtualisation.docker = {
    enable = lib.mkDefault false;
    # Auto-prune images weekly
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Git configuration
  programs.git = {
    enable = true;
    lfs.enable = true;
  };
}
