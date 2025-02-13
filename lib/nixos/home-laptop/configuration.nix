# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, username }:{ pkgs, ... }:

let
  config = {};
  lib = pkgs.lib;
  in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware.nix
    ];

  # Use the systemd-boot EFI boot loader.
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
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
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
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  nix.settings.experimental-features = [ "nix-command" "flakes" ];  
  
  nixpkgs.config.allowUnfree = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.admin = {
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
       tree
       git
       neovim
     ];
   };
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = [ "wheel" "docker" "video"];
    shell = pkgs.zsh;
  };

  users.extraGroups.video.members = ["frigate"  "${username}" ];
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
    inputs.anyrun.packages.${pkgs.system}.anyrun-with-all-plugins
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
    cheese
    mosquitto
    bc
    memos
  ];

  environment.sessionVariables.NIXOS_OZONE_WL="1";
  environment.localBinInPath = true;

  virtualisation.docker.enable = true;

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
  services.avahi.enable = true;

  services.adguardhome = {
    enable = true;
    port = 8081;
    mutableSettings = true;
    allowDHCP = true;
    settings = {
      http = {
        # You can select any ip and port, just make sure to open firewalls where needed
        address = "0.0.0.0:8081";
      };
      dns = {
        upstream_dns = [
          # Example config with quad9
          "8.8.8.8:53"
          "1.1.1.1:53"
          # Uncomment the following to use a local DNS service (e.g. Unbound)
          # Additionally replace the address & port as needed
          # "127.0.0.1:5335"
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        parental_enabled = false;  # Parental control-based DNS requests filtering.
        safe_search = {
          enabled = false;  # Enforcing "Safe search" option for search engines, when possible.
        };
      };
      # The following notation uses map
      # to not have to manually create {enabled = true; url = "";} for every filter
      # This is, however, fully optional
      filters = map(url: { enabled = true; url = url; }) [
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
      ];
    };
  };

  services.go2rtc = {
    enable = true;
    settings = {
      streams = {
          cam2 = "onvif://admin:kr4m3r072025@192.168.100.4:5000";
        };
    };
  };

  services.frigate = {
    enable = true;
    hostname = "homec.local";
    settings= {
        cameras = {
          frontcam = {
              ffmpeg = {
                inputs = [{
                    path = "rtsp://127.0.0.1:8554/cam2";
                    input_args = "preset-rtsp-restream";
                    roles = [ "record" "detect" ];
                  }];
              };
              detect = {
                  enabled = true;
                  width = 1280;
                  height = 720;
                  fps = 5;
              };
              live = {
                stream_name = "cam2";
              };
              # zones = {
              #   test_zone = {
              #   };
              # };
            };
          };
      };
  };

  systemd.services.frigate = {
      serviceConfig = {
          SupplementaryGroups = [ "video" ];
    };
  };

  services.home-assistant = {
      enable = true;
      config = null;
      configWritable = true;
      # configDir = "/etc/home-assistant/";
      extraComponents = [
        "isal"
        "esphome"
        "met"
        "radio_browser"
        "adguard"
        "device_tracker"
        "lg_thinq"
        "stream"
        "default_config"
        "androidtv_remote"
        "cast"
        "google_translate"
        "ibeacon"
        "bluetooth"
        "bluetooth_adapters"
        "bluetooth_tracker"
        "webostv"
        "ipp"
        "nmap_tracker"
        "local_todo"
        "manual_mqtt"
        "apple_tv"
        "mqtt"
        "google"
        "google_cloud"
        "workday"
        "wyoming"
        "piper"
        "mealie"
        "tailscale"
      ];
  };


  services.wyoming.piper.servers = {
    principal = {
      enable = true;
      uri = "tcp://0.0.0.0:10200";
      voice = "en_US-arctic-medium";
      speaker = 2;
    };
    principal2 = {
      enable = true;
      uri = "tcp://0.0.0.0:10201";
      voice = "en_US-amy-medium";
    };
  };

  services.mealie = {
    enable = true;
    port = 8083;
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    authKeyFile = "/home/${username}/tailscale_key";
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 53 853 443 8081 8123 80 8080 8083 8084 8085 ];
  networking.firewall.allowedUDPPorts = [ 53 67 68 853 546 547 ];
 
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

