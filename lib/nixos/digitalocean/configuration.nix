{ inputs, username ? "ferock" }: { config, pkgs, lib, ... }:

{
  imports = [
    ../../shared/secrets.nix
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
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfkO8Yq+xqCA5oTalJh6p9RsjwWUBai8AXOPrhF4kTV/b8ar5OrWxHHAv2Dt3Wzv0kihKlwUyPddn8kF7RBtbTjbPSn6D2Fv0McOZ+B5C1Tfomzj5jREYgUpaYamhCnb8W9vTo3lxJCQnIzGLPr7w+tvh3omyS/EkT+/yY8gFHQjcHIUchHrnxzQnjgWGCNE64h1TZk9o7wxv2Q5ekHsMB/JRH1naJvHaEMN0Ulbrch8r0PAxPXokQmNNCI6dYofFZkf99FaT03FNZFBPixcvzlxLPlPHQ5ZBO0onyc3l9a1AQdg3Wv9V9ebAa02ZjSuvF1xtiOu9jhXQNrAYU97RD ferock07@gmail.com"
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

  # System state version
  system.stateVersion = "25.05";
}
