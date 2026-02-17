{ config, pkgs, lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;

    # Main Hyprland configuration
    settings = {
      # Monitor configuration
      monitor = [
        "HDMI-A-1,1920x1080@60.0,0x0,1.0"
        "eDP-1,1366x768@60.06,1920x106,1.0"
      ];

      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      # Program definitions
      "$terminal" = "kitty";
      "$fileManager" = "nnn";
      "$menu" = "rofi -show drun";
      "$browser" = "chromium";
      "$mainMod" = "Alt";

      # Autostart
      exec-once = [
        "~/.config/hypr/scripts/wallpaper-autochange.sh"
      ];

      # General settings
      general = {
        gaps_in = 10;
        gaps_out = 20;
        border_size = 1;
        "col.active_border" = "rgb(ffb59d) rgb(55200c) 90deg";
        "col.inactive_border" = "rgb(55200c)";
        layout = "dwindle";
        resize_on_border = true;
      };

      # Decoration
      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 1.0;

        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      # Animations
      animations = {
        enabled = true;

        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];

        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      # Dwindle layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Master layout
      master = {
        new_status = "master";
      };

      # Misc
      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = true;
      };

      # Input configuration
      input = {
        kb_layout = "latam";
        kb_variant = ",,";
        numlock_by_default = true;
        follow_mouse = 1;
        mouse_refocus = false;

        touchpad = {
          natural_scroll = false;
          scroll_factor = 1.0;
          disable_while_typing = false;
        };

        sensitivity = 0;
      };

      # Gestures
      gestures = {
        # workspace_swipe = false;
      };

      # Device-specific config
      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      # Workspace assignments
      workspace = [
        "1, monitor:HDMI-A-1"
        "2, monitor:HDMI-A-1"
        "3, monitor:HDMI-A-1"
        "4, monitor:HDMI-A-1"
        "5, monitor:HDMI-A-1"
        "6, monitor:eDP-1"
        "7, monitor:eDP-1"
        "8, monitor:eDP-1"
        "9, monitor:eDP-1"
        "name:myhome"
      ];

      # Window rules
      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "opacity 0.8 0.8,class:^(kitty)$"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];

      # Keybindings
      bind = [
        # Display zoom
        "$mainMod SHIFT, mouse_down, exec, hyprctl keyword cursor:zoom_factor $(awk \"BEGIN {print $(hyprctl getoption cursor:zoom_factor | grep 'float:' | awk '{print $2}') + 0.5}\")"
        "$mainMod SHIFT, mouse_up, exec, hyprctl keyword cursor:zoom_factor $(awk \"BEGIN {print $(hyprctl getoption cursor:zoom_factor | grep 'float:' | awk '{print $2}') - 0.5}\")"
        "$mainMod SHIFT, Z, exec, hyprctl keyword cursor:zoom_factor 1"

        # Window management
        "$mainMod SHIFT, Q, exec, hyprctl activewindow | grep pid | tr -d 'pid:' | xargs kill"
        "$mainMod, F, fullscreen, 0"
        "$mainMod, M, fullscreen, 1"
        "$mainMod, T, togglefloating"

        # Launch applications
        "$mainMod, Q, exec, $terminal"
        "$mainMod, C, killactive,"
        "$mainMod, W, exec, $browser"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating,"
        "$mainMod, R, exec, $menu"
        "$mainMod, P, pseudo,"

        # Focus movement
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"

        # Window resizing
        "$mainMod SHIFT, l, resizeactive, 100 0"
        "$mainMod SHIFT, h, resizeactive, -100 0"
        "$mainMod SHIFT, j, resizeactive, 0 100"
        "$mainMod SHIFT, k, resizeactive, 0 -100"

        # Window swapping
        "$mainMod CTRL, h, swapwindow, l"
        "$mainMod CTRL, l, swapwindow, r"
        "$mainMod CTRL, k, swapwindow, u"
        "$mainMod CTRL, j, swapwindow, d"

        # Workspace switching
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move window to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Workspace navigation
        "$mainMod, Tab, workspace, m+1"
        "$mainMod SHIFT, Tab, workspace, m-1"

        # Special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Custom scripts
        "$mainMod SHIFT, B, exec, ~/.config/waybar/launch.sh"
        "$mainMod CTRL, B, exec, ~/.config/waybar/toggle.sh"
        "$mainMod CTRL, W, exec, ~/.config/hypr/scripts/waypaper.sh"
        "$mainMod SHIFT, T, exec, rofi-tmux"

        # Reload Hyprland
        "$mainMod CTRL, R, exec, hyprctl reload"
      ];

      # Multimedia bindings (with repeat)
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
      ];

      # Media controls (locked)
      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };

  # Scripts for Hyprland
  home.file.".config/hypr/scripts/wallpaper-autochange.sh" = {
    text = ''
      #!/usr/bin/env bash
      # Script to automatically change wallpaper every 15 minutes using waypaper

      while true; do
        # Wait 15 minutes (900 seconds)
        sleep 900

        # Change wallpaper randomly using waypaper
        waypaper --random
      done
    '';
    executable = true;
  };

  home.file.".config/hypr/scripts/waypaper.sh" = {
    text = ''
      #!/usr/bin/env bash
      waypaper --random
    '';
    executable = true;
  };

  home.file.".config/hypr/scripts/kyb-layout.sh" = {
    text = ''
      #!/bin/sh
      hyprctl switchxkblayout by-tech-gaming-keyboard next
    '';
    executable = true;
  };
}
