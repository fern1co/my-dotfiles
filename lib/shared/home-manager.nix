{ inputs }:{git}:{ pkgs, ...}:
let isDarwin = system == "aarch64-darwin" || system == "x86_64-darwin";
system = pkgs.system;
dotnet = (with pkgs.dotnetCorePackages; combinePackages [
      sdk_8_0
    ]);

in {
  #imports = [
  	#inputs.nixvim.homeManagerModules.nixvim
   	#../../modules/nvim
  #];
  
  home.packages = with pkgs; [
    fd jq k9s kubectl lazydocker ripgrep azure-cli kubelogin kubernetes-helm
    lens google-cloud-sdk pulumi-bin go cargo kind gh gcc google-chrome
    dotnet (pkgs.python312.withPackages (ps: with ps; [
      pyyaml
      requests
    ]))
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DOTNET_ROOT = dotnet;
  };

  home.stateVersion = "24.11";

  home.shellAliases = {
    "lg" = "lazygit";
    "vim" = "nvim";
    "n" = "nvim";
    #"ls" = "lsd";
    "cat" = "bat";
    "dotnet-ef" = "$HOME/.dotnet/tools/dotnet-ef";
    "k9c" = "kubectl config get-contexts -o name | fzf | xargs -r k9s --context";
  };
  programs.neovim.enable = true;

  catppuccin.zsh-syntax-highlighting.enable = true;
  catppuccin.tmux.enable = true;
  catppuccin.lazygit.enable = true;
  # catppuccin.lazygit.catppuccin.accent = "mauve";
  catppuccin.k9s.enable = true;
  catppuccin.k9s.transparent = true;

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

  programs.lsd.enable = true;

  programs.bat = {
    enable = true;
  };

  programs.bottom.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git =
    pkgs.lib.recursiveUpdate git
    {
      enable = true;
    };

  programs.lazygit.enable = true; 

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux = {
      enableShellIntegration = true;
    };
  };

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
  
  programs.kitty = {
    enable = true;
  	font = {
	    name = "Hack Nerd Font Propo";
	    size = 14;
	  };
    shellIntegration = {
      enableZshIntegration = true;
    };
    settings = {
      enable_audio_bell = false;
      macos_option_as_alt = false;
      hide_window_decorations = "titlebar-only";
      single_window_margin_width = 4;
      disable_ligatures = false;
      url_style = "curly";
      mouse_hide_wait = 3;
      detect_urls = true;
      input_delay = 3;
      sync_to_monitor = true;
      background_opacity = "0.9";
    };
    themeFile = "Catppuccin-Mocha";
    keybindings = {
      "ctrl+left" = "neighboring_window left";
      "ctrl+right" = "neighboring_window right";
      "ctrl+up" = "neighboring_window up";
      "ctrl+down" = "neighboring_window down";
      "ctrl+shift+z" = "toggle_layout stack";
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+enter" = "new_window_with_cwd";
    };
  };

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

  #programs.nixvim = {
  # enable = true;
  #};
}

