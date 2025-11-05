# Hardened security profile
# Enhanced security settings for production environments
{ config, pkgs, lib, ... }:

{
  # Strong SSH configuration
  services.openssh.settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
    X11Forwarding = false;
    AllowAgentForwarding = false;
    AllowStreamLocalForwarding = false;
    AuthenticationMethods = "publickey";
  };

  # Firewall with strict defaults
  networking.firewall = {
    enable = true;
    # Only allow explicitly configured ports
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
    # Log refused connections
    logRefusedConnections = true;
    logRefusedPackets = false; # Can be noisy
  };

  # Kernel hardening
  boot.kernel.sysctl = {
    # Disable IP forwarding
    "net.ipv4.ip_forward" = 0;
    "net.ipv6.conf.all.forwarding" = 0;

    # Enable SYN cookies
    "net.ipv4.tcp_syncookies" = 1;

    # Ignore ICMP redirects
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;

    # Disable source routing
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;

    # Enable reverse path filtering
    "net.ipv4.conf.all.rp_filter" = 1;
  };

  # Sudo configuration
  security.sudo = {
    wheelNeedsPassword = true;
    # Require password every time
    extraConfig = ''
      Defaults timestamp_timeout=0
    '';
  };

  # Automatic security updates (use with caution in production)
  system.autoUpgrade = {
    enable = lib.mkDefault false;
    allowReboot = false;
  };
}
