#!/usr/bin/env bash
# Setup script for sops-nix secrets management

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Check if running on macOS or Linux
OS_TYPE="$(uname)"
if [[ "$OS_TYPE" == "Darwin" ]]; then
    PLATFORM="darwin"
    KEY_DIR="$HOME/.config/sops/age"
    KEY_FILE="$KEY_DIR/keys.txt"
elif [[ "$OS_TYPE" == "Linux" ]]; then
    PLATFORM="linux"
    KEY_DIR="/var/lib/sops-nix"
    KEY_FILE="$KEY_DIR/key.txt"
else
    error "Unsupported operating system: $OS_TYPE"
    exit 1
fi

info "Setting up sops-nix secrets management on $PLATFORM..."

# Check if nix is available
if ! command -v nix &> /dev/null; then
    error "Nix is not installed or not in PATH"
    exit 1
fi

# Install required tools
info "Installing age and sops..."
if ! nix shell nixpkgs#age nixpkgs#sops --command true; then
    error "Failed to install age and sops"
    exit 1
fi

# Create key directory
info "Creating key directory: $KEY_DIR"
if [[ "$PLATFORM" == "linux" ]]; then
    sudo mkdir -p "$KEY_DIR"
else
    mkdir -p "$KEY_DIR"
fi

# Generate age key if it doesn't exist
if [[ ! -f "$KEY_FILE" ]]; then
    info "Generating new age key..."
    if [[ "$PLATFORM" == "linux" ]]; then
        nix shell nixpkgs#age --command age-keygen | sudo tee "$KEY_FILE" > /dev/null
        sudo chown root:root "$KEY_FILE"
        sudo chmod 600 "$KEY_FILE"
    else
        nix shell nixpkgs#age --command age-keygen -o "$KEY_FILE"
        chmod 600 "$KEY_FILE"
    fi
    success "Age key generated at $KEY_FILE"
else
    info "Age key already exists at $KEY_FILE"
fi

# Get public key
info "Getting public key..."
if [[ "$PLATFORM" == "linux" ]]; then
    PUBLIC_KEY=$(sudo nix shell nixpkgs#age --command age-keygen -y "$KEY_FILE")
else
    PUBLIC_KEY=$(nix shell nixpkgs#age --command age-keygen -y "$KEY_FILE")
fi

success "Your public key is: $PUBLIC_KEY"

# Check if secrets directory exists
SECRETS_DIR="$(dirname "$0")/../secrets"
if [[ ! -d "$SECRETS_DIR" ]]; then
    error "Secrets directory not found: $SECRETS_DIR"
    exit 1
fi

# Update .sops.yaml with the new key
SOPS_CONFIG="$SECRETS_DIR/.sops.yaml"
if [[ -f "$SOPS_CONFIG" ]]; then
    info "Updating .sops.yaml with your public key..."
    # Create backup
    cp "$SOPS_CONFIG" "$SOPS_CONFIG.backup"
    
    # Replace the placeholder key with the actual key
    sed -i.tmp "s/age1hl8zqn7j9k6j8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k/$PUBLIC_KEY/" "$SOPS_CONFIG"
    rm "$SOPS_CONFIG.tmp"
    
    success ".sops.yaml updated with your public key"
else
    error ".sops.yaml not found in $SECRETS_DIR"
    exit 1
fi

# Create initial secrets file if it doesn't exist
SECRETS_FILE="$SECRETS_DIR/secrets.yaml"
EXAMPLE_FILE="$SECRETS_DIR/secrets.yaml.example"

if [[ ! -f "$SECRETS_FILE" ]]; then
    if [[ -f "$EXAMPLE_FILE" ]]; then
        info "Creating initial secrets.yaml from example..."
        cp "$EXAMPLE_FILE" "$SECRETS_FILE"
        success "Created secrets.yaml from example"
    else
        warn "No example file found, creating empty secrets.yaml..."
        cat > "$SECRETS_FILE" << 'EOF'
# Encrypted secrets file
# Add your secrets here, then encrypt with: sops -e -i secrets.yaml

vpn: {}
api_keys: {}
environment: {}
EOF
    fi
fi

# Instructions for next steps
echo
info "Setup complete! Next steps:"
echo "1. Edit your secrets file:"
echo "   nix shell nixpkgs#sops --command sops $SECRETS_FILE"
echo
echo "2. Add your actual secrets (VPN configs, API keys, etc.)"
echo
echo "3. The file will be automatically encrypted when you save and exit"
echo
echo "4. Rebuild your system:"
if [[ "$PLATFORM" == "linux" ]]; then
    echo "   sudo nixos-rebuild switch --flake .#your-hostname"
else
    echo "   darwin-rebuild switch --flake .#aarch64"
fi
echo
info "Your public key for reference: $PUBLIC_KEY"
warn "Keep your private key secure and never commit it to the repository!"

exit 0