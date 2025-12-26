# hosts.nix - Centralized host configuration with metadata
# This file contains non-sensitive host information and configuration metadata
# For sensitive data, use secrets.yaml with sops-nix
{
  # DigitalOcean VPS
  digitalocean = {
    # Network configuration
    hostname = "159.203.69.154";
    domain = null; # Optional: set to your domain name

    # SSH configuration
    sshUser = "root";
    sshPort = 22;
    deployUser = "root";

    # System configuration
    system = "x86_64-linux";
    username = "ferock";
    hostName = "nixos-kyra";

    # Profiles to apply
    profiles = [
      "base"
      "server"
      "server/digitalocean"
      "development"
    ];

    # Role-based metadata
    role = "server";
    environment = "production";

    # Hardware/VM type
    platform = "digitalocean";
    virtualization = "kvm";

    # Resource information (for documentation)
    resources = {
      cpu = 1;
      ram = 1024; # MB
      disk = 25; # GB
    };

    # Deployment configuration
    deploy = {
      remoteBuild = true;
      autoRollback = true;
      magicRollback = true;
    };

    # Feature flags
    features = {
      docker = false;
      monitoring = false;
      backups = false;
    };
  };

  # Home laptop configuration
  home_laptop = {
    hostname = "localhost";
    hostName = "home-laptop";
    system = "x86_64-linux";
    username = "fernando-carbajal";

    profiles = [
      "base"
      "development"
      "desktop"
      "desktop/hyprland"
      "homelab"
      "gaming"
    ];

    role = "workstation";
    environment = "home";
    platform = "physical";

    # Feature flags for homelab services
    features = {
      docker = true;
      homeAssistant = true;
      adguard = true;
      caddy = true;
      fireflyIII = true;
      esphome = true;
      mealie = true;
      tailscale = true;
    };

    # Keyboard layout
    keyboardLayout = "latam";
  };

  # N1co work machine
  n1co = {
    hostname = "localhost";
    hostName = "n1co-work";
    system = "x86_64-linux";
    username = "fernando-carbajal";

    profiles = [
      "base"
      "development"
    ];

    role = "workstation";
    environment = "work";
    platform = "physical";
  };

  # macOS configurations
  darwin = {
    aarch64 = {
      hostname = "localhost";
      system = "aarch64-darwin";
      username = "fernando.carbajal";

      profiles = [
        "base"
        "development"
      ];

      role = "workstation";
      environment = "development";
      platform = "darwin";
    };

    x86_64 = {
      hostname = "localhost";
      system = "x86_64-darwin";
      username = "fernando.carbajal";

      profiles = [
        "base"
        "development"
      ];

      role = "workstation";
      environment = "development";
      platform = "darwin";
    };

    macbook-pro = {
      hostname = "localhost";
      system = "x86_64-darwin";
      username = "fcarbajalm07";

      profiles = [
        "base"
        "development"
      ];

      role = "workstation";
      environment = "development";
      platform = "darwin";
    };

    macbook-pro2 = {
      hostname = "localhost";
      system = "x86_64-darwin";
      username = "fcarbajalm07";

      profiles = [
        "base"
        "development"
      ];

      role = "workstation";
      environment = "development";
      platform = "darwin";
    };
  };
}
