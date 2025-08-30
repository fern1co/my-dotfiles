#!/usr/bin/env bash

# Dotfiles Restoration Script
# Restore dotfiles from various backup sources

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
BACKUP_ROOT="$HOME/.dotfiles-backups"
RESTORE_DIR="$HOME/dotfiles-restored"
CURRENT_DATE=$(date '+%Y%m%d-%H%M%S')

# Show available backups
list_backups() {
    info "Available backup sources:"
    echo ""
    
    # Local snapshots
    if ls "$BACKUP_ROOT"/snapshots/snapshot-*.tar.gz &>/dev/null; then
        echo "📁 Local Snapshots:"
        ls -lt "$BACKUP_ROOT"/snapshots/snapshot-*.tar.gz | head -10 | while read -r line; do
            echo "   $line"
        done
        echo ""
    fi
    
    # Git bundles
    if ls "$BACKUP_ROOT"/snapshots/dotfiles-*.bundle &>/dev/null; then
        echo "📦 Git Bundles:"
        ls -lt "$BACKUP_ROOT"/snapshots/dotfiles-*.bundle | head -10 | while read -r line; do
            echo "   $line"
        done
        echo ""
    fi
    
    # SOPS key backups
    if ls "$BACKUP_ROOT"/sops-keys/keys-*.txt &>/dev/null; then
        echo "🔑 SOPS Key Backups:"
        ls -lt "$BACKUP_ROOT"/sops-keys/keys-*.txt | head -5 | while read -r line; do
            echo "   $line"
        done
        echo ""
    fi
    
    # Git remote
    echo "🌐 Remote Repository:"
    echo "   https://github.com/fern1co/my-dotfiles.git"
    echo ""
}

# Restore from git remote
restore_from_remote() {
    info "Restoring from git remote repository..."
    
    local restore_path="$RESTORE_DIR/from-remote-$CURRENT_DATE"
    mkdir -p "$restore_path"
    
    # Clone from remote
    git clone https://github.com/fern1co/my-dotfiles.git "$restore_path"
    
    success "Remote repository cloned to: $restore_path"
    
    # Verify flake
    cd "$restore_path"
    if nix flake check --no-build &>/dev/null; then
        success "Flake validation passed"
    else
        warn "Flake validation failed - configuration may have issues"
    fi
}

# Restore from local snapshot
restore_from_snapshot() {
    local snapshot_file="$1"
    
    if [[ ! -f "$snapshot_file" ]]; then
        error "Snapshot file not found: $snapshot_file"
        return 1
    fi
    
    info "Restoring from local snapshot: $(basename "$snapshot_file")"
    
    local restore_path="$RESTORE_DIR/from-snapshot-$CURRENT_DATE"
    mkdir -p "$restore_path"
    
    # Extract snapshot
    tar -xzf "$snapshot_file" -C "$restore_path" --strip-components=1
    
    success "Snapshot restored to: $restore_path"
}

# Restore from git bundle
restore_from_bundle() {
    local bundle_file="$1"
    
    if [[ ! -f "$bundle_file" ]]; then
        error "Bundle file not found: $bundle_file"
        return 1
    fi
    
    info "Restoring from git bundle: $(basename "$bundle_file")"
    
    local restore_path="$RESTORE_DIR/from-bundle-$CURRENT_DATE"
    mkdir -p "$restore_path"
    
    cd "$restore_path"
    
    # Clone from bundle
    git clone "$bundle_file" .
    
    success "Bundle restored to: $restore_path"
    
    # Verify bundle integrity
    if git bundle verify "$bundle_file" &>/dev/null; then
        success "Bundle integrity verified"
    else
        warn "Bundle integrity check failed"
    fi
}

