# Desktop profile - Base desktop environment configuration
{ config, pkgs, lib, ... }:

{
  # Bluetooth support
  hardware.bluetooth.enable = lib.mkDefault true;
  services.blueman.enable = lib.mkDefault false;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.hack
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-color-emoji
    corefonts
  ];

  fonts.fontDir.enable = true;
  fonts.fontconfig = {
    enable = true;
    antialias = true;

    hinting = {
      enable = true;
      autohint = false;
      style = "full";
    };

    subpixel = {
      lcdfilter = "default";
      rgba = "rgb";
    };

    defaultFonts = {
      monospace = ["Hack Nerd Font Mono"];
      sansSerif = ["FiraCode Nerd Font" "Hack Nerd Font"];
      serif = ["Noto Serif" "Noto Color Emoji"];
    };
  };

  # Desktop applications
  environment.systemPackages = with pkgs; [
    # Browsers
    brave

    # Communication
    discord
    slack

    # Productivity
    notion-app-enhanced

    # Media
    pavucontrol

    # File management
    nnn

    # Theme and appearance
    nwg-look
    catppuccin-gtk

    claude-code
    overskride
  ];

  # ZSH shell
  programs.zsh.enable = true;

  # GnuPG agent
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Light control
  programs.light.enable = lib.mkDefault true;
  programs.light.brightnessKeys.enable = lib.mkDefault true;

  # Fingerprint reader support
  services.fprintd.enable = lib.mkDefault false;
}
