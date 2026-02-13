# Example configuration for Sure personal finance app
#
# To enable Sure in your NixOS configuration:
#
# 1. Generate a secret key:
#    openssl rand -hex 64
#
# 2. Add this configuration to your host config (e.g., lib/nixos/home-laptop/configuration.nix)
#
# 3. Rebuild your system:
#    sudo nixos-rebuild switch --flake .#your-hostname

{ config, ... }:

{
  # Enable the homelab profile if not already enabled
  # imports = [ ../../profiles/homelab ];

  # Enable and configure Sure
  services.sure = {
    enable = true;

    # Port to run the web server on
    port = 3000;

    # Bind address - use "127.0.0.1" for localhost only,
    # or "0.0.0.0" to expose on all interfaces
    bind = "127.0.0.1";

    # Secret key base for Rails encryption
    # Generate with: openssl rand -hex 64
    # IMPORTANT: Keep this secret and don't commit to git!
    # Consider using sops-nix or agenix for secret management
    secretKeyBase = "your-64-character-hex-string-here";

    # Set to true if using HTTPS reverse proxy (e.g., Caddy, Nginx)
    assumeSsl = false;

    # Git repository and revision (optional, uses defaults if not specified)
    # repository = "https://github.com/we-promise/sure.git";
    # revision = "main";
  };

  # Optional: Configure Caddy as reverse proxy for HTTPS
  services.caddy = {
    enable = true;
    virtualHosts."finance.yourdomain.com" = {
      extraConfig = ''
        reverse_proxy localhost:3000
      '';
    };
  };

  # Optional: Open firewall for external access
  # networking.firewall.allowedTCPPorts = [ 80 443 ];
}

# Example with sops-nix for secret management:
# {
#   sops.secrets.sure-secret-key = {
#     sopsFile = ./secrets.yaml;
#     owner = "sure";
#   };
#
#   services.sure = {
#     enable = true;
#     secretKeyBase = config.sops.secrets.sure-secret-key.path;
#     # ... other config
#   };
# }
