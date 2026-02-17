{ lib,inputs, username }:{ pkgs, ... }:{
  # home.stateVersion is set in lib/default.nix

  home.shellAliases = {
    lg = "lazygit";
    tmux = "tmux -u";
    vim = "nvim";
    kblink = "sudo pkill TouchBarServer; sudo killall 'ControlStrip'";
    dotnet-ef = "~/.dotnet/tools/dotnet-ef";
    opencode = "~/.opencode/bin/opencode";
  };
  
  home.file.".config/skhd/skhdrc".text = ''
    # ============================================
    # FOCUS - Cambiar foco entre ventanas
    # ============================================
    
    # Vim-style navigation
    alt - h : yabai -m window --focus west
    alt - j : yabai -m window --focus south
    alt - k : yabai -m window --focus north
    alt - l : yabai -m window --focus east

    # ============================================
    # SWAP - Intercambiar ventanas
    # ============================================
    
    shift + alt - h : yabai -m window --swap west
    shift + alt - j : yabai -m window --swap south
    shift + alt - k : yabai -m window --swap north
    shift + alt - l : yabai -m window --swap east

    # ============================================
    # MOVE - Mover ventanas
    # ============================================
    
    shift + cmd - h : yabai -m window --warp west
    shift + cmd - j : yabai -m window --warp south
    shift + cmd - k : yabai -m window --warp north
    shift + cmd - l : yabai -m window --warp east

    # ============================================
    # RESIZE - Redimensionar ventanas
    # ============================================
    
    # Expandir
    ctrl + alt - h : yabai -m window --resize left:-50:0
    ctrl + alt - j : yabai -m window --resize bottom:0:50
    ctrl + alt - k : yabai -m window --resize top:0:-50
    ctrl + alt - l : yabai -m window --resize right:50:0

    # Contraer
    ctrl + shift + alt - h : yabai -m window --resize left:50:0
    ctrl + shift + alt - j : yabai -m window --resize bottom:0:-50
    ctrl + shift + alt - k : yabai -m window --resize top:0:50
    ctrl + shift + alt - l : yabai -m window --resize right:-50:0

    # Balance (igualar tamaños)
    shift + alt - 0 : yabai -m space --balance

    # ============================================
    # ROTATION & FLIP
    # ============================================
    
    alt - r : yabai -m space --rotate 90
    shift + alt - r : yabai -m space --rotate 270
    alt - x : yabai -m space --mirror x-axis
    alt - y : yabai -m space --mirror y-axis

    # ============================================
    # LAYOUTS
    # ============================================
    
    # Toggle layout (BSP/Float)
    alt - space : yabai -m space --layout $(yabai -m query --spaces --space | jq -r 'if .type == "bsp" then "float" else "bsp" end')
    
    # Toggle window float
    shift + alt - space : yabai -m window --toggle float --grid 4:4:1:1:2:2

    # Toggle fullscreen
    alt - f : yabai -m window --toggle zoom-fullscreen
    
    # Toggle split orientation
    alt - e : yabai -m window --toggle split

    # ============================================
    # SPACES - Cambiar entre escritorios
    # ============================================
    
    alt - 1 : yabai -m space --focus 1
    alt - 2 : yabai -m space --focus 2
    alt - 3 : yabai -m space --focus 3
    alt - 4 : yabai -m space --focus 4
    alt - 5 : yabai -m space --focus 5
    alt - 6 : yabai -m space --focus 6

    # Mover ventana a espacio
    shift + alt - 1 : yabai -m window --space 1
    shift + alt - 2 : yabai -m window --space 2
    shift + alt - 3 : yabai -m window --space 3
    shift + alt - 4 : yabai -m window --space 4
    shift + alt - 5 : yabai -m window --space 5
    shift + alt - 6 : yabai -m window --space 6

    # Navegar espacios
    alt - n : yabai -m space --focus next
    alt - p : yabai -m space --focus prev
    alt - tab : yabai -m space --focus recent

    # ============================================
    # DISPLAYS - Multi-monitor
    # ============================================
    
    # Focus display
    ctrl + alt - 1 : yabai -m display --focus 1
    ctrl + alt - 2 : yabai -m display --focus 2
    ctrl + alt - 3 : yabai -m display --focus 3

    # Mover ventana a display
    ctrl + shift + alt - 1 : yabai -m window --display 1; yabai -m display --focus 1
    ctrl + shift + alt - 2 : yabai -m window --display 2; yabai -m display --focus 2
    ctrl + shift + alt - 3 : yabai -m window --display 3; yabai -m display --focus 3

    # ============================================
    # WINDOW MANAGEMENT
    # ============================================
    
    # Cerrar ventana
    shift + alt - w : yabai -m window --close

    # Minimizar
    shift + alt - m : yabai -m window --minimize

    # Stack windows
    shift + alt - s : yabai -m window --stack next
    shift + alt - d : yabai -m window --stack prev

    # ============================================
    # RESTART & RELOAD
    # ============================================
    
    # Restart yabai
    ctrl + alt + cmd - r : launchctl kickstart -k "gui/$UID/org.nixos.yabai"
    
    # Reload skhd
    ctrl + alt + cmd - s : skhd --reload

    # sketchybar
    ctrl + alt + cmd - b : sketchybar --reload
  '';

  home.sessionVariables = {
        PAGER = "less";
        CLICLOLOR = 1;
        EDITOR = "nvim";
  };

# file-tools
  programs = {
    bat = {
        enable = true;
        config.theme = "TwoDark";
    };
    lsd.enable = true;
    fzf = {
        enable = true;
        enableZshIntegration = true;
    };
    # openclaw = {
    #   enable = true;
    #   firstParty = {
    #     summarize.enable = true;   # Summarize web pages, PDFs, videos
    #   };
    #   instances.default = {};
    # };
  };


# shell and term
  programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        oh-my-zsh = {
          enable = true;
	      theme = "gnzh";
	      plugins = [ "git" "docker" "npm" "pip" ];
        };
        sessionVariables = {
          CLICOLOR = 1;
        };
  };
  programs.kitty = {
    enable = true;
        font = {
            name = "Hack Nerd Font";
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
        background_opacity = "0.8";
        }; 
        themeFile = "Catppuccin-Mocha";
  };

# programming
  programs.git = {
        enable = true;
        userName = "ferock";
        userEmail = "ferock07@gmail.com";
        extraConfig = {
        github.user = "ferock";
        init = { defaultBranch = "main"; };
        diff = { external = "${pkgs.difftastic}/bin/difft"; };
        };
  };
  programs.go.enable = true;
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

# clusters things
  programs.k9s.enable = true;

}
