# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, username }:{ pkgs, config, ... }:

let
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
  security.rtkit.enable = true;
 
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    alsa.support32Bit = true;
  #  extraConfig.pipewire = {
  #    load-module module-native-protocol-unix auth-anonymous=1
  #    "context.modules" = [
  #      {
  #        name = "libpipewire-module-rtp-recv";
  #        args = { sap.listen = true; };
  #      }
  #    ];
  #  };
  };
 
  services.shairport-sync = {
    enable = true;
    openFirewall = true;
    arguments = "-o alsa";
    #arguments = "-v -o pw";
    # settings.general.name = "NixOS-Speakers";
  }; 
  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.

  #users.users.shairport = {
  #  isSystemUser = true;
  #};
  #users.groups.shairport = {};

  #USers.users.caddy = {
  #    isSystemUser = true;
  #    group = "caddy";
  #};
  #users.groups.caddy = {};

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
    extraGroups = [ "wheel" "docker" "video" "audio" "pipewire"];
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
    python312
    python312Packages.adb-shell
    python312Packages.kegtron-ble
    esphome 
    nss.tools
    openjdk
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

 

services = {
  snapserver = {
    enable = false;
    openFirewall = true;
    codec = "flac";
    streams = {
      pipewire  = {
        type = "pipe";
        location = "/run/snapserver/pipewire";
      };
      audio_pipe = {
        type = "pipe";
        location = "/tmp/snapfifo";
        query = {
          name = "Audio Stream";
          codec = "flac";
          sampleformat = "48000:16:2";
        };
      };
    };
    
  };
  avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
  adguardhome = {
    enable = true;
    port = 8081;
    mutableSettings = true;
    settings = {
      http = {
        # You can select any ip and port, just make sure to open firewalls where needed
        address = "0.0.0.0:8081";
      };
      dns = {
        bind_hosts = ["192.168.10.149" "127.0.0.1" ];
        upstream_dns = [
          "8.8.8.8:53"
          "1.1.1.1:53"
        ];
        rewrites = [
          { "'domain'" = "*.f3rock.local"; "'answer'" = "192.168.10.149"; }
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
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_33.txt"
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_48.txt"
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_57.txt"
      ];
    };
  };
  go2rtc = {
    enable = false;
    settings = {
      streams = {
          cam2 = "onvif://admin:kr4m3r072025@192.168.100.4:5000";
        };
    };
  };
  esphome = {
    enable = true;
    openFirewall = true;
  };
  firefly-iii = {
    enable = true;
    settings = {
      APP_KEY_FILE = "/appkeyfile";
    };
  };
  frigate = {
    enable = false;
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
  home-assistant = {
      enable = true;
      config = null;
      configWritable = true;
      # configDir = "/etc/home-assistant/";
      extraPackages = python3Packages: with python3Packages; [
        psycopg2
        adb-shell
      ];
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
        "xiaomi_ble"
        "androidtv"
        "youtube"
      ];
  };


  wyoming.piper.servers = {
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

  mealie = {
    enable = true;
    port = 8083;
  };

  tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "server";
    permitCertUid = "caddy";
    authKeyFile = "/home/${username}/tailscale_key";
  };

  #caddy = {
  #  enable = false;
  #  globalConfig = ''
  #      skip_install_trust
  #  '';
  #  user = "caddy";
  #  group = "caddy";

  #  virtualHosts = {
  #    "ha.${config.networking.hostName}.tail337b8f.ts.net" = {
  #        extraConfig = "reverse_proxy 127.0.0.1:8123";
  #      };
  #    "ha.f3rock.local" = {
  #      extraConfig = ''
  #        tls internal
  #        reverse_proxy localhost:8123
  #      '';
  #    };
  #    "test.f3rock.local" = {
  #      extraConfig = ''
  #        respond "Hello, world!"
  #      '';
  #    };
  #  };
  #};
};

systemd.tmpfiles.rules = [
  "p /tmp/snapfifo 0666 root root - -"
];

#systemd.user.services.snapcast-sink = {
#    wantedBy = [
#      "pipewire.service"
#    ];
#    after = [
#      "pipewire.service"
#    ];
#    bindsTo = [
#      "pipewire.service"
#    ];
#    path = with pkgs; [
#      gawk
#      pulseaudio
#    ];
#    script = ''
#      pactl load-module module-pipe-sink file=/run/snapserver/pipewire sink_name=Snapcast format=s16le rate=48000
#    '';
#  };
#systemd.user.services.snapclient-local = {
#    wantedBy = [
#      "pipewire.service"
#    ];
#    after = [
#      "pipewire.service"
#    ];
#    serviceConfig = {
#      ExecStart = "${pkgs.snapcast}/bin/snapclient -h ::1";
#    };
#  };
system.activationScripts.setup_keyfile = ''
    echo "mysecretpasswordmysecretpassword" > /appkeyfile
    chown firefly-iii:firefly-iii /appkeyfile
  '';

  systemd.services = {
    frigate = {
        serviceConfig = {
            SupplementaryGroups = [ "video" ];
      };
    };
    # caddy.after = ["tailscale.service"];
    # caddy.path = with pkgs; [ sudo coreutils nss.tools ];
    # caddy.environment.JAVA_HOME = "${pkgs.openjdk}/lib/openjdk";
 
    #adguardhome.after = ["network-online.target"];
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 53 853 443 8081 8123 80 8080 8083 8084 8085 ];
  networking.firewall.allowedUDPPorts = [ 53 67 68 853 546 547 ];
  networking.firewall.trustedInterfaces = ["tailscale0"];
  networking.firewall.checkReversePath = "loose";
 
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

