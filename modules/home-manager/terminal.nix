# Home-manager module for terminal configuration
# Configures Kitty, Alacritty, or WezTerm with consistent theming

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.terminalConfig;

  # Terminal emulator options
  terminalOptions = {
    kitty = {
      package = pkgs.kitty;
      configPath = ".config/kitty/kitty.conf";
    };
    alacritty = {
      package = pkgs.alacritty;
      configPath = ".config/alacritty/alacritty.yml";
    };
    wezterm = {
      package = pkgs.wezterm;
      configPath = ".config/wezterm/wezterm.lua";
    };
  };

in
{
  options.programs.terminalConfig = {
    enable = mkEnableOption "terminal configuration";

    terminal = mkOption {
      type = types.enum [ "kitty" "alacritty" "wezterm" ];
      default = "kitty";
      description = "Terminal emulator to configure";
    };

    font = {
      name = mkOption {
        type = types.str;
        default = "Hack Nerd Font";
        description = "Font family name";
      };

      size = mkOption {
        type = types.int;
        default = 14;
        description = "Font size";
      };
    };

    opacity = mkOption {
      type = types.float;
      default = 0.95;
      description = "Background opacity (0.0 to 1.0)";
    };

    theme = mkOption {
      type = types.str;
      default = "Catppuccin-Mocha";
      description = "Color theme";
    };

    enableLigatures = mkOption {
      type = types.bool;
      default = true;
      description = "Enable font ligatures";
    };
  };

  config = mkIf cfg.enable {
    # Install selected terminal
    home.packages = [ terminalOptions.${cfg.terminal}.package ];

    # Kitty configuration
    programs.kitty = mkIf (cfg.terminal == "kitty") {
      enable = true;

      font = {
        name = cfg.font.name;
        size = cfg.font.size;
      };

      settings = {
        # Appearance
        background_opacity = toString cfg.opacity;
        disable_ligatures = if cfg.enableLigatures then "never" else "always";

        # Window
        hide_window_decorations = "titlebar-only";
        window_padding_width = 4;

        # Behavior
        enable_audio_bell = false;
        confirm_os_window_close = 0;

        # Performance
        sync_to_monitor = true;

        # URLs
        url_style = "curly";
        detect_urls = true;
      };

      theme = cfg.theme;

      keybindings = {
        # Window management
        "ctrl+shift+enter" = "new_window_with_cwd";
        "ctrl+shift+t" = "new_tab_with_cwd";

        # Navigation
        "ctrl+left" = "neighboring_window left";
        "ctrl+right" = "neighboring_window right";
        "ctrl+up" = "neighboring_window up";
        "ctrl+down" = "neighboring_window down";

        # Layout
        "ctrl+shift+z" = "toggle_layout stack";
      };

      shellIntegration.enableZshIntegration = true;
    };

    # Alacritty configuration
    programs.alacritty = mkIf (cfg.terminal == "alacritty") {
      enable = true;

      settings = {
        font = {
          normal.family = cfg.font.name;
          size = cfg.font.size;
        };

        window = {
          opacity = cfg.opacity;
          padding = {
            x = 4;
            y = 4;
          };
          decorations = "buttonless";
        };

        bell = {
          animation = "EaseOutExpo";
          duration = 0;
        };
      };
    };
  };

  meta = {
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
