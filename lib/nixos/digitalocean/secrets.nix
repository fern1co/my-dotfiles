{ inputs, username, ... }:
{
  # Configure sops for DigitalOcean
  sops = {
    # Default sops file location
    defaultSopsFile = ../../../secrets/secrets.yaml;
    
    # Validate sops files during evaluation
    validateSopsFiles = false; # Set to true once secrets are properly set up
    
    # Age key file location
    age.keyFile = "/var/lib/sops-nix/key.txt";
    
    # Configure where secrets are created for DigitalOcean
    secrets = {
      # DigitalOcean SSH public key
      "digitalocean/ssh-public-key" = {
        owner = username;
        path = "/home/${username}/.ssh/authorized_keys";
        mode = "0600";
      };
    };
  };
}
