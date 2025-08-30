#!/usr/bin/env bash

# SOPS Age Key Setup and Backup Script
# Sets up age encryption keys for sops-nix and creates secure backups

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

# Configuration
SOPS_DIR="$HOME/.config/sops/age"
KEY_FILE="$SOPS_DIR/keys.txt"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOPS_CONFIG="$DOTFILES_DIR/.sops.yaml"
BACKUP_DIR="$HOME/.dotfiles-backups/sops-keys"

# Check dependencies
check_dependencies() {
    info "Checking dependencies..."
    
    local missing=()
    
    if ! command -v age-keygen &> /dev/null; then
        missing+=("age")
    fi
    
    if ! command -v sops &> /dev/null; then
        missing+=("sops")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing dependencies: ${missing[*]}"
        echo ""
        echo "Install with:"
        echo "  nix shell nixpkgs#age nixpkgs#sops"
        echo "  # or"
        echo "  brew install age sops"
        exit 1
    fi
    
    success "Dependencies check passed"
}

# Generate age key
generate_age_key() {
    info "Generating age encryption key..."
    
    mkdir -p "$SOPS_DIR"
    
    if [[ -f "$KEY_FILE" ]]; then
        warn "Age key already exists at $KEY_FILE"
        read -p "Overwrite existing key? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Keeping existing key"
            return 0
        fi
    fi
    
    # Generate new key
    age-keygen -o "$KEY_FILE"
    chmod 600 "$KEY_FILE"
    
    success "Age key generated: $KEY_FILE"
}

# Display public key
show_public_key() {
    info "Your age public key:"
    echo ""
    age-keygen -y "$KEY_FILE"
    echo ""
}

# Update .sops.yaml with new public key
update_sops_config() {
    info "Updating .sops.yaml configuration..."
    
    local public_key
    public_key=$(age-keygen -y "$KEY_FILE")
    
    # Create or update .sops.yaml
    cat > "$SOPS_CONFIG" << EOF
keys:
  - &main_key $public_key

creation_rules:
  - path_regex: secrets\.yaml$
    key_groups:
    - age:
      - *main_key
EOF
    
    success ".sops.yaml updated with your public key"
}

# Create backup of keys
backup_keys() {
    info "Creating secure backup of age keys..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Copy key with timestamp
    local backup_file="$BACKUP_DIR/keys-$(date +%Y%m%d-%H%M%S).txt"
    cp "$KEY_FILE" "$backup_file"
    chmod 600 "$backup_file"
    
    success "Key backup created: $backup_file"
    
    # Show backup instructions
    echo ""
    warn "IMPORTANT: Store your age key backup securely!"
    echo "Consider:"
    echo "  • Password manager secure notes"
    echo "  • Encrypted USB drive"
    echo "  • Hardware security key"
    echo "  • Multiple secure locations"
    echo ""
    echo "Without this key, you cannot decrypt your secrets!"
}

# Setup secrets file
setup_secrets_file() {
    info "Setting up secrets file..."
    
    local secrets_file="$DOTFILES_DIR/secrets/secrets.yaml"
    local example_file="$DOTFILES_DIR/secrets/secrets.yaml.example"
    
    if [[ ! -f "$secrets_file" ]] && [[ -f "$example_file" ]]; then
        cp "$example_file" "$secrets_file"
        success "Copied example secrets file"
        
        # Encrypt the file
        sops -e -i "$secrets_file"
        success "Secrets file encrypted"
        
        echo ""
        info "To edit secrets, run: sops $secrets_file"
    elif [[ -f "$secrets_file" ]]; then
        success "Secrets file already exists"
    else
        warn "No example secrets file found - creating basic template"
        
        cat > "$secrets_file" << 'EOF'
# Encrypted secrets for dotfiles
# Edit with: sops secrets.yaml

# VPN Configurations
vpn:
  example-vpn: |
    # OpenVPN config content here
    # client
    # dev tun
    # ...

# API Keys and Tokens  
tokens:
  github: "your-github-token-here"
  example-api: "your-api-key-here"

# Environment Variables
env:
  DATABASE_URL: "postgresql://user:pass@host:port/db"
  SECRET_KEY: "your-secret-key-here"

# SSH Keys (if needed)
ssh:
  private_key: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    # Your SSH private key content
    -----END OPENSSH PRIVATE KEY-----
EOF
        
        # Encrypt the template
        sops -e -i "$secrets_file"
        success "Basic secrets template created and encrypted"
        
        echo ""
        info "Edit your secrets with: sops $secrets_file"
    fi
}

