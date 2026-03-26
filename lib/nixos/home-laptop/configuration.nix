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

    # sops-nix module
    inputs.sops-nix.nixosModules.sops

    # Secrets
    (import ./secrets.nix { inherit username; })
  ] ++ profileImports;  # Import all profiles defined in hosts.nix

  # Import custom package overlays
  nixpkgs.overlays = [
    (import ../../packages/overlay.nix)
    # Fix for jaraco-test build failure
  ];

  nixpkgs.config.permittedInsecurePackages = [
      "mbedtls-2.28.10"
  ];
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
    homeMode = "711";
    extraGroups = [ "wheel" "docker" "video" "audio" "pipewire" ];
    shell = pkgs.zsh;
  };

  users.extraGroups.video.members = [ "frigate" "${username}" ];

  # Media group for arr stack services
  users.groups.media = {};
  users.groups.media.members = [ username "sonarr" "radarr" "bazarr" "jellyfin" "transmission" ];

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
    #timewarrior
    #taskwarrior3

    # AI Tools
    gemini-cli

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
    wavemon
    statix
    nil

    # Python for home automation
    #python310
    #pipenv
    python313
    python313Packages.adb-shell
    python313Packages.kegtron-ble

    # nodejs
    nodejs_24

    # Security
    trivy
    #seclists
    openvpn


    # DEPLOY TOOLS
    tenv
    #gcloud
    hcloud
    k9s
    kubectl
    kubernetes-helm
    cloudflared

    (writeShellScriptBin "install-hacs" ''
      #!/usr/bin/env bash
      cd /var/lib/hass/custom_components
      sudo -u hass git clone https://github.com/hacs/integration.git hacs
      sudo systemctl restart home-assistant.service
      echo "✅ HACS instalado"
    '')
  ];

  environment.localBinInPath = true;

  # ============================================================================
  # NH - Nix Helper
  # ============================================================================

  programs.nh = {
    enable = true;
    #clean.enable = true;
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
      "webostv" "ipp" "nmap_tracker" "local_todo"
      "manual_mqtt" "apple_tv" "mqtt" "google" "google_cloud" "workday"
      "wyoming" "piper" "mealie" "tailscale" "xiaomi_ble" "androidtv" "youtube" "homekit_controller" "kegtron" "github"
      "music_assistant" "mcp_server"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/hass 0755 hass hass -"
    "d /var/lib/hass/custom_components 0755 hass hass -"
    "d /var/lib/hass/.storage 0755 hass hass -"
    # Media directories for arr stack
    "d /home/${username}/media 0775 ${username} media -"
    "d /home/${username}/media/movies 0775 ${username} media -"
    "d /home/${username}/media/series 0775 ${username} media -"
    "d /home/${username}/media/downloads 0775 ${username} media -"
    "d /home/${username}/media/downloads/complete 0775 ${username} media -"
    "d /home/${username}/media/downloads/incomplete 0775 ${username} media -"
  ];
  
  systemd.services.home-assistant.serviceConfig = {
    ReadWritePaths = [ "/var/lib/hass" ];
  };

  # ============================================================================
  # FIREFLY III - Personal Finance
  # ============================================================================

  services.firefly-iii = lib.mkIf (hostConfig.features.fireflyIII or false) {
    enable = false;
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
  # ARR STACK - Media Management
  # ============================================================================

  services.flaresolverr = {
    enable = true;
    openFirewall = false;
  };

  services.prowlarr = lib.mkIf (hostConfig.features.prowlarr or false) {
    enable = true;
    openFirewall = false;
  };

  services.sonarr = lib.mkIf (hostConfig.features.sonarr or false) {
    enable = true;
    openFirewall = false;
  };

  services.radarr = lib.mkIf (hostConfig.features.radarr or false) {
    enable = true;
    openFirewall = false;
  };

  services.bazarr = lib.mkIf (hostConfig.features.bazarr or false) {
    enable = true;
    openFirewall = false;
  };

  services.jellyfin = lib.mkIf (hostConfig.features.jellyfin or false) {
    enable = true;
    openFirewall = false;
  };

  services.jellyseerr = lib.mkIf (hostConfig.features.jellyseerr or false) {
    enable = true;
    openFirewall = false;
    port = 5055;
  };

  services.transmission = lib.mkIf (hostConfig.features.transmission or false) {
    enable = true;
    openFirewall = false;
    settings = {
      download-dir = "/home/${username}/media/downloads/complete";
      incomplete-dir = "/home/${username}/media/downloads/incomplete";
      incomplete-dir-enabled = true;
      rpc-bind-address = "0.0.0.0";
      rpc-port = 9091;
      rpc-whitelist-enabled = false;
      rpc-host-whitelist-enabled = false;
      rpc-authentication-required = false;
      umask = 2;
      seed-ratio-limit = 0.0001;
      seed-ratio-limited = true;
    };
  };

  # ============================================================================
  # CADDY WEB SERVER
  # ============================================================================

  services.caddy = lib.mkIf (hostConfig.features.caddy or false) {
    enable = true;
    user = "caddy";
    group = "caddy";
    virtualHosts = lib.optionalAttrs config.services.firefly-iii.enable {
      "finance.f3rock.local" = {
        extraConfig = ''
          root * ${config.services.firefly-iii.package}/public
          php_fastcgi unix/${config.services.phpfpm.pools.firefly-iii.socket} {
          }
          file_server
          tls internal
        '';
      };
    } // {
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
      # Arr stack virtual hosts (HTTP only - internal network)
      "http://sonarr.f3rock.local" = {
        extraConfig = "reverse_proxy localhost:8989";
      };
      "http://radarr.f3rock.local" = {
        extraConfig = "reverse_proxy localhost:7878";
      };
      "http://prowlarr.f3rock.local" = {
        extraConfig = "reverse_proxy localhost:9696";
      };
      "http://bazarr.f3rock.local" = {
        extraConfig = "reverse_proxy localhost:6767";
      };
      "http://jellyfin.f3rock.local" = {
        extraConfig = "reverse_proxy localhost:8096";
      };
      "http://transmission.f3rock.local" = {
        extraConfig = "reverse_proxy localhost:9091";
      };
      "http://jellyseerr.f3rock.local" = {
        extraConfig = "reverse_proxy localhost:5055";
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
      enable = true;
      uri = "tcp://0.0.0.0:10200";
      voice = "es_AR-daniela-high";
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

 #--token 
  #services.cloudflared.tunnels = {
  #    "" = {
  #        credentials= "";
  #      };
  #};

  # ============================================================================
  # SYSTEMD SERVICES CONFIGURATION
  # ============================================================================

  systemd.services = {
    frigate.serviceConfig.SupplementaryGroups = [ "video" ];
    caddy.after = ["tailscale.service"];
    caddy.path = with pkgs; [ sudo coreutils nss.tools ];
    caddy.environment.JAVA_HOME = "${pkgs.openjdk}/lib/openjdk";
    sonarr.serviceConfig.SupplementaryGroups = [ "media" ];
    radarr.serviceConfig.SupplementaryGroups = [ "media" ];
    bazarr.serviceConfig.SupplementaryGroups = [ "media" ];
    jellyfin.serviceConfig.SupplementaryGroups = [ "media" ];
    transmission.serviceConfig.SupplementaryGroups = [ "media" ];

    arr-cleanup = {
      description = "Delete watched media older than 30 days";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = pkgs.writeShellScript "arr-cleanup" ''
          set -euo pipefail

          JELLYFIN_URL="http://localhost:8096"
          RADARR_URL="http://localhost:7878"
          SONARR_URL="http://localhost:8989"
          DAYS=30

          JELLYFIN_KEY_FILE="/etc/arr-stack/jellyfin-api-key"
          RADARR_KEY_FILE="/etc/arr-stack/radarr-api-key"
          SONARR_KEY_FILE="/etc/arr-stack/sonarr-api-key"

          if [[ ! -f "$JELLYFIN_KEY_FILE" ]]; then
            echo "Missing $JELLYFIN_KEY_FILE — skipping cleanup"
            exit 0
          fi

          JELLYFIN_KEY=$(cat "$JELLYFIN_KEY_FILE")
          RADARR_KEY=$(cat "$RADARR_KEY_FILE" 2>/dev/null || echo "")
          SONARR_KEY=$(cat "$SONARR_KEY_FILE" 2>/dev/null || echo "")
          THRESHOLD=$(date -d "-$DAYS days" --iso-8601=seconds)

          echo "=== arr-cleanup: deleting watched media older than $DAYS days ==="

          # ---- MOVIES ----
          echo "-- Movies --"
          ${pkgs.curl}/bin/curl -sf \
            "$JELLYFIN_URL/Items?IncludeItemTypes=Movie&IsPlayed=true&Recursive=true&Fields=Path,UserData,Id,Name" \
            -H "X-Emby-Token: $JELLYFIN_KEY" | \
          ${pkgs.jq}/bin/jq -r --arg threshold "$THRESHOLD" \
            '.Items[] | select(.UserData.LastPlayedDate != null) |
             select(.UserData.LastPlayedDate < $threshold) |
             [.Id, .Name, (.Path // "")] | @tsv' | \
          while IFS=$'\t' read -r jf_id name path; do
            if [[ -z "$path" || ! -f "$path" ]]; then
              echo "SKIP (no file): $name"
              continue
            fi
            echo "DELETE movie: $name ($path)"
            rm -f "$path"
            rmdir "$(dirname "$path")" 2>/dev/null || true
            if [[ -n "$RADARR_KEY" ]]; then
              radarr_id=$(${pkgs.curl}/bin/curl -sf \
                "$RADARR_URL/api/v3/movie?apikey=$RADARR_KEY" | \
                ${pkgs.jq}/bin/jq -r --arg title "$name" \
                  '.[] | select(.title == $title) | .id' | head -1)
              if [[ -n "$radarr_id" ]]; then
                ${pkgs.curl}/bin/curl -sf -X POST \
                  "$RADARR_URL/api/v3/command?apikey=$RADARR_KEY" \
                  -H "Content-Type: application/json" \
                  -d "{\"name\":\"RescanMovie\",\"movieId\":$radarr_id}" > /dev/null
              fi
            fi
          done

          # ---- EPISODES ----
          echo "-- Episodes --"
          ${pkgs.curl}/bin/curl -sf \
            "$JELLYFIN_URL/Items?IncludeItemTypes=Episode&IsPlayed=true&Recursive=true&Fields=Path,UserData,SeriesName" \
            -H "X-Emby-Token: $JELLYFIN_KEY" | \
          ${pkgs.jq}/bin/jq -r --arg threshold "$THRESHOLD" \
            '.Items[] | select(.UserData.LastPlayedDate != null) |
             select(.UserData.LastPlayedDate < $threshold) |
             [.SeriesName, (.Path // "")] | @tsv' | \
          while IFS=$'\t' read -r series_name path; do
            if [[ -z "$path" || ! -f "$path" ]]; then
              echo "SKIP (no file): $series_name"
              continue
            fi
            echo "DELETE episode: $series_name ($path)"
            rm -f "$path"
            rmdir "$(dirname "$path")" 2>/dev/null || true
          done

          if [[ -n "$SONARR_KEY" ]]; then
            ${pkgs.curl}/bin/curl -sf -X POST \
              "$SONARR_URL/api/v3/command?apikey=$SONARR_KEY" \
              -H "Content-Type: application/json" \
              -d '{"name":"RescanSeries"}' > /dev/null
          fi

          echo "=== arr-cleanup done ==="
        '';
      };
    };
  };

  systemd.timers.arr-cleanup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

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
    allowedTCPPorts = [ 22 53 853 443 8081 8123 80 8080 8083 8084 8085 8095 8097 25565 25575 18789
      # Arr stack
      7878 8989 9696 6767 8096 9091 51413 5055
    ];
    allowedUDPPorts = [ 53 67 68 853 546 547 25565 25575 18789
      51413 # Transmission torrents
    ];
    trustedInterfaces = ["tailscale0"];
    checkReversePath = "loose";
  };

  # ============================================================================
  # SYSTEM STATE VERSION
  # ============================================================================

  system.stateVersion = "25.11";
  }
