{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.yabai;

  # Generate yabai configuration
  yabaiConfig = pkgs.writeText "yabairc" ''
    #!/usr/bin/env sh

    # Global settings
    yabai -m config layout ${cfg.layout}
    yabai -m config window_placement ${cfg.windowPlacement}

    # Gaps
    yabai -m config top_padding    ${toString cfg.gaps.top}
    yabai -m config bottom_padding ${toString cfg.gaps.bottom}
    yabai -m config left_padding   ${toString cfg.gaps.left}
    yabai -m config right_padding  ${toString cfg.gaps.right}
    yabai -m config window_gap     ${toString cfg.gaps.window}

    # Window settings
    yabai -m config window_opacity ${if cfg.windowOpacity.enable then "on" else "off"}
    ${optionalString cfg.windowOpacity.enable ''
      yabai -m config active_window_opacity   ${toString cfg.windowOpacity.active}
      yabai -m config normal_window_opacity   ${toString cfg.windowOpacity.normal}
    ''}

    # Mouse settings
    yabai -m config mouse_follows_focus ${if cfg.mouseFollowsFocus then "on" else "off"}
    yabai -m config focus_follows_mouse ${cfg.focusFollowsMouse}

    # Split ratios
    yabai -m config auto_balance ${if cfg.autoBalance then "on" else "off"}
    yabai -m config split_ratio ${toString cfg.splitRatio}

    # Window borders (requires SIP disabled)
    ${optionalString cfg.border.enable ''
      yabai -m config window_border ${if cfg.border.enable then "on" else "off"}
      yabai -m config window_border_width ${toString cfg.border.width}
      yabai -m config active_window_border_color ${cfg.border.activeColor}
      yabai -m config normal_window_border_color ${cfg.border.normalColor}
    ''}

    # Disable management for specific apps
    ${concatStringsSep "\n" (map (app:
      "yabai -m rule --add app='^${app}$' manage=off"
    ) cfg.disabledApps)}

    # Extra configuration
    ${cfg.extraConfig}
  '';

in
{
  options.services.yabai = {
    enable = mkEnableOption "Yabai tiling window manager";

    package = mkOption {
      type = types.package;
      default = pkgs.yabai;
      description = "The yabai package to use.";
    };

    layout = mkOption {
      type = types.enum [ "bsp" "stack" "float" ];
      default = "bsp";
      description = "Default window layout algorithm.";
    };

    windowPlacement = mkOption {
      type = types.enum [ "first_child" "second_child" ];
      default = "second_child";
      description = "New window spawn position.";
    };

    gaps = {
      top = mkOption {
        type = types.int;
        default = 8;
        description = "Top padding in pixels.";
      };

      bottom = mkOption {
        type = types.int;
        default = 8;
        description = "Bottom padding in pixels.";
      };

      left = mkOption {
        type = types.int;
        default = 8;
        description = "Left padding in pixels.";
      };

      right = mkOption {
        type = types.int;
        default = 8;
        description = "Right padding in pixels.";
      };

      window = mkOption {
        type = types.int;
        default = 8;
        description = "Gap between windows in pixels.";
      };
    };

    windowOpacity = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable window opacity.";
      };

      active = mkOption {
        type = types.float;
        default = 1.0;
        description = "Opacity of active window (0.0-1.0).";
      };

      normal = mkOption {
        type = types.float;
        default = 0.9;
        description = "Opacity of normal windows (0.0-1.0).";
      };
    };

    border = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable window borders (requires SIP disabled).";
      };

      width = mkOption {
        type = types.int;
        default = 4;
        description = "Border width in pixels.";
      };

      activeColor = mkOption {
        type = types.str;
        default = "0xff89b4fa";
        description = "Active window border color (0xAARRGGBB).";
      };

      normalColor = mkOption {
        type = types.str;
        default = "0xff313244";
        description = "Normal window border color (0xAARRGGBB).";
      };
    };

    mouseFollowsFocus = mkOption {
      type = types.bool;
      default = false;
      description = "Make mouse follow window focus.";
    };

    focusFollowsMouse = mkOption {
      type = types.enum [ "off" "autoraise" "autofocus" ];
      default = "off";
      description = "Make window focus follow mouse.";
    };

    autoBalance = mkOption {
      type = types.bool;
      default = false;
      description = "Automatically balance window sizes.";
    };

    splitRatio = mkOption {
      type = types.float;
      default = 0.5;
      description = "New window split ratio (0.1-0.9).";
    };

    disabledApps = mkOption {
      type = types.listOf types.str;
      default = [
        "System Preferences"
        "System Settings"
        "Archive Utility"
        "Calculator"
      ];
      example = [ "Steam" "GIMP" ];
      description = "Applications to not manage with yabai.";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''
        # Custom rules
        yabai -m rule --add app="Finder" manage=off
        yabai -m rule --add app="Spotify" space=5
      '';
      description = "Extra shell commands to add to yabairc.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # Create yabai configuration
    environment.etc."yabai/yabairc" = {
      source = yabaiConfig;
      mode = "0755";
    };

    # Launch yabai service
    launchd.user.agents.yabai = {
      serviceConfig = {
        ProgramArguments = [
          "${cfg.package}/bin/yabai"
          "-c"
          "/etc/yabai/yabairc"
        ];
        RunAtLoad = true;
        KeepAlive = true;
        ProcessType = "Interactive";
        StandardOutPath = "/tmp/yabai.log";
        StandardErrorPath = "/tmp/yabai.error.log";
      };
    };

    # Assertions
    assertions = [
      {
        assertion = cfg.splitRatio >= 0.1 && cfg.splitRatio <= 0.9;
        message = "yabai: splitRatio must be between 0.1 and 0.9";
      }
      {
        assertion = cfg.windowOpacity.active >= 0.0 && cfg.windowOpacity.active <= 1.0;
        message = "yabai: windowOpacity.active must be between 0.0 and 1.0";
      }
      {
        assertion = cfg.windowOpacity.normal >= 0.0 && cfg.windowOpacity.normal <= 1.0;
        message = "yabai: windowOpacity.normal must be between 0.0 and 1.0";
      }
    ];

    warnings = optionals cfg.border.enable [
      "yabai: Window borders require SIP to be disabled. See: https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection"
    ];
  };
}
