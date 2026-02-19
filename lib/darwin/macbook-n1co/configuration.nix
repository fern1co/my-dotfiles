{ inputs, username }:{ pkgs, system, ... }:

let
  # Determine which Darwin host we're using based on system architecture
  # This assumes this config is used by aarch64 and x86_64 generic hosts
  hosts = import ../../../hosts.nix;
  hostConfig = hosts.darwin.macbook-n1co;

  # Load profiles from host configuration
  profileLoader = import ../../profiles/default.nix;
  profileImports = profileLoader { profiles = hostConfig.profiles; };
in
{
  imports = [
    (import ../../shared/secrets-macbookpro.nix { inherit username; inherit inputs; })
  ] ++ profileImports; # Import all profiles defined in hosts.nix

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = 5;
  system.primaryUser = username;
  users.users.${username} = {
    home = "/Users/${username}";
  };

  # Darwin-specific packages
  environment.systemPackages = with pkgs; [
    awscli
    #aerospace
    skhd
    sketchybar
    doppler
    ngrok
    tenv
    python310
    cloudlens
    e1s
    bagels
    #llama-cpp
    claude-code
    gomplate
    yq-go
    packer
    yabai
    (google-cloud-sdk.withExtraComponents (with pkgs.google-cloud-sdk.components; [
      gke-gcloud-auth-plugin
    ]))
    gemini-cli
  ];

  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  ids.gids.nixbld = 30000;

  services.aerospace = {
        enable = false;
        settings = {
            default-root-container-layout = "tiles";
            default-root-container-orientation = "auto";
            gaps = {
                inner.horizontal = 10;
                inner.vertical = 10;
                outer.left = 8;
                outer.bottom = 8;
                outer.right = 8;
                outer.top = [
                    { monitor.main = 42; }
                    8
                ];
            };
            mode.main.binding = {
                alt-h = "focus --boundaries-action wrap-around-the-workspace left";
                alt-j = "focus --boundaries-action wrap-around-the-workspace down";
                alt-k = "focus --boundaries-action wrap-around-the-workspace up";
                alt-l = "focus --boundaries-action wrap-around-the-workspace right";

                alt-shift-j = "move left";
                alt-shift-k = "move down";
                alt-shift-l = "move up";
                alt-shift-semicolon = "move right";

                alt-minus = "resize smart -50";
                alt-equal = "resize smart +50";

                alt-d = "join-with left";
                alt-v = "join-with up";

                alt-f = "fullscreen";

                alt-s = "layout v_accordion"; # "layout stacking" in i3;;
                alt-w = "layout h_accordion"; # "layout tabbed" in i3
                alt-e = "layout tiles horizontal vertical";
                alt-shift-space = "layout floating tiling";

                alt-1 = "workspace 1";
                alt-2 = "workspace 2";
                alt-3 = "workspace 3";
                alt-4 = "workspace 4";
                alt-5 = "workspace 5";
                alt-6 = "workspace 6";
                alt-7 = "workspace 7";
                alt-8 = "workspace 8";
                alt-9 = "workspace 9";
                alt-0 = "workspace 10";

                alt-shift-1 = "move-node-to-workspace 1";
                alt-shift-2 = "move-node-to-workspace 2";
                alt-shift-3 = "move-node-to-workspace 3";
                alt-shift-4 = "move-node-to-workspace 4";
                alt-shift-5 = "move-node-to-workspace 5";
                alt-shift-6 = "move-node-to-workspace 6";
                alt-shift-7 = "move-node-to-workspace 7";
                alt-shift-8 = "move-node-to-workspace 8";
                alt-shift-9 = "move-node-to-workspace 9";
                alt-shift-0 = "move-node-to-workspace 10";

                alt-shift-c = "reload-config";

                #alt-r = "mode resize";

                # alt-shift-enter = "mode apps";
            };
            exec-on-workspace-change = [
              "/bin/bash"
              "-c"
              "sketchybar --trigger aerospace_workspace_change FOCUSED=$AEROSPACE_FOCUSED_WORKSPACE"
            ];
        };
  };

  # Habilitar yabai y skhd
  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    enableScriptingAddition = true; # Requiere deshabilitar SIP
    config = {
      # Layout
      layout = "bsp";

      # Padding y gaps
      top_padding    = 10;
      bottom_padding = 10;
      left_padding   = 10;
      right_padding  = 10;
      window_gap     = 10;

      # Mouse
      mouse_follows_focus = "off";
      focus_follows_mouse = "off";
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      mouse_drop_action = "swap";

      # Window
      window_placement = "second_child";
      window_opacity = "on";
      active_window_opacity = "1.0";
      normal_window_opacity = "0.95";
      window_shadow = "float";

      # Splits
      split_ratio = "0.50";
      auto_balance = "off";
    };

    extraConfig = ''
      # Cargar scripting addition (necesario para space focus, window move, etc.)
      sudo yabai --load-sa
      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"

      yabai -m config external_bar all:40:0

      # Reglas por aplicacion
      yabai -m rule --add app="^Configuracion del Sistema$" manage=off
      yabai -m rule --add app="^Calculator$" manage=off
      yabai -m rule --add app="^Finder$" manage=off
      yabai -m rule --add app="^Activity Monitor$" manage=off
      yabai -m rule --add app="^1Password$" manage=off

      # Aplicaciones que siempre flotan
      yabai -m rule --add app="^Raycast$" manage=off
      yabai -m rule --add title="^Preferences$" manage=off
      yabai -m rule --add title="^Settings$" manage=off

      # Borders (opcional, requiere borders plugin)
      # borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=5.0 &

      # k9s selector en floating centrado
      yabai -m rule --add title="k9s" manage=off grid=6:6:1:1:4:4
    '';
  };

  fonts.packages = with pkgs; [
    jetbrains-mono
  ];

  services.skhd.enable = true;
  services.sketchybar = {
    enable = true;
    package = pkgs.sketchybar;
  };
}
