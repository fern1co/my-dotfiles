{ inputs, username }:{ pkgs, ... }:
let
  config = {};
  lib = pkgs.lib;
  in
{
  imports =
    [ # Include the results of the hardware scan.
      ./x86_64-linux.nix
      ../../shared/secrets.nix
    ];
  console = {
    keyMap = "la-latin1";
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  };
  hardware.bluetooth.enable = true;
  # Use the systemd-boot EFI boot loader.
#  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  networking.networkmanager.enable = true;
  networking.nameservers = [ "8.8.8.8" "4.4.4.4" ];
  # networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  programs.nix-ld.enable = true;

  # Set your time zone.
  fonts.packages = [
    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.fira-code
  ];
  time.timeZone = "America/Tegucigalpa";
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

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "es_US.UTF-8";
 
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];  

  nixpkgs.config.allowUnfree = true;

  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.f3rn1co = {
     isNormalUser = true;
     extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       tree
     ];
   };
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = [ "wheel" "docker"];
    shell = pkgs.zsh;
  };

  # programs.firefox.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    swww
    catppuccin
    seclists
    waybar
    rofi-wayland
    socat
    openvpn
    unzip
    nnn
    openssl
    hyprshade
    hypridle
    hyprlock
    hyprsunset
    parallel
    playerctl
    wlogout
    envsubst
    pavucontrol
    hyprpolkitagent
    swaynotificationcenter
    swappy
    wl-clipboard
    nodejs_22
    act
    discord
    brave
    bmon
    # inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins
    tmux
    grimblast
    fontconfig
    hyprsome
    overskride
    networkmanager_dmenu
    notion-app-enhanced
    azuredatastudio
    noto-fonts
    corefonts
    timewarrior
    taskwarrior3
    kbd
    cmake
    meson
    cpio
    gcc
    gnumake
    nwg-look
    nh
    catppuccin-gtk
    trivy
    slack
    opentofu
    pritunl-client
  ];

  environment.sessionVariables.NIXOS_OZONE_WL="1";
  environment.localBinInPath = true;

  virtualisation.docker.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/fernando-carbajal/my-dotfiles/";
  };
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.light.enable = true;
  programs.light.brightnessKeys.enable = true;


  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true; 
  programs.zsh.enable = true;

  # List services that you want to enable:
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # Configure keymap in X11
  services.xserver.xkb.layout = "latam";
  # services.xserver.xkb.variant = "latam";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  services.blueman.enable = false;

  services.actkbd.enable = true;
  services.fprintd.enable = true;
  services.fprintd.tod.enable = true;
  services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;
  security.pam.services.hyprlock = {
    fprintAuth = true;
  };
  services.avahi.enable = true;

  services.openvpn.servers = {
    n1co-dev-hubVPN = { config = '' config /home/fernando-carbajal/vpn_configs/vpnconfig.ovpn ''; autoStart = false; };
    n1co-dev-main-hubVPN = { config = '' config /home/fernando-carbajal/vpn_configs/vpnconfig-dev-main.ovpn ''; autoStart = false; };
    n1co-prod-main-hubVPN = { config = '' config /home/fernando-carbajal/vpn_configs/vpnconfig-prod-main.ovpn ''; autoStart = false; };
    n1co-prod-core-cross-hubVPN = { config = '' config /home/fernando-carbajal/vpn_configs/vpnconfig-prod-core-cross.ovpn ''; autoStart = false; };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?
}

