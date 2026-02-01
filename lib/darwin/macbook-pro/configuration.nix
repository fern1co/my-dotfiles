{ inputs, username }:{ pkgs, ... }:

let
  # Import host metadata
  hosts = import ../../../hosts.nix;
  hostConfig = hosts.darwin.macbook-pro;

  # Load profiles from host configuration
  profileLoader = import ../../profiles/default.nix;
  profileImports = profileLoader { profiles = hostConfig.profiles; };
in
{
  imports = [
    (import ../../shared/secrets-macbookpro.nix { inherit username; inherit inputs; })
  ] ++ profileImports; # Import all profiles defined in hosts.nix

  # allowUnfree is already set in base profile, no need to duplicate
  system.stateVersion = 5;
  system.primaryUser = username;
  users.users.${username} = {
    home = "/Users/${username}";
  };

  # macOS-specific packages not covered by profiles
  environment.systemPackages = with pkgs; [
    aerospace
    skhd
    sketchybar
    gemini-cli
    claude-code
    openvpn
    tenv
    hcloud
  ];

  security.pam.services.sudo_local.touchIdAuth = true;

  ids.gids.nixbld = 30000;

  services.aerospace = {
        enable = true;
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

  services.skhd.enable = true;
  services.sketchybar = {
    enable = true;
  };
}
