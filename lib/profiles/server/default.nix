# Server profile - Configuration for server environments
# Optimized for headless operation, security, and reliability
{ config, pkgs, lib, ... }:

{
  # SSH configuration for remote access
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
    openFirewall = true;
  };

  # Fail2ban for brute force protection
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
    ];
  };

  # Server-specific packages
  environment.systemPackages = with pkgs; [
    sops
    age
    tree
    ncdu
    iotop
    lsof
    strace
  ];

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  };

  # System monitoring and logging
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=7day
  '';

  # Firewall enabled by default
  networking.firewall.enable = lib.mkDefault true;

  # Disable unnecessary services for servers
  documentation.enable = lib.mkDefault false;
  documentation.nixos.enable = lib.mkDefault false;
}
