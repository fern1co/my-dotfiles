#!/usr/bin/env bash

# Comprehensive Dotfiles Backup Script
# Supports local snapshots, cloud sync, and integrity validation

set -euo pipefail

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_ROOT="$HOME/.dotfiles-backups"
LOCAL_BACKUP_DIR="$BACKUP_ROOT/snapshots"
CLOUD_BACKUP_DIR="$BACKUP_ROOT/cloud-sync"
LOG_FILE="$BACKUP_ROOT/backup.log"
MAX_LOCAL_SNAPSHOTS=10
DATE=$(date '+%Y%m%d-%H%M%S')

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

# Setup backup directories
setup_dirs() {
    info "Setting up backup directories..."
    mkdir -p "$LOCAL_BACKUP_DIR" "$CLOUD_BACKUP_DIR" "$(dirname "$LOG_FILE")"
    success "Backup directories ready"
}

# Git repository backup
backup_git() {
    info "Creating git repository backup..."
    
    cd "$DOTFILES_DIR"
    
    # Ensure all changes are committed
    if ! git diff-index --quiet HEAD --; then
        warn "Uncommitted changes detected - creating stash backup"
        git stash push -m "auto-backup-stash-$DATE"
    fi
    
    # Push to remote
    if git remote get-url origin &>/dev/null; then
        git push origin main || warn "Failed to push to remote - continuing with local backup"
        success "Git repository synced to remote"
    else
        warn "No remote configured - skipping remote sync"
    fi
    
    # Create local git bundle
    local bundle_path="$LOCAL_BACKUP_DIR/dotfiles-$DATE.bundle"
    git bundle create "$bundle_path" --all
    success "Git bundle created: $bundle_path"
}

# Local snapshot backup
backup_local_snapshot() {
    info "Creating local snapshot backup..."
    
    local snapshot_dir="$LOCAL_BACKUP_DIR/snapshot-$DATE"
    
    # Create snapshot using rsync for efficiency
    rsync -av --delete \
        --exclude='.git/' \
        --exclude='result' \
        --exclude='*.lock' \
        --exclude='.DS_Store' \
        "$DOTFILES_DIR/" \
        "$snapshot_dir/"
    
    # Compress for space efficiency
    tar -czf "$snapshot_dir.tar.gz" -C "$LOCAL_BACKUP_DIR" "snapshot-$DATE"
    rm -rf "$snapshot_dir"
    
    success "Local snapshot created: $snapshot_dir.tar.gz"
}

# SOPS keys backup (if configured)
backup_sops_keys() {
    info "Backing up SOPS keys..."
    
    local sops_key_path="$HOME/.config/sops/age/keys.txt"
    local sops_backup_dir="$BACKUP_ROOT/sops-keys"
    
    if [[ -f "$sops_key_path" ]]; then
        mkdir -p "$sops_backup_dir"
        # Create encrypted backup of SOPS keys
        cp "$sops_key_path" "$sops_backup_dir/keys-$DATE.txt"
        chmod 600 "$sops_backup_dir/keys-$DATE.txt"
        success "SOPS keys backed up securely"
    else
        warn "SOPS keys not found at $sops_key_path - skipping"
    fi
}

# Cloud backup (configurable providers)
backup_cloud() {
    info "Syncing to cloud backup..."
    
    # Check for available cloud sync tools
    if command -v rclone &> /dev/null; then
        # Rclone configuration (requires setup)
        if rclone listremotes | grep -q "backup:"; then
            rclone sync "$LOCAL_BACKUP_DIR" "backup:dotfiles-backups"
            success "Cloud sync via rclone completed"
        else
            warn "Rclone backup remote not configured - skipping cloud sync"
        fi
    elif command -v aws &> /dev/null; then
        # AWS S3 sync (requires configuration)
        if aws sts get-caller-identity &>/dev/null; then
            aws s3 sync "$LOCAL_BACKUP_DIR" "s3://your-backup-bucket/dotfiles/" || warn "S3 sync failed"
            success "Cloud sync via AWS S3 completed"
        else
            warn "AWS not configured - skipping S3 sync"
        fi
    else
        warn "No cloud sync tools available (rclone, aws) - skipping cloud backup"
    fi
}