# Restore SOPS keys
restore_sops_keys() {
    local key_backup="$1"
    
    if [[ ! -f "$key_backup" ]]; then
        error "SOPS key backup not found: $key_backup"
        return 1
    fi
    
    info "Restoring SOPS keys from: $(basename "$key_backup")"
    
    local sops_dir="$HOME/.config/sops/age"
    mkdir -p "$sops_dir"
    
    # Backup existing key if present
    if [[ -f "$sops_dir/keys.txt" ]]; then
        warn "Existing SOPS key found - creating backup"
        cp "$sops_dir/keys.txt" "$sops_dir/keys.backup.$CURRENT_DATE"
    fi
    
    # Restore key
    cp "$key_backup" "$sops_dir/keys.txt"
    chmod 600 "$sops_dir/keys.txt"
    
    success "SOPS keys restored to: $sops_dir/keys.txt"
    
    # Test key
    if [[ -f "$sops_dir/keys.txt" ]] && age-keygen -y "$sops_dir/keys.txt" &>/dev/null; then
        success "SOPS key validation passed"
        info "Public key: $(age-keygen -y "$sops_dir/keys.txt")"
    else
        error "SOPS key validation failed"
        return 1
    fi
}

# Interactive restoration
interactive_restore() {
    echo "Interactive Dotfiles Restoration"
    echo "==============================="
    echo ""
    
    list_backups
    
    echo "Select restoration source:"
    echo "1) Git remote repository (latest)"
    echo "2) Local snapshot (select file)"
    echo "3) Git bundle (select file)"
    echo "4) SOPS keys only"
    echo "5) Full system restore (git + SOPS)"
    echo "6) Exit"
    echo ""
    
    read -p "Choose option (1-6): " choice
    
    case $choice in
        1)
            restore_from_remote
            ;;
        2)
            echo ""
            echo "Available snapshots:"
            ls -lt "$BACKUP_ROOT"/snapshots/snapshot-*.tar.gz 2>/dev/null | nl -w2 -s') ' || {
                error "No snapshots available"
                return 1
            }
            echo ""
            read -p "Select snapshot number: " num
            snapshot=$(ls -lt "$BACKUP_ROOT"/snapshots/snapshot-*.tar.gz 2>/dev/null | sed -n "${num}p" | awk '{print $NF}')
            if [[ -n "$snapshot" ]]; then
                restore_from_snapshot "$snapshot"
            else
                error "Invalid selection"
            fi
            ;;
        3)
            echo ""
            echo "Available bundles:"
            ls -lt "$BACKUP_ROOT"/snapshots/dotfiles-*.bundle 2>/dev/null | nl -w2 -s') ' || {
                error "No bundles available"
                return 1
            }
            echo ""
            read -p "Select bundle number: " num
            bundle=$(ls -lt "$BACKUP_ROOT"/snapshots/dotfiles-*.bundle 2>/dev/null | sed -n "${num}p" | awk '{print $NF}')
            if [[ -n "$bundle" ]]; then
                restore_from_bundle "$bundle"
            else
                error "Invalid selection"
            fi
            ;;
        4)
            echo ""
            echo "Available SOPS key backups:"
            ls -lt "$BACKUP_ROOT"/sops-keys/keys-*.txt 2>/dev/null | nl -w2 -s') ' || {
                error "No SOPS key backups available"
                return 1
            }
            echo ""
            read -p "Select key backup number: " num
            key_backup=$(ls -lt "$BACKUP_ROOT"/sops-keys/keys-*.txt 2>/dev/null | sed -n "${num}p" | awk '{print $NF}')
            if [[ -n "$key_backup" ]]; then
                restore_sops_keys "$key_backup"
            else
                error "Invalid selection"
            fi
            ;;
        5)
            info "Performing full system restore..."
            restore_from_remote
            
            # Find latest SOPS key backup
            latest_key=$(ls -t "$BACKUP_ROOT"/sops-keys/keys-*.txt 2>/dev/null | head -1)
            if [[ -n "$latest_key" ]]; then
                restore_sops_keys "$latest_key"
            else
                warn "No SOPS key backups found - you'll need to set up encryption keys manually"
            fi
            ;;
        6)
            info "Exiting..."
            exit 0
            ;;
        *)
            error "Invalid option"
            ;;
    esac
}

