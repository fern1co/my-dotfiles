{ lib,inputs, username }:{ pkgs, ... }:
{
    home.stateVersion = "25.11";

    #gtk.catppuccin.enable = true;
    #gtk.catppuccin.flavor = "mocha";
    #gtk.catppuccin.icon.enable = true;

    catppuccin.tmux.enable = true;
    catppuccin.flavor = "mocha";
    catppuccin.k9s.enable = true;
    catppuccin.k9s.transparent = true;
    catppuccin.lazygit.enable = true;
    catppuccin.lazygit.accent = "mauve";
    catppuccin.zsh-syntax-highlighting.enable = true;
    catppuccin.hyprlock.enable = true;

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


    programs.gpg.enable = true;
    programs.chromium.enable = true;
    programs.hyprlock.enable = true;
    programs.hyprlock.settings = {
      general = {
        ignore_empty_input = true;
        disable_input_if_command_fails = false;
        disable_loading_bar = true;
        grace = 0;
      };
      auth = {
        pam = {
          enable = true;
        };
        fingerprint = {
          enable = true;
          ready_message = "Place your finger on the sensor";
          present_message = "scanning";
        };
      };
      background = {
        path = "screenshot"; #"$HOME/backgrounds/Space-Nebula.png";
        blur_passes = 1;
        color = "@base";
      };
      label = [
        {
          text = "cmd[update:1000] echo $(date +%-I:%M%p);";
          color = "$text";
          font_size = 120;
          font_family = "FiraCode Nerd Font Mono";
          position = "0, -150";
          valign = "top";
          halign = "center";
        }
        {
          text = ''cmd[update:1000] echo "<span>$(date '+%A, %d %B')</span>"'';
          color = "$text";
          font_size = 30;
          font_family = "FiraCode Nerd Font Mono";
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
        {
          text = "Hello, $USER";
          font_size = 25;
          font_family = "FiraCode Nerd Font Mono";
          position = "0, -70";
          halign = "center";
          valign = "center";
        }
      ];
      input-field = [{
        size = "290, 60";
        outline_thickness = 4;
        dots_size = "0.2";
        dots_spacing = "0.2";
        dots_center = true;
        font_family = "FiraCode Nerd Font Mono";
        outer_color = "$mauve";
        inner_color = "$surface0";
        font_color = "$text";
        fade_on_empty= false;
        placeholder_text = "<span foreground='##$mauveAlpha'><i>󰌾 Logged in  </i></span>";
        hide_input = false;
        check_color = "$mauveAlpha";
        fail_color = "$red";
        fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
        fail_timeout = 1000;
        capslock_color = "$yellow";
        position = "0, -140";
        halign = "center";
        valign = "center";
      }];
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

    home.packages = [
      pkgs.swaylock
      pkgs.killall
      pkgs.swaynotificationcenter
      pkgs.rofi-systemd
      pkgs.rofi-power-menu

      pkgs.nerd-fonts.hack
      pkgs.nerd-fonts.fira-code
    ]; 

    services.darkman.enable = true;

    fonts.fontconfig.enable = true;

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "pidof hyprlock || hyprlock";
        };

        listener = [
          {
            timeout = 150; # 2.5min
            on-timeout = "light -S 10 && light -O";
            on-resume = "light -I";
          }
          {
            timeout = 900; # 15min
            on-timeout = "hyprlock";
          }
          #{
          #  timeout = 1800; # 30min
          #  on-timeout = "hyprctl dispatch dpms off";
          #  on-resume = "hyprctl dispatch dpms on";
          #}
        ];
      };
  };

  # Kitty terminal-specific overrides (terminal module handles base config)
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

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };


  home.shellAliases = {
    lg = "lazygit";
    tmux = "tmux -u";
    vim = "nvim";
  };

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
  };

  # Openclaw configuration
  programs.openclaw = {
    enable = true;
    # Path to your managed documents directory
    # documents = ./documents;

    # Openclaw configuration (optional - uncomment and configure as needed)
    # config = {
    #   channels.telegram = {
    #     tokenFile = "/path/to/telegram/bot/token";
    #     allowFrom = [ 123456789 ]; # Your Telegram user ID
    #     groups = {
    #       "*" = { requireMention = true; };
    #     };
    #   };
    # };

    # Default instance configuration
    instances.default = {
      enable = true;
      # Add plugins here as needed
      # plugins = [
      #   { source = "github:acme/example-plugin"; }
      # ];
    };
  };

}
