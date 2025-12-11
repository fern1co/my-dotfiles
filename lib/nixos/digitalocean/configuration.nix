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
    # Secrets configuration
    #(import ./secrets.nix { inherit inputs; inherit username; })

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

    # Primary SSH key for direct access
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCfkO8Yq+xqCA5oTalJh6p9RsjwWUBai8AXOPrhF4kTV/b8ar5OrWxHHAv2Dt3Wzv0kihKlwUyPddn8kF7RBtbTjbPSn6D2Fv0McOZ+B5C1Tfomzj5jREYgUpaYamhCnb8W9vTo3lxJCQnIzGLPr7w+tvh3omyS/EkT+/yY8gFHQjcHIUchHrnxzQnjgWGCNE64h1TZk9o7wxv2Q5ekHsMB/JRH1naJvHaEMN0Ulbrch8r0PAxPXokQmNNCI6dYofFZkf99FaT03FNZFBPixcvzlxLPlPHQ5ZBO0onyc3l9a1AQdg3Wv9V9ebAa02ZjSuvF1xtiOu9jhXQNrAYU97RD ferock07@gmail.com"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC+T1vWLTrFulf0iocsbU/LKBFZT8prE37TanFUjaNDIqcI6SvKD5pgDOUaxc+gyoCm+2t403tB758lsR6NFgG2UufyB4GdwZQdc3gw3Ae0KmFNppl8rW43oJaNmGkCIRdqSYAcxFReCDH5sf2vI9j3aURLnZSiNjANaC94e89DIPqXRFMkxo9enyInDBDFzVbiiZn+0vuWe+nqq1VFZ423epCs8qTgoO6OW2utL8GOvsOrhagQYq12BsbiGeXBxePe8WdEzPCT0OOfEZDsbZE2j8idZgsAzhuK3D2xWKTFn7T9Vljepikd3RgXUj2XcssHVs62N7ks/a2LuuziSgzLZ+wQkhOlqUIl5YTbS4de7MxdTk/AG7wVYldDH82Vr6slbh5x3BtUXE+pB7i8oiaPvrzd/soaZS4gBCWssyFn6lTjBZ6zzfUev+p0IWeK1BZkY/JszYBN9cHdMBCtTyBgPgFHxlfNVtRY4jJZIYm4X13RXd/4JxxJ5ohn161SNg8= fernando-carbajal@nixos"
    ];
  };

  # System state version
  system.stateVersion = "25.05";
}
