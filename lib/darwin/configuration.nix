{ inputs, username }:{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  programs.zsh.enable = true;
  system.stateVersion = 5;
  users.users.${username} = {
    # isNormalUser = true;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };
  environment.systemPackages = with pkgs; [
        awscli
        aerospace
        skhd
        pritunl-client
        sketchybar
        doppler
        ngrok
        tenv
        python310
        # terragrunt
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

                alt-r = "mode resize";

                alt-shift-enter = "mode apps";
            };
        };
  };

  services.skhd.enable = true;
  services.sketchybar.enable = true;
}
