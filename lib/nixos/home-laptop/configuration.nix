{ inputs, username }: { pkgs, config, ... }:

let
  lib = pkgs.lib;

  # Import host metadata
  hosts = import ../../../hosts.nix;
  hostConfig = hosts.home_laptop;

  # Load profiles from host configuration
  profileLoader = import ../../profiles/default.nix;
  profileImports = profileLoader { profiles = hostConfig.profiles; };

in
{
  imports = [
    # Hardware configuration
    ./hardware.nix

    # Secrets
    ../../shared/secrets.nix
  ] ++ profileImports;  # Import all profiles defined in hosts.nix

  # ============================================================================
  # BOOT CONFIGURATION
  # ============================================================================

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    devices = [ "nodev" ];
    efiSupport = true;
    useOSProber = true;
  };

  # ============================================================================
  # NETWORKING
  # ============================================================================

  networking.hostName = hostConfig.hostName;
  networking.networkmanager.enable = true;

  # ============================================================================
  # LOCALE AND TIME
  # ============================================================================

  time.timeZone = "America/Tegucigalpa";
  i18n.defaultLocale = "es_US.UTF-8";

  # Keyboard layout from host config
  services.xserver.xkb.layout = hostConfig.keyboardLayout or "us";
  console = {
    keyMap = "la-latin1";
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  };

  # ============================================================================
  # USERS
  # ============================================================================

  users.users.admin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ tree git neovim ];
  };

  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = [ "wheel" "docker" "video" "audio" "pipewire" ];
    shell = pkgs.zsh;
  };

  users.extraGroups.video.members = [ "frigate" "${username}" ];

  # Caddy user for homelab services
  users.users.caddy = {
    isSystemUser = true;
    group = "caddy";
    extraGroups = [ "firefly-iii" ];
  };
  users.groups.caddy = {};

  # ============================================================================
  # DEVELOPMENT PACKAGES (Host-specific additions)
  # ============================================================================

  environment.systemPackages = with pkgs; [
    # Task management
    timewarrior
    taskwarrior3

    # Database tools
    azuredatastudio

    # Cloud tools
    doctl

    # Build tools
    cmake
    meson
    cpio
    kbd

    # System tools
    nh
    cheese
    bc
    nss.tools
    openjdk

    # Python for home automation
    python312
    python312Packages.adb-shell
    python312Packages.kegtron-ble

    # Security
    trivy
    seclists
    openvpn
  ];

  environment.localBinInPath = true;

  # ============================================================================
  # NH - Nix Helper
  # ============================================================================

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    flake = "/home/fernando-carbajal/my-dotfiles/";
  };

  # ============================================================================
  # FINGERPRINT READER
  # ============================================================================

  services.fprintd = {
    enable = true;
    tod.enable = true;
    tod.driver = pkgs.libfprint-2-tod1-goodix;
  };

  services.actkbd.enable = true;

  # ============================================================================
  # HOMELAB SERVICES (Configured via feature flags)
  # ============================================================================

  # All homelab services are configured below with lib.mkIf based on feature flags

  # ============================================================================
  # ADGUARD HOME DNS
  # ============================================================================

  services.adguardhome = lib.mkIf (hostConfig.features.adguard or false) {
    enable = true;
    port = 8081;
    mutableSettings = true;
    settings = {
      http.address = "0.0.0.0:8081";
      dns = {
        bind_hosts = ["192.168.10.149" "127.0.0.1"];
        upstream_dns = [ "8.8.8.8:53" "1.1.1.1:53" ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        parental_enabled = false;
        safe_search.enabled = false;
        rewrites = [
          { domain = "*.f3rock.local"; answer = "192.168.10.149"; }
        ];
      };
      filters = map(url: { enabled = true; url = url; }) [
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_33.txt"
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_48.txt"
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_57.txt"
      ];
    };
  };

  # ============================================================================
  # HOME ASSISTANT
  # ============================================================================

  services.home-assistant = lib.mkIf (hostConfig.features.homeAssistant or false) {
    enable = true;
    configWritable = true;
    extraPackages = python3Packages: with python3Packages; [
      psycopg2
      adb-shell
    ];
    extraComponents = [
      "isal" "esphome" "met" "radio_browser" "adguard" "device_tracker"
      "lg_thinq" "stream" "default_config" "androidtv_remote" "cast"
      "google_translate" "ibeacon" "bluetooth" "bluetooth_adapters"
      "bluetooth_tracker" "webostv" "ipp" "nmap_tracker" "local_todo"
      "manual_mqtt" "apple_tv" "mqtt" "google" "google_cloud" "workday"
      "wyoming" "piper" "mealie" "tailscale" "xiaomi_ble" "androidtv" "youtube"
    ];
  };

  # ============================================================================
  # FIREFLY III - Personal Finance
  # ============================================================================

  services.firefly-iii = lib.mkIf (hostConfig.features.fireflyIII or false) {
    enable = true;
    virtualHost = null;
    group = "caddy";
    user = "caddy";
    settings = {
      APP_KEY_FILE = "/appkeyfile";
      APP_URL = "https://finance.f3rock.local";
      TZ = "America/Tegucigalpa";
      TRUSTED_PROXIES = "127.0.0.1,::1";
    };
  };

  # ============================================================================
  # CADDY WEB SERVER
  # ============================================================================

  services.caddy = lib.mkIf (hostConfig.features.caddy or false) {
    enable = true;
    user = "caddy";
    group = "caddy";
    virtualHosts = {
      "finance.f3rock.local" = {
        extraConfig = ''
          root * ${config.services.firefly-iii.package}/public
          php_fastcgi unix/${config.services.phpfpm.pools.firefly-iii.socket} {
          }
          file_server
          tls internal
        '';
      };
      "ha.${config.networking.hostName}.tail337b8f.ts.net" = {
        extraConfig = "reverse_proxy 127.0.0.1:8123";
      };
      "ha.f3rock.local" = {
        extraConfig = ''
          tls internal
          reverse_proxy localhost:8123
        '';
      };
      "test.f3rock.local" = {
        extraConfig = ''
          tls internal
          respond "Hello, world!"
        '';
      };
    };
  };

  # ============================================================================
  # TAILSCALE VPN
  # ============================================================================

  services.tailscale = lib.mkIf (hostConfig.features.tailscale or false) {
    enable = true;
    useRoutingFeatures = "server";
    permitCertUid = "caddy";
    authKeyFile = "/home/${username}/tailscale_key";
  };

  # ============================================================================
  # WYOMING PIPER (Voice synthesis)
  # ============================================================================

  services.wyoming.piper.servers = {
    principal = {
      enable = lib.mkDefault false;
      uri = "tcp://0.0.0.0:10200";
      voice = "en_US-arctic-medium";
      speaker = 2;
    };
    principal2 = {
      enable = lib.mkDefault false;
      uri = "tcp://0.0.0.0:10201";
      voice = "en_US-amy-medium";
    };
  };

  # ============================================================================
  # SHAIRPORT-SYNC (AirPlay receiver)
  # ============================================================================

  services.shairport-sync = {
    enable = lib.mkDefault true;
    openFirewall = true;
    arguments = "-o alsa";
  };

  # ============================================================================
  # GO2RTC (WebRTC streaming)
  # ============================================================================

  services.go2rtc = {
    enable = false;
    settings = {
      streams = {
        cam2 = "onvif://admin:kr4m3r072025@192.168.100.4:5000";
      };
    };
  };

  # ============================================================================
  # FRIGATE (NVR)
  # ============================================================================

  services.frigate = {
    enable = false;
    hostname = "homec.local";
    settings = {
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
          live.stream_name = "cam2";
        };
      };
    };
  };

  # ============================================================================
  # SYSTEMD SERVICES CONFIGURATION
  # ============================================================================

  systemd.services = {
    frigate.serviceConfig.SupplementaryGroups = [ "video" ];
    caddy.after = ["tailscale.service"];
    caddy.path = with pkgs; [ sudo coreutils nss.tools ];
    caddy.environment.JAVA_HOME = "${pkgs.openjdk}/lib/openjdk";
  };

  systemd.tmpfiles.rules = [
    "p /tmp/snapfifo 0666 root root - -"
  ];

  # ============================================================================
  # ACTIVATION SCRIPTS
  # ============================================================================

  system.activationScripts.setup_keyfile = ''
    echo "mysecretpasswordmysecretpassword" > /appkeyfile
    chown caddy:caddy /appkeyfile
    chmod -R 775 /var/lib/firefly-iii/storage
    chown -R caddy:caddy /var/lib/firefly-iii/storage
  '';

  # ============================================================================
  # FIREWALL
  # ============================================================================

  networking.firewall = {
    allowedTCPPorts = [ 53 853 443 8081 8123 80 8080 8083 8084 8085 ];
    allowedUDPPorts = [ 53 67 68 853 546 547 ];
    trustedInterfaces = ["tailscale0"];
    checkReversePath = "loose";
  };

  # ============================================================================
  # SYSTEM STATE VERSION
  # ============================================================================

  system.stateVersion = "24.11";
}
