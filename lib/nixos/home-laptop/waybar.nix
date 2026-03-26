{ config, pkgs, lib, ... }:

let
  # Dark Industrial Palette — same as sketchybar/colors.sh
  surface = "#181c20";
  muted   = "#3a4048";
  subtle  = "#5a6370";
  text    = "#c8cdd4";
  bright  = "#e8ecf0";
  accent  = "#4d9fff";
  green   = "#3dd68c";
  yellow  = "#f0c060";
  red     = "#ff5f6d";
  purple  = "#a78bfa";
  cyan    = "#22d3ee";
in
{
  programs.waybar = {
    enable = true;

    settings = [{
      layer    = "top";
      position = "top";
      height   = 45;
      margin-top   = 6;
      margin-left  = 6;
      margin-right = 6;
      spacing  = 6;
      exclusive = true;

      modules-left   = [ "hyprland/workspaces" "custom/separator" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right  = [ "network" "memory" "cpu" "battery" "pulseaudio" ];

      # ── Workspaces ──────────────────────────────────────
      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
          "1" = "● TERM";
          "2" = "● WEB";
          "3" = "● K8S";
          "4" = "● MSG";
          "5" = "● 5";
          "6" = "● 6";
          "7" = "● 7";
          "8" = "● 8";
          "9" = "● 9";
          urgent  = "● !";
          default = "●";
        };
        sort-by-id = true;
        on-click   = "activate";
      };

      "custom/separator" = {
        format  = "│";
        tooltip = false;
      };

      # ── Active window ────────────────────────────────────
      "hyprland/window" = {
        max-length        = 40;
        separate-outputs  = true;
      };

      # ── Clock ────────────────────────────────────────────
      clock = {
        format         = "{:%H:%M - %a %d %b}";
        format-alt     = "{:%H:%M:%S}";
        interval       = 1;
        tooltip-format = "<tt>{calendar}</tt>";
        calendar = {
          mode   = "month";
          format = {
            months   = "<span color='${bright}'><b>{}</b></span>";
            days     = "<span color='${text}'>{}</span>";
            weekdays = "<span color='${subtle}'><b>{}</b></span>";
            today    = "<span color='${accent}'><b><u>{}</u></b></span>";
          };
        };
      };

      # ── Battery ──────────────────────────────────────────
      battery = {
        interval = 60;
        states   = { warning = 30; critical = 15; };
        format          = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-icons    = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        tooltip         = false;
      };

      # ── Volume ───────────────────────────────────────────
      pulseaudio = {
        format       = "{icon} {volume}%";
        format-muted = "󰝟 muted";
        format-icons = { default = [ "󰕿" "󰖀" "󰕾" ]; };
        on-click     = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        tooltip      = false;
      };

      # ── Network ──────────────────────────────────────────
      network = {
        interval           = 3;
        format-wifi        = "󰤨 {essid}";
        format-ethernet    = "󰈀 {ifname}";
        format-disconnected = "󰤭 offline";
        format-linked      = "󰤭 {ifname}";
        tooltip-format     = "󰇚 {bandwidthUpBytes}  󰕒 {bandwidthDownBytes}";
      };

      # ── Memory ───────────────────────────────────────────
      memory = {
        interval       = 5;
        format         = "◈ {used:.1f}GB";
        tooltip-format = "{used:.1f}GB / {total:.1f}GB";
      };

      # ── CPU ──────────────────────────────────────────────
      cpu = {
        interval = 3;
        format   = "⬡ {usage}%";
        tooltip  = false;
      };
    }];

    # ── Styles ──────────────────────────────────────────────────────────────
    style = ''
      * {
        font-family: "JetBrains Mono", monospace;
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
        margin: 0;
        padding: 0;
      }

      window#waybar {
        background: rgba(17, 20, 23, 0.80);
        border-radius: 10px;
        border: 1px solid rgba(0, 0, 0, 0.6);
        color: ${text};
      }

      /* ── Workspaces ── */
      #workspaces {
        padding: 0 4px;
      }

      #workspaces button {
        padding: 4px 12px;
        border-radius: 8px;
        color: ${subtle};
        background: transparent;
        font-size: 12px;
        font-weight: bold;
        transition: all 0.15s ease;
      }

      #workspaces button.active,
      #workspaces button.focused {
        color: ${accent};
        background: ${surface};
        border: 1px solid rgba(58, 64, 72, 0.6);
      }

      #workspaces button.urgent {
        color: ${red};
      }

      #workspaces button:hover,
      #workspaces button.visible {
        color: ${text};
        background: ${surface};
      }

      /* ── Separator ── */
      #custom-separator {
        color: ${muted};
        font-size: 14px;
        padding: 0 4px;
      }

      /* ── Active window ── */
      #window {
        color: ${text};
        font-size: 11px;
        padding: 0 4px;
      }

      /* ── Clock ── */
      #clock {
        color: ${bright};
        font-weight: bold;
        font-size: 12px;
        padding: 0 8px;
      }

      /* ── Right widgets base ── */
      #network,
      #memory,
      #cpu,
      #battery,
      #pulseaudio {
        padding: 4px 12px;
        border-radius: 8px;
        background: ${surface};
        border: 1px solid rgba(58, 64, 72, 0.5);
        font-size: 12px;
        margin: 6px 2px;
      }

      /* ── Per-widget colors (matching sketchybar) ── */
      #network   { color: ${cyan};   }
      #memory    { color: ${purple}; }
      #cpu       { color: ${accent}; }
      #pulseaudio { color: ${cyan};  }
      #pulseaudio.muted { color: ${muted}; }

      #battery           { color: ${green};  }
      #battery.warning   { color: ${yellow}; }
      #battery.critical  { color: ${red};    }
      #battery.charging  { color: ${green};  }
    '';
  };
}
