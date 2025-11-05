# DigitalOcean-specific server profile
# Optimized for DigitalOcean droplets
{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
  ];

  # Enable cloud-init for DigitalOcean metadata service
  services.cloud-init.enable = true;
  services.cloud-init.network.enable = true;

  # DigitalOcean droplet optimization
  services.qemuGuest.enable = true;

  # Time zone - UTC for servers
  time.timeZone = lib.mkDefault "UTC";

  # Locale settings
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  # Common firewall ports for web services
  networking.firewall.allowedTCPPorts = lib.mkDefault [ 22 80 443 ];
}
