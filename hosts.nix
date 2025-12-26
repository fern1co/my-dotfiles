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
    sshUser = "root";  # Using root directly since SSH key is configured
    sshPort = 22;
    deployUser = "root";

    # SSH public keys for authorized access
    sshKeys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfkO8Yq+xqCA5oTalJh6p9RsjwWUBai8AXOPrhF4kTV/b8ar5OrWxHHAv2Dt3Wzv0kihKlwUyPddn8kF7RBtbTjbPSn6D2Fv0McOZ+B5C1Tfomzj5jREYgUpaYamhCnb8W9vTo3lxJCQnIzGLPr7w+tvh3omyS/EkT+/yY8gFHQjcHIUchHrnxzQnjgWGCNE64h1TZk9o7wxv2Q5ekHsMB/JRH1naJvHaEMN0Ulbrch8r0PAxPXokQmNNCI6dYofFZkf99FaT03FNZFBPixcvzlxLPlPHQ5ZBO0onyc3l9a1AQdg3Wv9V9ebAa02ZjSuvF1xtiOu9jhXQNrAYU97RD ferock07@gmail.com"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+T1vWLTrFulf0iocsbU/LKBFZT8prE37TanFUjaNDIqcI6SvKD5pgDOUaxc+gyoCm+2t403tB758lsR6NFgG2UufyB4GdwZQdc3gw3Ae0KmFNppl8rW43oJaNmGkCIRdqSYAcxFReCDH5sf2vI9j3aURLnZSiNjANaC94e89DIPqXRFMkxo9enyInDBDFzVbiiZn+0vuWe+nqq1VFZ423epCs8qTgoO6OW2utL8GOvsOrhagQYq12BsbiGeXBxePe8WdEzPCT0OOfEZDsbZE2j8idZgsAzhuK3D2xWKTFn7T9Vljepikd3RgXUj2XcssHVs62N7ks/a2LuuziSgzLZ+wQkhOlqUIl5YTbS4de7MxdTk/AG7wVYldDH82Vr6slbh5x3BtUXE+pB7i8oiaPvrzd/soaZS4gBCWssyFn6lTjBZ6zzfUev+p0IWeK1BZkY/JszYBN9cHdMBCtTyBgPgFHxlfNVtRY4jJZIYm4X13RXd/4JxxJ5ohn161SNg8= fernando-carbajal@nixos"
    ];

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
        "hacking"
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
        "hacking"
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
