# Home-manager configuration for macbook-n1co
{ lib, inputs, username }:{ pkgs, ... }:
{
  imports = [
    ../../../modules/home-manager/tmux-sessionizer.nix
  ];

  # tmux session manager
  programs.tmuxSessionizer = {
    enable = true;
    projectDirs = [ "~/Documents/DevOps" "~/Documents/Development" ];
    enableFzf = true;
    enableRofi = false;
    enableSpotlight = true;
    defaultTerminal = "${pkgs.kitty}/bin/kitty";
  };

  # skhd config for yabai
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

    # Balance (igualar tamanos)
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
}
