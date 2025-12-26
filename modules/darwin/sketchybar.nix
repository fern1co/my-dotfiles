{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.sketchybar;

  # Generate sketchybar configuration script
  configScript = pkgs.writeShellScript "sketchybarrc" ''
    #!/usr/bin/env bash

    # Bar configuration
    sketchybar --bar \
      height=${toString cfg.bar.height} \
      position=${cfg.bar.position} \
      padding_left=${toString cfg.bar.padding.left} \
      padding_right=${toString cfg.bar.padding.right} \
      color=${cfg.bar.color} \
      ${optionalString cfg.bar.transparent "y_offset=10 blur_radius=30"}

    # Default item settings
    sketchybar --default \
      icon.font="${cfg.defaults.font.family}:${cfg.defaults.font.style}:${toString cfg.defaults.font.size}" \
      icon.color=${cfg.defaults.icon.color} \
      label.font="${cfg.defaults.font.family}:${cfg.defaults.font.style}:${toString cfg.defaults.font.size}" \
      label.color=${cfg.defaults.label.color}

    ${optionalString cfg.modules.clock.enable ''
      # Clock module
      sketchybar --add item clock right \
        --set clock \
          update_freq=${toString cfg.modules.clock.updateFreq} \
          icon= \
          script="${pkgs.writeShellScript "clock.sh" ''
            sketchybar --set $NAME label="$(date '${cfg.modules.clock.format}')"
          ''}"
    ''}

    ${optionalString cfg.modules.battery.enable ''
      # Battery module
      sketchybar --add item battery right \
        --set battery \
          update_freq=${toString cfg.modules.battery.updateFreq} \
          script="${pkgs.writeShellScript "battery.sh" ''
            PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
            CHARGING=$(pmset -g batt | grep 'AC Power')

            if [ $PERCENTAGE = "" ]; then
              exit 0
            fi

            if [[ $CHARGING != "" ]]; then
              ICON="󰂄"
            else
              case ''${PERCENTAGE} in
                9[0-9]|100) ICON="󰁹" ;;
                8[0-9]) ICON="󰂂" ;;
                7[0-9]) ICON="󰂁" ;;
                6[0-9]) ICON="󰂀" ;;
                5[0-9]) ICON="󰁿" ;;
                4[0-9]) ICON="󰁾" ;;
                3[0-9]) ICON="󰁽" ;;
                2[0-9]) ICON="󰁼" ;;
                *) ICON="󰁺" ;;
              esac
            fi

            sketchybar --set $NAME icon="$ICON" label="''${PERCENTAGE}%"
          ''}"
    ''}

    ${optionalString cfg.modules.wifi.enable ''
      # WiFi module
      sketchybar --add item wifi right \
        --set wifi \
          update_freq=${toString cfg.modules.wifi.updateFreq} \
          script="${pkgs.writeShellScript "wifi.sh" ''
            SSID=$(networksetup -getairportnetwork en0 | awk -F': ' '{print $2}')
            if [ "$SSID" = "" ]; then
              sketchybar --set $NAME icon=󰖪 label="Disconnected"
            else
              sketchybar --set $NAME icon=󰖩 label="$SSID"
            fi
          ''}"
    ''}

    # Custom plugins
    ${cfg.extraConfig}

    # Update all items
    sketchybar --update
  '';

in
{
  options.programs.sketchybar = {
    enable = mkEnableOption "SketchyBar status bar";

    package = mkOption {
      type = types.package;
      default = pkgs.sketchybar;
      description = "The sketchybar package to use.";
    };

    bar = {
      height = mkOption {
        type = types.int;
        default = 32;
        description = "Height of the bar in pixels.";
      };

      position = mkOption {
        type = types.enum [ "top" "bottom" ];
        default = "top";
        description = "Position of the bar on screen.";
      };

      color = mkOption {
        type = types.str;
        default = "0xff1e1e2e";
        description = "Background color in hex format (0xAARRGGBB).";
      };

      transparent = mkOption {
        type = types.bool;
        default = false;
        description = "Enable transparent bar with blur.";
      };

      padding = {
        left = mkOption {
          type = types.int;
          default = 10;
          description = "Left padding in pixels.";
        };

        right = mkOption {
          type = types.int;
          default = 10;
          description = "Right padding in pixels.";
        };
      };
    };

    defaults = {
      font = {
        family = mkOption {
          type = types.str;
          default = "Hack Nerd Font";
          description = "Default font family.";
        };

        style = mkOption {
          type = types.str;
          default = "Regular";
          description = "Default font style.";
        };

        size = mkOption {
          type = types.int;
          default = 14;
          description = "Default font size.";
        };
      };

      icon.color = mkOption {
        type = types.str;
        default = "0xffffffff";
        description = "Default icon color.";
      };

      label.color = mkOption {
        type = types.str;
        default = "0xffffffff";
        description = "Default label color.";
      };
    };

    modules = {
      clock = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable clock module.";
        };

        format = mkOption {
          type = types.str;
          default = "+%a %d %b %H:%M";
          description = "Date format string (date command format).";
        };

        updateFreq = mkOption {
          type = types.int;
          default = 10;
          description = "Update frequency in seconds.";
        };
      };

      battery = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable battery module.";
        };

        updateFreq = mkOption {
          type = types.int;
          default = 60;
          description = "Update frequency in seconds.";
        };
      };

      wifi = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable WiFi module.";
        };

        updateFreq = mkOption {
          type = types.int;
          default = 30;
          description = "Update frequency in seconds.";
        };
      };
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''
        sketchybar --add item custom_item left \
          --set custom_item label="Hello"
      '';
      description = "Extra shell commands to add to sketchybarrc.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    # Create sketchybar configuration
    environment.etc."sketchybar/sketchybarrc" = {
      source = configScript;
      mode = "0755";
    };

    # Launch Agent
    launchd.user.agents.sketchybar = {
      serviceConfig = {
        ProgramArguments = [ "${cfg.package}/bin/sketchybar" ];
        RunAtLoad = true;
        KeepAlive = true;
        ProcessType = "Interactive";
        EnvironmentVariables = {
          PATH = "${cfg.package}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        };
      };
    };
  };
}
