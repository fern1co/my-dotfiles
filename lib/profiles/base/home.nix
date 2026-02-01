# Workstation Profile
# Full-featured desktop/laptop environment with development tools

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Development Tools
    neovim vim git gh lazygit
    gcc cargo go python314

    # CLI Tools
    curl wget jq ripgrep fd bat lsd
    fzf tmux htop bottom

    # Kubernetes & Cloud
    kubectl k9s kubernetes-helm lazydocker
    google-cloud-sdk

    # Terminal & Shell
    kitty
    direnv

    # Fonts
    nerd-fonts.hack
  ];

  programs = {
    neovim.enable = true;
    git = {
      enable = true;
      package = pkgs.git.override { withLibsecret = true; };
      settings = {
        credential.helper = "libsecret";
      };
    };
    lazygit.enable = true;
    fzf.enable = true;
    tmux.enable = true;
    kitty.enable = true;
    direnv.enable = true;
    bat.enable = true;
    lsd.enable = true;
    bottom.enable = true;
    k9s.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };
  };

  home.shellAliases = {
    lg = "lazygit";
    vim = "nvim";
    n = "nvim";
    cat = "bat";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
