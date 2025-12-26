# Server Profile
# Minimal server environment with essential tools only

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Essential Tools
    vim git curl wget
    htop tree

    # Sysadmin Tools
    sops age
  ];

  programs = {
    vim.enable = true;
    git.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
    };
  };

  home.shellAliases = {
    ll = "ls -la";
  };

  home.sessionVariables = {
    EDITOR = "vim";
  };
}
