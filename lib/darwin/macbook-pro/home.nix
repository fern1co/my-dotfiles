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
