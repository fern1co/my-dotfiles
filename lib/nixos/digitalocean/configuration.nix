{ inputs, username }: { config, pkgs, lib, modulesPath, ... }:

let
  # Import host metadata
  hosts = import ../../../hosts.nix;
  hostConfig = hosts.digitalocean;

  # Load profiles from host configuration
  profileLoader = import ../../profiles/default.nix;
  profileImports = profileLoader { profiles = hostConfig.profiles; };

in
{
  imports = [
    # Secrets configuration (disabled temporarily until sops is set up)
    # (import ./secrets.nix { inherit inputs; inherit username; })

    # Hardware configuration
    ./hardware.nix
  ] ++ profileImports; # Import all profiles defined in hosts.nix

  # Network configuration from hosts.nix
  networking.hostName = hostConfig.hostName;

  # ZSH shell
  programs.zsh.enable = true;

  # User configuration
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;

    # SSH keys from hosts.nix configuration
    openssh.authorizedKeys.keys = hostConfig.sshKeys;
  };

  # System state version
  system.stateVersion = "25.05";
}
