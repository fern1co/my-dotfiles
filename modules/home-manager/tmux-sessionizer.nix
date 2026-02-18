# Home-manager module for tmux-sessionizer
# A session manager that shows active tmux sessions and project directories
#
# Usage in home-manager configuration:
#   imports = [ ../../modules/home-manager/tmux-sessionizer.nix ];
#   programs.tmuxSessionizer = {
#     enable = true;
#     projectDirs = [ "~/DevOps" "~/projects" ];
#     enableSpotlight = true;  # macOS: adds app to Spotlight
#   };

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.tmuxSessionizer;
  isDarwin = pkgs.stdenv.isDarwin;

  # Get home directory from config
  homeDir = config.home.homeDirectory;

  # Expand ~ to absolute home path for each project directory
  expandedProjectDirs = map (dir:
    if lib.hasPrefix "~/" dir
    then homeDir + lib.removePrefix "~" dir
    else if dir == "~"
    then homeDir
    else dir
  ) cfg.projectDirs;

  # Core session listing logic (shared between fzf and rofi variants)
  sessionListScript = ''
    # Generar lista combinada
    {
      # Sesiones activas
      ${pkgs.tmux}/bin/tmux list-sessions -F "#{session_name}" 2>/dev/null | while read -r session; do
        echo "●|$session|"
      done || true

      # Directorios de proyectos
      find ${concatStringsSep " " expandedProjectDirs} -mindepth 1 -maxdepth ${toString cfg.maxDepth} -type d 2>/dev/null | while read -r dir; do
        name=$(basename "$dir" | tr . _)

        # Verificar si ya existe sesion
        if ${pkgs.tmux}/bin/tmux has-session -t="$name" 2>/dev/null; then
          echo "◉|$name|$dir"
        else
          echo "○|$name|$dir"
        fi
      done
    } | awk -F'|' '
      # Deduplicar: preferir entradas con path (◉ o ○ sobre ●)
      {
        key = $2
        if (!seen[key] || $3 != "") {
          entries[key] = $0
          seen[key] = 1
        }
      }
      END {
        for (key in entries) print entries[key]
      }
    ' | sort -t'|' -k2
  '';

  # FZF variant script
  fzfScript = pkgs.writeShellScriptBin "tmux-sessionizer" ''
    # tmux session manager - Muestra sesiones activas y directorios de proyectos

    # Generate session list and pipe to fzf
    (
    ${sessionListScript}
    ) | ${pkgs.fzf}/bin/fzf --delimiter='|' --with-nth=1,2 --no-preview > /tmp/tmux-sel 2>/dev/null

    # Leer seleccion
    if [[ ! -s /tmp/tmux-sel ]]; then
      rm -f /tmp/tmux-sel
      exit 0
    fi

    selected=$(cat /tmp/tmux-sel)
    rm -f /tmp/tmux-sel

    # Parsear seleccion
    IFS='|' read -r marker selected_name selected_path <<< "$selected"
    selected_name=$(echo "$selected_name" | xargs)  # trim

    # Crear sesion si es necesario
    if [[ "$marker" == "○" && -n "$selected_path" ]]; then
      if ! ${pkgs.tmux}/bin/tmux has-session -t="$selected_name" 2>/dev/null; then
        ${pkgs.tmux}/bin/tmux new-session -ds "$selected_name" -c "$selected_path"
      fi
    fi

    # Adjuntar o cambiar a la sesion
    if [[ -z $TMUX ]]; then
      ${pkgs.tmux}/bin/tmux attach-session -t "$selected_name"
    else
      ${pkgs.tmux}/bin/tmux switch-client -t "$selected_name"
    fi
  '';

  # Rofi variant script
  rofiScript = pkgs.writeShellScriptBin "rofi-tmux" ''
    # tmux session manager para rofi - Muestra sesiones activas y directorios de proyectos

    # Generate session list
    list=$(
    ${sessionListScript}
    )

    # Formatear para rofi (mostrar solo marcador y nombre)
    display_list=$(echo "$list" | awk -F'|' '{printf "%s %s\n", $1, $2}')

    # Mostrar en rofi
    selected=$(echo "$display_list" | ${pkgs.rofi}/bin/rofi -dmenu -i -p "tmux" -theme-str 'window {width: 40%;}')

    if [[ -z "$selected" ]]; then
      exit 0
    fi

    # Extraer nombre seleccionado (quitar marcador)
    selected_name=$(echo "$selected" | awk '{print $2}')

    # Buscar la entrada completa en la lista original
    entry=$(echo "$list" | grep "|$selected_name|")
    IFS='|' read -r marker name path <<< "$entry"

    # Crear sesion si es necesario
    if [[ "$marker" == "○" && -n "$path" ]]; then
      if ! ${pkgs.tmux}/bin/tmux has-session -t="$selected_name" 2>/dev/null; then
        ${pkgs.tmux}/bin/tmux new-session -ds "$selected_name" -c "$path"
      fi
    fi

    # Determinar terminal a usar
    terminal="''${TERMINAL:-${cfg.defaultTerminal}}"

    # Lanzar terminal con tmux
    if [[ -z $TMUX ]]; then
      # No estamos en tmux, abrir terminal
      $terminal -e ${pkgs.tmux}/bin/tmux attach-session -t "$selected_name" &
    else
      # Ya estamos en tmux, hacer switch
      ${pkgs.tmux}/bin/tmux switch-client -t "$selected_name"
    fi
  '';

  # macOS .app bundle for Spotlight integration
  spotlightApp = pkgs.stdenv.mkDerivation {
    name = "TmuxSessionizer";
    version = "1.0.0";

    dontUnpack = true;

    # Pass Nix store paths as environment variables
    inherit fzfScript;
    terminalPath = cfg.defaultTerminal;

    buildPhase = ''
      mkdir -p "$out/Applications/Tmux Sessionizer.app/Contents/MacOS"
      mkdir -p "$out/Applications/Tmux Sessionizer.app/Contents/Resources"

      # Create the executable script with proper Nix store paths
      cat > "$out/Applications/Tmux Sessionizer.app/Contents/MacOS/Tmux Sessionizer" << EOF
#!/bin/bash
# Tmux Sessionizer - Spotlight launcher
# Opens kitty with tmux-sessionizer (reuses existing instance)

SESSIONIZER="$fzfScript/bin/tmux-sessionizer"
TERMINAL="$terminalPath"

# Launch kitty with single-instance (reuses existing kitty window)
"\$TERMINAL" --single-instance -e "\$SESSIONIZER" &
EOF

      chmod +x "$out/Applications/Tmux Sessionizer.app/Contents/MacOS/Tmux Sessionizer"

      # Create Info.plist
      cat > "$out/Applications/Tmux Sessionizer.app/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Tmux Sessionizer</string>
    <key>CFBundleIdentifier</key>
    <string>com.nixos.tmux-sessionizer</string>
    <key>CFBundleName</key>
    <string>Tmux Sessionizer</string>
    <key>CFBundleDisplayName</key>
    <string>Tmux Sessionizer</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSUIElement</key>
    <false/>
</dict>
</plist>
PLIST
    '';

    installPhase = ''
      # Already created in buildPhase
      true
    '';

    meta = with lib; {
      description = "Tmux session manager - Spotlight app";
      platforms = platforms.darwin;
    };
  };

