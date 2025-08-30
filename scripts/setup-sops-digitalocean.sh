#!/usr/bin/env bash

# Setup SOPS for DigitalOcean droplet
# This script should be run on the DigitalOcean instance after deployment

set -euo pipefail

echo "🔐 Setting up SOPS for DigitalOcean..."

# Create the sops-nix directory
sudo mkdir -p /var/lib/sops-nix

# Check if age key already exists
if [ ! -f /var/lib/sops-nix/key.txt ]; then
    echo "📋 Age key not found. Please copy your age private key to /var/lib/sops-nix/key.txt"
    echo "You can do this by running:"
    echo "sudo nano /var/lib/sops-nix/key.txt"
    echo ""
    echo "Or copy from your local machine:"
    echo "scp ~/.config/sops/age/keys.txt root@your-droplet:/var/lib/sops-nix/key.txt"
    exit 1
fi

# Set proper permissions
sudo chmod 600 /var/lib/sops-nix/key.txt
sudo chown root:root /var/lib/sops-nix/key.txt

echo "✅ SOPS setup completed for DigitalOcean"
echo "🔄 Now rebuild your NixOS configuration:"
echo "sudo nixos-rebuild switch --flake /path/to/dotfiles#digitalocean"