{ username, inputs, ... }:
{
  # sops-nix module is imported at the system level

  # Configure sops for macbookpro
  sops = {
    # Default sops file location
    defaultSopsFile = ../../secrets/secrets.yaml;
    
    # Validate sops files during evaluation
    validateSopsFiles = false; # Set to true once secrets are properly set up
    
    # Age key file location for Darwin
    age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
    
    # Configure where secrets are created - macbookpro specific
    secrets = {
      # macbookpro-specific secrets
      "macbookpro/ssh-key" = {
        owner = "${username}";
        path = "/Users/${username}/.ssh/macbookpro_rsa";
        mode = "0600";
      };
      "macbookpro/api-key" = {
        owner = "${username}";
        path = "/Users/${username}/.config/secrets/macbookpro-api-key";
        mode = "0600";
      };
    };
  };
}
