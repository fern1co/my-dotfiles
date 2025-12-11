{ config, inputs, ... }:
{
  # sops-nix module is imported at the system level

  # Configure sops
  sops = {
    # Default sops file location
    defaultSopsFile = ../../secrets/secrets.yaml;
    
    # Validate sops files during evaluation
    validateSopsFiles = false; # Set to true once secrets are properly set up
    
    # Age key file location
    age.keyFile = "/var/lib/sops-nix/key.txt";
    
    # Configure where secrets are created
    secrets = {
      # VPN configuration files
      "vpn/n1co-dev" = {
        owner = config.users.users.fernando-carbajal.name;
        path = "/home/fernando-carbajal/vpn_configs/vpnconfig.ovpn";
        mode = "0600";
      };
      "vpn/n1co-dev-main" = {
        owner = config.users.users.fernando-carbajal.name;
        path = "/home/fernando-carbajal/vpn_configs/vpnconfig-dev-main.ovpn";
        mode = "0600";
      };
      "vpn/n1co-prod-main" = {
        owner = config.users.users.fernando-carbajal.name;
        path = "/home/fernando-carbajal/vpn_configs/vpnconfig-prod-main.ovpn";
        mode = "0600";
      };
      "vpn/n1co-prod-core-cross" = {
        owner = config.users.users.fernando-carbajal.name;
        path = "/home/fernando-carbajal/vpn_configs/vpnconfig-prod-core-cross.ovpn";
        mode = "0600";
      };
    };
  };
}
