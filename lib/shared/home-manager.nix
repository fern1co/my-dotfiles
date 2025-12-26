{ inputs, homeManagerModules }:{git}:{ pkgs, ...}:
let
  system = pkgs.system;
  dotnet = (with pkgs.dotnetCorePackages; combinePackages [
      sdk_8_0
    ]);
in {
  # Import home-manager modules for unified configuration
  # Path passed from lib/default.nix to avoid relative path resolution issues
  imports = [
    homeManagerModules
  ];

  # Enable unified development environment
  programs.devEnvironment = {
    enable = true;

    # Languages used in this environment
    languages = [ "go" "rust" ];

    # Enable all tool categories
    tools = {
      vcs = true;        # git, gh, lazygit
      editors = true;    # neovim
      terminals = true;  # tmux
      utils = true;      # fd, jq, ripgrep, bat, fzf, lsd, bottom
      network = true;    # curl, wget
      containers = true; # kubectl, k9s, helm, lazydocker
    };

    # Project-specific packages not covered by modules
    extraPackages = with pkgs; [
      google-cloud-sdk
      google-chrome
      nss
      dotnet
    ];

    # Project-specific aliases (module provides standard ones)
    shellAliases = {
      "dotnet-ef" = "$HOME/.dotnet/tools/dotnet-ef";
      "k9c" = "kubectl config get-contexts -o name | fzf | xargs -r k9s --context";
    };

    # Project-specific session variables (module provides EDITOR, etc.)
    sessionVariables = {
      DOTNET_ROOT = "${dotnet}";
    };

    # Enable basic git config (extended below)
    enableGitConfig = true;
  };

  # Enable unified terminal configuration
  programs.terminalConfig = {
    enable = true;
    terminal = "kitty";
    font = {
      name = "Hack Nerd Font Propo";
      size = 14;
    };
    opacity = 0.9;
    theme = "Catppuccin-Mocha";
    enableLigatures = true;
  };

  home.stateVersion = "24.11";

  # Catppuccin theme integration
  catppuccin.zsh-syntax-highlighting.enable = true;
  catppuccin.tmux.enable = true;
  catppuccin.lazygit.enable = true;
  catppuccin.k9s.enable = true;
  catppuccin.k9s.transparent = true;

  # ZSH configuration (oh-my-zsh specific)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableVteIntegration = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "gnzh";
      plugins = [ "git" "docker" "npm" "pip"];
    };
  };

  # direnv with nix integration
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Git configuration with project-specific settings
  programs.git =
    pkgs.lib.recursiveUpdate git
    {
      enable = true;
      userName = git.userName;
      userEmail = git.userEmail;
      extraConfig = {
        credential.helper = "store";
      };
    };

  # K9s with custom plugins
  programs.k9s = {
    enable = true;
    plugins = {
      shell = {
        shortCut = "Shift-V";
        description = "Pod Shell";
        scopes = [ "po" ];
        command = "kubectl";
        background = false;
        args = [
          "exec"
          "-ti"
          "-n"
          "$NAMESPACE"
          "--context"
          "$CONTEXT"
          "$NAME"
          "--"
          "sh"
          "-c"
          "'clear; (bash || ash || sh)'"
        ];
      };
    };
  };

  # Kitty terminal-specific overrides (terminal module handles base config)
  programs.kitty = {
    settings = {
      # Additional settings not in module
      macos_option_as_alt = false;
      single_window_margin_width = 4;
      mouse_hide_wait = 3;
      input_delay = 3;
    };
  };

  # tmux with advanced configuration
  programs.tmux = {
    prefix = "C-a";
    enable = true;
    mouse = true;
    plugins = [
      pkgs.tmuxPlugins.catppuccin
      pkgs.tmuxPlugins.cpu
      pkgs.tmuxPlugins.battery
      pkgs.tmuxPlugins.resurrect
      pkgs.tmuxPlugins.net-speed
    ];
    extraConfig = ''
      set -g base-index 1
      set -g escape-time 1
      setw -g pane-base-index 1
      setw -g automatic-rename on
      set -g renumber-windows on
      set -g set-titles on

      # split current window horizontally
      bind - split-window -v
      # split current window vertically
      bind _ split-window -h

      # pane navigation
      bind -r h select-pane -L  # move left
      bind -r j select-pane -D  # move down
      bind -r k select-pane -U  # move up
      bind -r l select-pane -R  # move right
      bind > swap-pane -D       # swap current pane with the next one
      bind < swap-pane -U       # swap current pane with the previous one
      # pane resizing
      bind -r H resize-pane -L 2
      bind -r J resize-pane -D 2
      bind -r K resize-pane -U 2
      bind -r L resize-pane -R 2
    '';
  };
}
