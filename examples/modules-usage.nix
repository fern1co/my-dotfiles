# Ejemplo de uso de módulos personalizados
# Este archivo muestra cómo usar los módulos creados en tu configuración

{ config, pkgs, lib, ... }:

{
  # ============================================================================
  # IMPORTAR MÓDULOS
  # ============================================================================

  imports = [
    # Opción 1: Importar módulos individuales
    ../modules/darwin/aerospace.nix
    ../modules/darwin/sketchybar.nix
    ../modules/darwin/yabai.nix

    # Opción 2: Importar todo el directorio (usa default.nix)
    # ../modules/darwin

    # Módulos shared (funcionan en Darwin y NixOS)
    ../modules/shared/dev-environment.nix
  ];

  # ============================================================================
  # EJEMPLO 1: AeroSpace Window Manager (Darwin)
  # ============================================================================

  programs.aerospace = {
    enable = true;
    startAtLogin = true;

    # Configurar gaps
    gaps = {
      inner = 12;
      outer = 12;
    };

    # Layout por defecto
    autoLayout = "tiles";

    # Workspaces a configurar
    workspaces = [ 1 2 3 4 5 6 ];

    # Keybindings personalizados
    keybindings = {
      # Focus con vim keys
      "cmd-h" = "focus left";
      "cmd-j" = "focus down";
      "cmd-k" = "focus up";
      "cmd-l" = "focus right";

      # Mover ventanas
      "cmd-shift-h" = "move left";
      "cmd-shift-j" = "move down";
      "cmd-shift-k" = "move up";
      "cmd-shift-l" = "move right";

      # Aplicaciones
      "cmd-enter" = "exec-and-forget open -a kitty";
      "cmd-shift-enter" = "exec-and-forget open -a Firefox";

      # Workspaces
      "cmd-1" = "workspace 1";
      "cmd-2" = "workspace 2";
      "cmd-3" = "workspace 3";
      "cmd-4" = "workspace 4";
      "cmd-5" = "workspace 5";
      "cmd-6" = "workspace 6";

      # Mover a workspace
      "cmd-shift-1" = "move-node-to-workspace 1";
      "cmd-shift-2" = "move-node-to-workspace 2";
      "cmd-shift-3" = "move-node-to-workspace 3";
    };

    # Configuración TOML avanzada
    extraConfig = ''
      # Resize mode
      [mode.resize.binding]
      h = "resize width -50"
      l = "resize width +50"
      k = "resize height -50"
      j = "resize height +50"
      esc = "mode main"

      # Rules para aplicaciones específicas
      [[on-window-detected]]
      if.app-id = 'com.apple.Terminal'
      run = 'move-node-to-workspace 1'

      [[on-window-detected]]
      if.app-id = 'com.google.Chrome'
      run = 'move-node-to-workspace 2'

      [[on-window-detected]]
      if.app-id = 'com.microsoft.VSCode'
      run = 'move-node-to-workspace 3'
    '';
  };

  # ============================================================================
  # EJEMPLO 2: SketchyBar Status Bar (Darwin)
  # ============================================================================

  programs.sketchybar = {
    enable = true;

    bar = {
      height = 32;
      position = "top";
      color = "0xff1e1e2e";  # Catppuccin Mocha
      transparent = true;
      padding = {
        left = 16;
        right = 16;
      };
    };

    defaults = {
      font = {
        family = "Hack Nerd Font";
        style = "Regular";
        size = 14;
      };
      icon.color = "0xffcdd6f4";
      label.color = "0xffcdd6f4";
    };

    modules = {
      clock = {
        enable = true;
        format = "+%a %d %b %H:%M";
        updateFreq = 10;
      };

      battery = {
        enable = true;
        updateFreq = 60;
      };

      wifi = {
        enable = true;
        updateFreq = 30;
      };
    };

    extraConfig = ''
      # CPU module
      sketchybar --add item cpu right \
        --set cpu \
          update_freq=5 \
          icon=󰻠 \
          script="sketchybar --set cpu label=\"$(ps -A -o %cpu | awk '{s+=$1} END {print s \"%\"}')\"" \

      # Memory module
      sketchybar --add item memory right \
        --set memory \
          update_freq=5 \
          icon=󰍛 \
          script="sketchybar --set memory label=\"$(memory_pressure | grep 'System-wide memory free percentage:' | awk '{print 100-$5\"%\"}')\"" \
    '';
  };

  # ============================================================================
  # EJEMPLO 3: Yabai Window Manager (Darwin)
  # ============================================================================

  services.yabai = {
    enable = false;  # Deshabilitado porque usamos aerospace

    layout = "bsp";
    windowPlacement = "second_child";

    gaps = {
      top = 12;
      bottom = 12;
      left = 12;
      right = 12;
      window = 12;
    };

    windowOpacity = {
      enable = true;
      active = 1.0;
      normal = 0.95;
    };

    border = {
      enable = false;  # Requiere SIP deshabilitado
      width = 4;
      activeColor = "0xff89b4fa";
      normalColor = "0xff313244";
    };

    mouseFollowsFocus = false;
    focusFollowsMouse = "off";
    autoBalance = false;
    splitRatio = 0.5;

    disabledApps = [
      "System Preferences"
      "System Settings"
      "Calculator"
      "Archive Utility"
      "App Store"
    ];

    extraConfig = ''
      # Reglas específicas
      yabai -m rule --add app="Finder" manage=off
      yabai -m rule --add app="Activity Monitor" manage=off
      yabai -m rule --add app="Spotify" space=5
    '';
  };

  # ============================================================================
  # EJEMPLO 4: Development Environment (Shared)
  # ============================================================================

  programs.devEnvironment = {
    enable = true;

    # Lenguajes a instalar
    languages = [
      "javascript"
      "python"
      "rust"
      "go"
      "nix"
    ];

    # Herramientas a instalar
    tools = {
      vcs = true;        # git, gh, lazygit
      editors = true;    # neovim
      terminals = true;  # tmux
      utils = true;      # ripgrep, fd, jq, bat, etc
      network = true;    # curl, wget, httpie
      containers = true; # docker-compose
    };

    # Paquetes adicionales
    extraPackages = with pkgs; [
      kubectl
      terraform
      ansible
    ];

    # Shell aliases personalizados
    shellAliases = {
      # Git
      g = "git";
      gs = "git status";
      gp = "git pull";
      gc = "git commit";
      gco = "git checkout";
      glog = "git log --oneline --graph --all";

      # Modern replacements
      ls = "eza --icons";
      ll = "eza -la --icons";
      lt = "eza --tree --icons";
      cat = "bat";

      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      # Kubernetes
      k = "kubectl";
      kgp = "kubectl get pods";
      kgs = "kubectl get services";

      # Docker
      d = "docker";
      dc = "docker-compose";
      dps = "docker ps";
    };

    # Shell functions
    shellFunctions = {
      # Crear directorio y cd
      mkcd = ''
        mkdir -p "$1" && cd "$1"
      '';

      # Git commit rápido
      gcom = ''
        git add .
        git commit -m "$1"
      '';

      # Find and kill process
      killport = ''
        lsof -ti:$1 | xargs kill -9
      '';

      # Extract archives
      extract = ''
        case $1 in
          *.tar.gz) tar xzf $1 ;;
          *.tar.bz2) tar xjf $1 ;;
          *.zip) unzip $1 ;;
          *.rar) unrar x $1 ;;
          *) echo "Unknown archive type" ;;
        esac
      '';
    };

    # Variables de entorno
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      PAGER = "bat";
      MANPAGER = "nvim +Man!";

      # Node.js
      NODE_OPTIONS = "--max-old-space-size=8192";

      # Go
      GOPATH = "$HOME/go";
      GO111MODULE = "on";

      # Rust
      CARGO_HOME = "$HOME/.cargo";
      RUSTUP_HOME = "$HOME/.rustup";
    };

    enableGitConfig = true;
  };

  # ============================================================================
  # EJEMPLO 5: Firewall Profiles (Solo NixOS)
  # ============================================================================

  # Descomentar en NixOS:
  # networking.firewall.profiles = {
  #   enable = true;
  #
  #   activeProfiles = [
  #     "web"      # Puertos 80, 443, 8080, 8443
  #     "ssh"      # Puerto 22
  #     "homelab"  # Puertos 8080-8085, 8123
  #   ];
  #
  #   customRules = {
  #     minecraft = {
  #       tcp = [ 25565 ];
  #       udp = [ 19132 ];
  #       description = "Minecraft server";
  #     };
  #     plex = {
  #       tcp = [ 32400 ];
  #       udp = [ ];
  #       description = "Plex Media Server";
  #     };
  #   };
  #
  #   trustedInterfaces = [ "tailscale0" "docker0" ];
  #   blockPing = false;
  #   logRefusedConnections = true;
  # };

  # ============================================================================
  # COMBINACIÓN CON PROFILES
  # ============================================================================

  # Los módulos se pueden combinar con profiles:
  # imports = [
  #   ../../lib/profiles/base
  #   ../../lib/profiles/development
  #   ../../modules/darwin/aerospace.nix
  # ];
  #
  # # El profile proporciona la base
  # # Los módulos añaden funcionalidad específica configurable
}