in
{
  options.programs.tmuxSessionizer = {
    enable = mkEnableOption "tmux session manager with fzf/rofi integration";

    projectDirs = mkOption {
      type = types.listOf types.str;
      default = [ "~/projects" ];
      example = [ "~/DevOps" "~/development" "~/work" ];
      description = ''
        List of directories to scan for projects.
        These directories will be searched for subdirectories to create tmux sessions from.
      '';
    };

    maxDepth = mkOption {
      type = types.int;
      default = 1;
      description = ''
        Maximum depth to search within project directories.
        1 = only immediate subdirectories, 2 = subdirectories and their children, etc.
      '';
    };

    enableFzf = mkOption {
      type = types.bool;
      default = true;
      description = "Enable the fzf-based terminal version (tmux-sessionizer command)";
    };

    enableRofi = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the rofi-based launcher version (rofi-tmux command)";
    };

    defaultTerminal = mkOption {
      type = types.str;
      default = "${pkgs.kitty}/bin/kitty";
      example = "\${pkgs.alacritty}/bin/alacritty";
      description = ''
        Default terminal emulator to use when launching tmux from rofi.
        Only used when TERMINAL environment variable is not set.
      '';
    };

    shellAlias = mkOption {
      type = types.str;
      default = "tm";
      example = "ts";
      description = "Shell alias for tmux-sessionizer command";
    };

    enableShellAlias = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to create a shell alias for tmux-sessionizer";
    };

    enableSpotlight = mkOption {
      type = types.bool;
      default = false;
      description = ''
        (macOS only) Create a .app bundle that Spotlight can index.
        The app will be available at ~/Applications/Tmux Sessionizer.app
        and can be launched via Spotlight search.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = mkMerge [
      (mkIf cfg.enableFzf [ fzfScript ])
      (mkIf cfg.enableRofi [ rofiScript ])
    ];

    # Ensure fzf is available when fzf variant is enabled
    programs.fzf.enable = mkIf cfg.enableFzf true;

    # Add shell alias
    home.shellAliases = mkIf (cfg.enableShellAlias && cfg.enableFzf) {
      ${cfg.shellAlias} = "tmux-sessionizer";
    };

    # macOS Spotlight integration - copy .app to ~/Applications (not symlink)
    # Spotlight doesn't index symlinks to Nix store properly
    home.activation = mkIf (cfg.enableSpotlight && isDarwin && cfg.enableFzf) {
      copyTmuxSessionizerApp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        APP_SRC="${spotlightApp}/Applications/Tmux Sessionizer.app"
        APP_DST="$HOME/Applications/Tmux Sessionizer.app"

        # Remove old version if exists
        rm -rf "$APP_DST"

        # Create directory structure
        mkdir -p "$APP_DST/Contents/MacOS"
        mkdir -p "$APP_DST/Contents/Resources"

        # Copy files (not symlink)
        cp "$APP_SRC/Contents/Info.plist" "$APP_DST/Contents/Info.plist"
        cp "$APP_SRC/Contents/MacOS/Tmux Sessionizer" "$APP_DST/Contents/MacOS/Tmux Sessionizer"
        chmod +x "$APP_DST/Contents/MacOS/Tmux Sessionizer"

        # Force Spotlight to reindex
        mdimport "$APP_DST" 2>/dev/null || true
      '';
    };
  };
}
