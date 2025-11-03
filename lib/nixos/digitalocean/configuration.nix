{ inputs, username }: { config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    (import ./secrets.nix { inherit inputs; inherit username; })
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
  ];



  # Enable cloud-init for DigitalOcean metadata service  
  services.cloud-init.enable = true;
  services.cloud-init.network.enable = true;
  
  # Network configuration
  networking.hostName = "nixos-kyra";

  programs.zsh.enable = true;

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
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = lib.mkForce []; # Let cloud-init handle SSH keys
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
    sops
    age
  ];

  # Enable Docker for containerized applications
  # virtualisation.docker.enable = true;

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

  # Allow unfree packages for Chrome and other tools
  nixpkgs.config.allowUnfree = true;

  # System state version
  system.stateVersion = "25.05";
}
