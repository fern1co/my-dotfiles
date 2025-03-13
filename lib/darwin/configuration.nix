{ inputs, username }:{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  programs.zsh.enable = true;
  services.nix-daemon.enable = true;
  system.stateVersion = 4;
  users.users.${username} = {
    # isNormalUser = true;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };
  environment.systemPackages = with pkgs; [
        awscli
        aerospace
        skhd
        pritunl-client
    ];
}
