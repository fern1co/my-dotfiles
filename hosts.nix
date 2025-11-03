# hosts.nix - Centralized host configuration
# This file contains non-sensitive host information
# For sensitive data, use secrets.yaml with sops-nix
{
  digitalocean = {
    # Replace with your actual droplet IP
    # You can also use a domain name here
    hostname = "165.227.123.205";

    # SSH configuration
    sshUser = "ferock";
    deployUser = "root";

    # System configuration
    system = "x86_64-linux";
    username = "ferock";
  };

  # Add more hosts as needed
  # example = {
  #   hostname = "example.com";
  #   sshUser = "user";
  #   deployUser = "root";
  #   system = "x86_64-linux";
  #   username = "user";
  # };
}