# Verify restored configuration
verify_restore() {
    local restore_path="$1"
    
    if [[ ! -d "$restore_path" ]]; then
        error "Restore path not found: $restore_path"
        return 1
    fi
    
    info "Verifying restored configuration..."
    
    cd "$restore_path"
    
    local errors=0
    
    # Check flake.nix
    if [[ ! -f "flake.nix" ]]; then
        error "flake.nix not found"
        ((errors++))
    else
        success "flake.nix found"
    fi
    
    # Validate flake if nix is available
    if command -v nix &>/dev/null; then
        if nix flake check --no-build &>/dev/null; then
            success "Flake validation passed"
        else
            error "Flake validation failed"
            ((errors++))
        fi
    else
        warn "Nix not available - skipping flake validation"
    fi
    
    # Check essential directories
    local required_dirs=("lib" "modules" "scripts")
    for dir in "${required_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            success "Directory $dir found"
        else
            error "Directory $dir missing"
            ((errors++))
        fi
    done
    
    if [[ $errors -eq 0 ]]; then
        success "🎉 Configuration verification passed!"
        echo ""
        info "Next steps:"
        echo "  1. Review restored configuration: cd $restore_path"
        echo "  2. Copy to desired location: cp -r $restore_path ~/my-dotfiles"
        echo "  3. Test build: nix build .#darwinConfigurations.aarch64.system"
        echo "  4. Apply: darwin-rebuild switch --flake .#aarch64"
        return 0
    else
        error "❌ Configuration verification failed with $errors error(s)"
        return 1
    fi
}

# Clean up old restore directories
cleanup_old_restores() {
    info "Cleaning up old restore directories..."
    
    # Keep only latest 5 restore directories
    if [[ -d "$RESTORE_DIR" ]]; then
        find "$RESTORE_DIR" -maxdepth 1 -type d -name "*-20*" -print0 | \
            sort -z | head -z -n -5 | xargs -0 -r rm -rf
        success "Cleanup completed"
    fi
}

# Show usage
show_usage() {
    echo "Dotfiles Restoration Script"
    echo "=========================="
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  interactive         - Interactive restoration menu (default)"
    echo "  list               - List available backups"
    echo "  remote             - Restore from git remote"
    echo "  snapshot <file>    - Restore from specific snapshot"
    echo "  bundle <file>      - Restore from specific git bundle"
    echo "  sops <file>        - Restore SOPS keys from backup"
    echo "  cleanup            - Clean up old restore directories"
    echo "  help               - Show this help"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Interactive menu"
    echo "  $0 remote                             # Restore from GitHub"
    echo "  $0 snapshot backup.tar.gz            # Restore specific snapshot"
    echo "  $0 sops keys-20231201-120000.txt     # Restore SOPS keys"
}

# Main execution
main() {
    mkdir -p "$RESTORE_DIR"
    
    case "${1:-interactive}" in
        "interactive"|"")
            interactive_restore
            ;;
        "list")
            list_backups
            ;;
        "remote")
            restore_from_remote
            verify_restore "$RESTORE_DIR/from-remote-$CURRENT_DATE"
            ;;
        "snapshot")
            if [[ -z "${2:-}" ]]; then
                error "Snapshot file required"
                show_usage
                exit 1
            fi
            restore_from_snapshot "$2"
            verify_restore "$RESTORE_DIR/from-snapshot-$CURRENT_DATE"
            ;;
        "bundle")
            if [[ -z "${2:-}" ]]; then
                error "Bundle file required"
                show_usage
                exit 1
            fi
            restore_from_bundle "$2"
            verify_restore "$RESTORE_DIR/from-bundle-$CURRENT_DATE"
            ;;
        "sops")
            if [[ -z "${2:-}" ]]; then
                error "SOPS key backup file required"
                show_usage
                exit 1
            fi
            restore_sops_keys "$2"
            ;;
        "cleanup")
            cleanup_old_restores
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            error "Unknown command: $1"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"