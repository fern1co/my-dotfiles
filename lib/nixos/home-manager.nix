{pkgs, ...}:
{
    programs.gpg.enable = true;
    programs.chromium.enable = true;
    programs.hyprlock.enable = true;
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

      (pkgs.nerdfonts.override { fonts = [ "Hack" "FiraCode" ]; })
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
          {
            timeout = 1800; # 30min
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout= 3000; # 60min
            on-timeout= "systemctl suspend";
          }
        ];
      };
    };
}
