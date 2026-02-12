{ username }: { config, ... }:
{
  # Configure sops for home-laptop
  sops = {
    # Default sops file location
    defaultSopsFile = ../../../secrets/secrets.yaml;

    # Validate sops files during evaluation
    validateSopsFiles = false; # Set to true once secrets are properly set up

    # Age key file location
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

    # Configure where secrets are created for home-laptop
    secrets = {
      "api_keys/openclaw-gw-token" = {
        owner = username;
        mode = "0600";
      };
      "api_keys/telgram-bot-openclaw-token" = {
        owner = username;
        path = "/home/${username}/.secrets/telegram-bot-token";
        mode = "0600";
      };
      "api_keys/homeassistant-token" = {
        owner = username;
        path = "/home/${username}/.secrets/ha-token";
        mode = "0600";
      };

      #"api_keys/cloudflare-tunnel-home-token" = {
      #    owner = username;
      #    path = "/home/${username}/.secrets/cloudflare-tunnel-home-token";
      #    mode = "0600";
      #};

      # Example: GitHub token
      # "api_keys/github_token" = {
      #   owner = username;
      #   path = "/home/${username}/.config/github/token";
      #   mode = "0600";
      # };

      # Example: AWS credentials
      # "api_keys/aws_access_key" = {
      #   owner = username;
      # };
      # "api_keys/aws_secret_key" = {
      #   owner = username;
      # };

      # Add more secrets as needed for home-laptop
    };
  };
}
