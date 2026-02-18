# Development Profile
# Development-focused environment with language toolchains

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Core Development
    neovim git gh lazygit

    # Programming Languages
    gcc cargo rustc
    go gopls
    python314 python314Packages.pip
    python310
    nodejs nodePackages.npm
    (with dotnetCorePackages; combinePackages [ sdk_8_0 ])

    # iAC
    tenv

    # Development Tools
    jq ripgrep fd fzf
    tmux direnv

    # Containerization
    kubectl k9s lazydocker

    # CLI Enhancements
    bat lsd bottom
  ];

  programs = {
    neovim.enable = true;
    git.enable = true;
    lazygit.enable = true;
    fzf.enable = true;
    tmux.enable = true;
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
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "docker" "npm" "pip" ];
      };
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
