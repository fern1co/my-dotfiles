# Hyprland desktop profile
# Wayland compositor with modern features
{ config, pkgs, lib, ... }:

{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # X11 for compatibility
  services.xserver = {
    enable = true;
    xkb.layout = lib.mkDefault "us";
  };

  # Audio with Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Input devices
  services.libinput.enable = true;

  # XDG portals for Wayland
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Hyprland-specific packages
  environment.systemPackages = with pkgs; [
    # Wayland utilities
    swww              # Wallpaper daemon
    waybar            # Status bar
    wlogout           # Logout menu
    swaynotificationcenter  # Notifications
    swappy            # Screenshot editor
    wl-clipboard      # Clipboard
    grimblast         # Screenshots

    # Hyprland utilities
    hyprshade         # Blue light filter
    hypridle          # Idle daemon
    hyprlock          # Screen locker
    hyprsunset        # Sunset/sunrise
    hyprpolkitagent   # Polkit agent
    hyprsome          # Workspace management

    # Rofi for Wayland
    rofi-wayland

    # Desktop utilities
    pavucontrol       # Audio control
    playerctl         # Media control
    networkmanager_dmenu  # Network menu
  ];

  # Session variables for Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";  # Enable Wayland for Electron apps
  };

  # Polkit for privilege escalation
  security.polkit.enable = true;
}
