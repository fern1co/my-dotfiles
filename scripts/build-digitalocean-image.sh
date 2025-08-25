#!/usr/bin/env bash

# Build DigitalOcean image script
# This script builds a NixOS image suitable for DigitalOcean droplets

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}=== DigitalOcean NixOS Image Builder ===${NC}"
echo ""

# Check if we're in the right directory
if [[ ! -f "$FLAKE_DIR/flake.nix" ]]; then
    echo -e "${RED}Error: flake.nix not found in $FLAKE_DIR${NC}"
    echo "Please run this script from the dotfiles repository root or scripts directory."
    exit 1
fi

# Check if nix is available
if ! command -v nix &> /dev/null; then
    echo -e "${RED}Error: Nix is not installed or not in PATH${NC}"
    exit 1
fi

# Check if flakes are enabled
if ! nix eval --expr '1' &> /dev/null; then
    echo -e "${YELLOW}Warning: Nix flakes may not be enabled${NC}"
    echo "You may need to enable flakes with: nix-env -iA nixpkgs.nixFlakes"
    echo ""
fi

echo -e "${BLUE}Building DigitalOcean image...${NC}"
echo "This may take several minutes depending on your system and network connection."
echo ""

# Build the image
echo -e "${YELLOW}Running: nix build .#digitalOceanImage${NC}"
cd "$FLAKE_DIR"

if nix build .#digitalOceanImage --show-trace; then
    echo ""
    echo -e "${GREEN}✓ Image built successfully!${NC}"
    
    # Find the result
    if [[ -L "result" ]]; then
        IMAGE_PATH=$(readlink -f result)
        IMAGE_SIZE=$(du -h "$IMAGE_PATH" | cut -f1)
        
        echo -e "${GREEN}Image location: $IMAGE_PATH${NC}"
        echo -e "${GREEN}Image size: $IMAGE_SIZE${NC}"
        echo ""
        
        echo -e "${BLUE}=== Next Steps ===${NC}"
        echo "1. Upload the image to DigitalOcean:"
        echo "   - Go to DigitalOcean Control Panel > Images > Custom Images"
        echo "   - Upload the image file from: $IMAGE_PATH"
        echo "   - Choose 'Ubuntu' as the distribution (closest match)"
        echo ""
        echo "2. Create a droplet using the custom image"
        echo ""
        echo "3. SSH into your droplet with:"
        echo "   ssh fernando-carbajal@your-droplet-ip"
        echo ""
        echo -e "${YELLOW}Note: Make sure to add your SSH public key to the configuration${NC}"
        echo "Edit lib/nixos/digitalocean/configuration.nix and add your SSH key."
    else
        echo -e "${YELLOW}Warning: Could not find result symlink${NC}"
    fi
else
    echo -e "${RED}✗ Image build failed${NC}"
    echo ""
    echo "Try the following troubleshooting steps:"
    echo "1. Update flake inputs: nix flake update"
    echo "2. Check the configuration for syntax errors"
    echo "3. Ensure you have enough disk space for the build"
    echo "4. Run with more verbose output: nix build .#digitalOceanImage -v"
    exit 1
fi

echo ""
echo -e "${GREEN}=== Build Complete ===${NC}"