# Validate setup
validate_setup() {
    info "Validating SOPS setup..."
    
    local errors=0
    
    # Check key file
    if [[ ! -f "$KEY_FILE" ]]; then
        error "Age key file not found: $KEY_FILE"
        ((errors++))
    elif [[ $(stat -c %a "$KEY_FILE" 2>/dev/null || stat -f %Lp "$KEY_FILE") != "600" ]]; then
        error "Age key file has incorrect permissions (should be 600)"
        ((errors++))
    fi
    
    # Check .sops.yaml
    if [[ ! -f "$SOPS_CONFIG" ]]; then
        error ".sops.yaml not found: $SOPS_CONFIG"
        ((errors++))
    fi
    
    # Test decryption if secrets exist
    local secrets_file="$DOTFILES_DIR/secrets/secrets.yaml"
    if [[ -f "$secrets_file" ]]; then
        if sops -d "$secrets_file" &>/dev/null; then
            success "SOPS decryption test passed"
        else
            error "SOPS decryption test failed"
            ((errors++))
        fi
    fi
    
    if [[ $errors -eq 0 ]]; then
        success "🎉 SOPS setup validation passed!"
        return 0
    else
        error "❌ SOPS setup has $errors error(s)"
        return 1
    fi
}

# Show usage instructions
show_usage() {
    echo "SOPS Setup Complete!"
    echo "==================="
    echo ""
    echo "Next steps:"
    echo "  1. Edit secrets:    sops $DOTFILES_DIR/secrets/secrets.yaml"
    echo "  2. Test decryption: sops -d $DOTFILES_DIR/secrets/secrets.yaml" 
    echo "  3. Rebuild system:  darwin-rebuild switch --flake .#aarch64"
    echo ""
    echo "Key management:"
    echo "  • Backup location: $BACKUP_DIR"
    echo "  • Public key:      age-keygen -y $KEY_FILE"
    echo "  • View secrets:    sops -d secrets/secrets.yaml"
    echo "  • Edit secrets:    sops secrets/secrets.yaml"
    echo ""
    echo "For NixOS systems, also copy the key to:"
    echo "  sudo mkdir -p /var/lib/sops-nix"
    echo "  sudo cp $KEY_FILE /var/lib/sops-nix/key.txt"
    echo "  sudo chmod 600 /var/lib/sops-nix/key.txt"
}

# Main execution
main() {
    echo "SOPS Age Key Setup and Backup"
    echo "=============================="
    echo ""
    
    check_dependencies
    generate_age_key
    show_public_key
    update_sops_config
    backup_keys
    setup_secrets_file
    
    if validate_setup; then
        echo ""
        show_usage
    else
        error "Setup completed with errors - please review and fix issues"
        exit 1
    fi
}

# Handle command line arguments
case "${1:-setup}" in
    "setup"|"")
        main
        ;;
    "backup")
        backup_keys
        ;;
    "validate")
        validate_setup
        ;;
    "show-key")
        if [[ -f "$KEY_FILE" ]]; then
            show_public_key
        else
            error "No age key found. Run setup first."
            exit 1
        fi
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [setup|backup|validate|show-key|help]"
        echo ""
        echo "Commands:"
        echo "  setup      - Complete SOPS setup (default)"
        echo "  backup     - Backup existing keys"
        echo "  validate   - Validate current setup"
        echo "  show-key   - Display public key"
        echo "  help       - Show this help"
        ;;
    *)
        error "Unknown command: $1"
        exit 1
        ;;
esac