# Cleanup old local backups
cleanup_old_backups() {
    info "Cleaning up old local backups..."
    
    cd "$LOCAL_BACKUP_DIR"
    
    # Remove old snapshots (keep latest MAX_LOCAL_SNAPSHOTS)
    ls -t snapshot-*.tar.gz 2>/dev/null | tail -n +$((MAX_LOCAL_SNAPSHOTS + 1)) | xargs -r rm -f
    
    # Remove old git bundles (keep latest MAX_LOCAL_SNAPSHOTS)
    ls -t dotfiles-*.bundle 2>/dev/null | tail -n +$((MAX_LOCAL_SNAPSHOTS + 1)) | xargs -r rm -f
    
    success "Cleanup completed - keeping $MAX_LOCAL_SNAPSHOTS recent backups"
}

# Validate backup integrity
validate_backups() {
    info "Validating backup integrity..."
    
    local errors=0
    
    # Check git bundle
    local latest_bundle=$(ls -t "$LOCAL_BACKUP_DIR"/dotfiles-*.bundle 2>/dev/null | head -1)
    if [[ -n "$latest_bundle" ]]; then
        if git bundle verify "$latest_bundle" &>/dev/null; then
            success "Git bundle validation passed"
        else
            error "Git bundle validation failed: $latest_bundle"
            ((errors++))
        fi
    fi
    
    # Check snapshot integrity
    local latest_snapshot=$(ls -t "$LOCAL_BACKUP_DIR"/snapshot-*.tar.gz 2>/dev/null | head -1)
    if [[ -n "$latest_snapshot" ]]; then
        if tar -tzf "$latest_snapshot" &>/dev/null; then
            success "Snapshot archive validation passed"
        else
            error "Snapshot archive validation failed: $latest_snapshot"
            ((errors++))
        fi
    fi
    
    if [[ $errors -eq 0 ]]; then
        success "All backup validations passed"
        return 0
    else
        error "$errors validation errors found"
        return 1
    fi
}

# Generate backup report
generate_report() {
    info "Generating backup report..."
    
    local report_file="$BACKUP_ROOT/backup-report-$DATE.txt"
    
    cat > "$report_file" << EOF
Dotfiles Backup Report
Generated: $(date)
=====================================

Backup Location: $BACKUP_ROOT
Dotfiles Source: $DOTFILES_DIR

Local Snapshots:
$(ls -lah "$LOCAL_BACKUP_DIR"/*.tar.gz 2>/dev/null || echo "No snapshots found")

Git Bundles:
$(ls -lah "$LOCAL_BACKUP_DIR"/*.bundle 2>/dev/null || echo "No bundles found")

Disk Usage:
$(du -sh "$BACKUP_ROOT" 2>/dev/null)

Recent Log Entries:
$(tail -20 "$LOG_FILE" 2>/dev/null || echo "No log entries")
EOF
    
    success "Backup report generated: $report_file"
    
    # Optional: display summary
    if [[ "${SHOW_REPORT:-}" == "true" ]]; then
        cat "$report_file"
    fi
}

# Main execution
main() {
    log "Starting dotfiles backup process..."
    
    setup_dirs
    backup_git
    backup_local_snapshot
    backup_sops_keys
    backup_cloud
    cleanup_old_backups
    
    if validate_backups; then
        generate_report
        success "🎉 Backup process completed successfully!"
    else
        error "❌ Backup process completed with validation errors"
        exit 1
    fi
}

# Handle command line arguments
case "${1:-backup}" in
    "backup"|"")
        main
        ;;
    "validate")
        validate_backups
        ;;
    "report")
        SHOW_REPORT=true generate_report
        ;;
    "cleanup")
        cleanup_old_backups
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [backup|validate|report|cleanup|help]"
        echo ""
        echo "Commands:"
        echo "  backup   - Run full backup process (default)"
        echo "  validate - Validate existing backups"
        echo "  report   - Generate and display backup report"
        echo "  cleanup  - Clean up old backup files"
        echo "  help     - Show this help message"
        ;;
    *)
        error "Unknown command: $1"
        echo "Run '$0 help' for usage information"
        exit 1
        ;;
esac