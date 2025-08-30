{ username, inputs, ... }:
{
  # sops-nix module is imported at the system level

  # Configure sops for Darwin
  sops = {
    # Default sops file location
    defaultSopsFile = ../../secrets/secrets.yaml;
    
    # Validate sops files during evaluation
    validateSopsFiles = false; # Set to true once secrets are properly set up
    
    # Age key file location for Darwin
    age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
    
    # Configure where secrets are created
    secrets = {
      # Example secrets for Darwin systems
      # Add your Darwin-specific secrets here
      "example/api-key" = {
        owner = "${username}";
        path = "/Users/${username}/.config/secrets/api-key";
        mode = "0600";
      };
    };
  };
}
