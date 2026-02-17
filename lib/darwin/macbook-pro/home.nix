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
  

  home.sessionVariables = {
        PAGER = "less";
        CLICLOLOR = 1;
        EDITOR = "nvim";
  };
  # Habilitar yabai y skhd
  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    enableScriptingAddition = true; # Requiere deshabilitar SIP
    config = {
      # Layout
      layout = "bsp";
      
      # Padding y gaps
      top_padding    = 10;
      bottom_padding = 10;
      left_padding   = 10;
      right_padding  = 10;
      window_gap     = 10;

      # Mouse
      mouse_follows_focus = "off";
      focus_follows_mouse = "off";
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      mouse_drop_action = "swap";

      # Window
      window_placement = "second_child";
      window_opacity = "on";
      active_window_opacity = "1.0";
      normal_window_opacity = "0.95";
      window_shadow = "float";

      # Splits
      split_ratio = "0.50";
      auto_balance = "off";
    };

    extraConfig = ''
      # Reglas por aplicación
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^Calculator$" manage=off
      yabai -m rule --add app="^Finder$" manage=off
      yabai -m rule --add app="^Activity Monitor$" manage=off
      yabai -m rule --add app="^1Password$" manage=off
      
      # Aplicaciones que siempre flotan
      yabai -m rule --add app="^Raycast$" manage=off
      yabai -m rule --add title="^Preferences$" manage=off
      yabai -m rule --add title="^Settings$" manage=off
      
      # Borders (opcional, requiere borders plugin)
      # borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=5.0 &
    '';
  };

  services.skhd = {
    enable = true;
    package = pkgs.skhd;
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
