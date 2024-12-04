{ inputs }: { pkgs, lib, config, ...}:
let isDarwin = system == "aarch64-darwin" || system == "x86_64-darwin";
system = pkgs.system;
dotnet = (with pkgs.dotnetCorePackages; combinePackages [
      sdk_6_0 sdk_7_0 sdk_8_0
    ]);

in {
  #imports = [
  	#inputs.nixvim.homeManagerModules.nixvim
   	#../../modules/nvim
  #];
  home.packages = with pkgs; [
    vim fd jq k9s kubectl lazydocker ripgrep azure-cli kubelogin kubernetes-helm terraform
    lens google-cloud-sdk pulumi-bin go cargo kind
    (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
    dotnet 

    # csharp-ls
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
    "ls" = "lsd";
    "dotnet-ef" = "$HOME/.dotnet/tools/dotnet-ef";
  };
  programs.neovim.enable = true;
  

  programs.zsh = {
    enable = true;
    enableCompletion = true;
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
    config = { theme = "catppuccin"; };
    themes = {
        catppuccin = {
          src = pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "bat";
            rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
            sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
        };
        file = "Catppuccin-macchiato.tmTheme";
      };
    };
  };

  programs.bottom.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
  };

  programs.lazygit = {
    enable = true;
    settings.gui = {
      theme = {
        activeBorderColor = ["#89dceb" "bold"];
        inactiveBorderColor = ["#a6adc8"];
        optionsTextColor = ["#89b4fa"];
        selectedLineBgColor  = ["#313244"];
        selectedRangeBgColor = ["#313244"];
        cherryPickedCommitBgColor = ["#45475a"];
        cherryPickedCommitFgColor = ["#89dceb"];
        unstagedChangesColor =["#f38ba8"];
        defaultFgColor =["#cdd6f4"];
        searchingActiveBorderColor =["#f9e2af"];
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.k9s.enable = true;

  programs.kitty = {
    enable = true;
  	font = {
	    name = "FiraCode Nerd Font Mono";
	    size = 13.5;
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
  #programs.nixvim = {
  # enable = true;
  #};
}

