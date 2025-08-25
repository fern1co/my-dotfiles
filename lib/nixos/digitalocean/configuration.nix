{ inputs, username ? "fernando-carbajal" }: { config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../../config
  ];

  # DigitalOcean specific boot configuration
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  # Enable cloud-init for DigitalOcean metadata service
  services.cloud-init.enable = true;
  services.cloud-init.network.enable = true;

  # Network configuration
  networking.hostName = "nixos-do";
  networking.networkmanager.enable = false;
  networking.useDHCP = true;

  # Enable the OpenSSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
    openFirewall = true;
  };

  # DigitalOcean droplet optimization
  services.qemuGuest.enable = true;

  # User configuration
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    description = "Fernando Carbajal";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      # Add your SSH public key here
      # "ssh-rsa AAAA... your-email@domain.com"
    ];
  };

  # Enable sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Essential packages for server environment
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
    htop
    tree
    unzip
    which
    tmux
  ];

  # Enable Docker for containerized applications
  virtualisation.docker.enable = true;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
    allowedUDPPorts = [ ];
  };

  # Time zone and locale
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable nix flakes
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    settings.trusted-users = [ "root" username ];
  };

  # System state version
  system.stateVersion = "23.11";
}