# Homelab profile - Self-hosted services
{ config, pkgs, lib, ... }:

{
  imports = [
    ./sure.nix
  ];
  # Docker for containerized services
  virtualisation.docker.enable = lib.mkForce true;

  # Avahi for local network discovery
  services.avahi = {
    enable = lib.mkDefault true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # Caddy web server
  services.caddy = {
    enable = lib.mkDefault false;
    globalConfig = ''
      skip_install_trust
    '';
  };

  # Home Assistant
  services.home-assistant = {
    enable = lib.mkDefault false;
    config = null;
    configWritable = true;
  };

  # ESPHome
  services.esphome = {
    enable = lib.mkDefault false;
    openFirewall = true;
  };

  # AdGuard Home DNS
  services.adguardhome = {
    enable = lib.mkDefault false;
    port = 8081;
    mutableSettings = true;
  };

  # Mealie recipe manager
  services.mealie = {
    enable = lib.mkDefault false;
    port = 8083;
  };

  # Firefly III personal finance
  services.firefly-iii = {
    enable = lib.mkDefault false;
    virtualHost = null;
  };

  # Sure personal finance app
  services.sure = {
    enable = lib.mkDefault false;
    # Uncomment and configure when enabling:
    # port = 3000;
    # bind = "127.0.0.1";  # Use "0.0.0.0" to expose on all interfaces
    # secretKeyBase = ""; # Generate with: openssl rand -hex 64
    # assumeSsl = false;  # Set to true when using HTTPS reverse proxy
  };

  # Tailscale VPN
  services.tailscale = {
    enable = lib.mkDefault false;
    openFirewall = true;
  };

  services.music-assistant = {
    enable = false;
    providers = ["apple_music" "bluesound" "builtin" "chromecast" "hass" "hass_players" "dlna" "ytmusic" "radiobrowser"];
  };

  # Homelab packages
  environment.systemPackages = with pkgs; [
    # Monitoring
    htop
    btop
    bmon

    # Network tools
    socat

    # Container management
    #docker-compose

    # Smart home
    #mosquitto  # MQTT broker
    #music-assistant
    #rustdesk
  ];

  # Open common homelab ports (override in host config as needed)
  networking.firewall.allowedTCPPorts = lib.mkDefault [];
  networking.firewall.allowedUDPPorts = lib.mkDefault [];
}
