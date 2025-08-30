#!/usr/bin/env bash

# Backup Monitoring and Health Check Script
# Monitors backup health, validates integrity, and sends alerts

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
LOG_FILE="$BACKUP_ROOT/monitoring.log"
HEALTH_REPORT="$BACKUP_ROOT/health-report.json"
ALERT_THRESHOLD_DAYS=7  # Alert if no backup in X days
MIN_BACKUPS=3           # Minimum number of backups to maintain

# Logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check backup age
check_backup_age() {
    info "Checking backup freshness..."
    
    local latest_snapshot latest_bundle backup_age
    local alerts=()
    
    # Check latest snapshot
    if latest_snapshot=$(ls -t "$BACKUP_ROOT"/snapshots/snapshot-*.tar.gz 2>/dev/null | head -1); then
        backup_age=$(( ($(date +%s) - $(stat -c %Y "$latest_snapshot" 2>/dev/null || stat -f %m "$latest_snapshot")) / 86400 ))
        
        if [[ $backup_age -gt $ALERT_THRESHOLD_DAYS ]]; then
            alerts+=("Latest snapshot is $backup_age days old")
        else
            success "Latest snapshot is $backup_age days old"
        fi
    else
        alerts+=("No local snapshots found")
    fi
    
    # Check latest git bundle
    if latest_bundle=$(ls -t "$BACKUP_ROOT"/snapshots/dotfiles-*.bundle 2>/dev/null | head -1); then
        backup_age=$(( ($(date +%s) - $(stat -c %Y "$latest_bundle" 2>/dev/null || stat -f %m "$latest_bundle")) / 86400 ))
        
        if [[ $backup_age -gt $ALERT_THRESHOLD_DAYS ]]; then
            alerts+=("Latest git bundle is $backup_age days old")
        else
            success "Latest git bundle is $backup_age days old"
        fi
    else
        alerts+=("No git bundles found")
    fi
    
    # Return alerts
    printf '%s\n' "${alerts[@]}"
}

# Check backup count
check_backup_count() {
    info "Checking backup count..."
    
    local snapshot_count bundle_count
    local alerts=()
    
    snapshot_count=$(ls "$BACKUP_ROOT"/snapshots/snapshot-*.tar.gz 2>/dev/null | wc -l)
    bundle_count=$(ls "$BACKUP_ROOT"/snapshots/dotfiles-*.bundle 2>/dev/null | wc -l)
    
    if [[ $snapshot_count -lt $MIN_BACKUPS ]]; then
        alerts+=("Only $snapshot_count snapshots available (minimum: $MIN_BACKUPS)")
    else
        success "$snapshot_count snapshots available"
    fi
    
    if [[ $bundle_count -lt $MIN_BACKUPS ]]; then
        alerts+=("Only $bundle_count git bundles available (minimum: $MIN_BACKUPS)")
    else
        success "$bundle_count git bundles available"
    fi
    
    printf '%s\n' "${alerts[@]}"
}

# Validate backup integrity
validate_backup_integrity() {
    info "Validating backup integrity..."
    
    local alerts=()
    local checked=0 failed=0
    
    # Validate git bundles
    for bundle in "$BACKUP_ROOT"/snapshots/dotfiles-*.bundle; do
        [[ -f "$bundle" ]] || continue
        ((checked++))
        
        if ! git bundle verify "$bundle" &>/dev/null; then
            alerts+=("Corrupted git bundle: $(basename "$bundle")")
            ((failed++))
        fi
    done
    
    # Validate snapshots
    for snapshot in "$BACKUP_ROOT"/snapshots/snapshot-*.tar.gz; do
        [[ -f "$snapshot" ]] || continue
        ((checked++))
        
        if ! tar -tzf "$snapshot" &>/dev/null; then
            alerts+=("Corrupted snapshot: $(basename "$snapshot")")
            ((failed++))
        fi
    done
    
    if [[ $failed -eq 0 ]]; then
        success "All $checked backups passed integrity validation"
    else
        error "$failed of $checked backups failed validation"
    fi
    
    printf '%s\n' "${alerts[@]}"
}

# Check disk space
check_disk_space() {
    info "Checking backup disk space..."
    
    local backup_size disk_free usage_percent
    local alerts=()
    
    if [[ -d "$BACKUP_ROOT" ]]; then
        backup_size=$(du -sm "$BACKUP_ROOT" 2>/dev/null | cut -f1)
        disk_free=$(df -m "$BACKUP_ROOT" 2>/dev/null | awk 'NR==2 {print $4}')
        
        if [[ $disk_free -lt 1000 ]]; then  # Less than 1GB free
            alerts+=("Low disk space: ${disk_free}MB free")
        else
            success "Disk space: ${disk_free}MB free, backups using ${backup_size}MB"
        fi
        
        # Calculate usage percentage
        if [[ $backup_size -gt 0 && $disk_free -gt 0 ]]; then
            usage_percent=$((backup_size * 100 / (backup_size + disk_free)))
            if [[ $usage_percent -gt 80 ]]; then
                alerts+=("High backup disk usage: ${usage_percent}%")
            fi
        fi
    else
        alerts+=("Backup directory not found: $BACKUP_ROOT")
    fi
    
    printf '%s\n' "${alerts[@]}"
}

# Check SOPS keys
check_sops_keys() {
    info "Checking SOPS configuration..."
    
    local alerts=()
    
    # Check age key
    if [[ -f "$HOME/.config/sops/age/keys.txt" ]]; then
        if [[ $(stat -c %a "$HOME/.config/sops/age/keys.txt" 2>/dev/null || stat -f %Lp "$HOME/.config/sops/age/keys.txt") == "600" ]]; then
            success "SOPS age key found with correct permissions"
        else
            alerts+=("SOPS age key has incorrect permissions")
        fi
    else
        alerts+=("SOPS age key not found")
    fi
    
    # Check key backups
    local key_backup_count
    key_backup_count=$(ls "$BACKUP_ROOT"/sops-keys/keys-*.txt 2>/dev/null | wc -l)
    
    if [[ $key_backup_count -eq 0 ]]; then
        alerts+=("No SOPS key backups found")
    elif [[ $key_backup_count -lt 2 ]]; then
        alerts+=("Only $key_backup_count SOPS key backup available (recommended: ≥2)")
    else
        success "$key_backup_count SOPS key backups available"
    fi
    
    printf '%s\n' "${alerts[@]}"
}

# Check remote repository status
check_remote_status() {
    info "Checking remote repository status..."
    
    local alerts=()
    local dotfiles_dir
    
    # Find dotfiles directory
    dotfiles_dir="$(dirname "$(dirname "${BASH_SOURCE[0]}")")"
    
    if [[ -d "$dotfiles_dir/.git" ]]; then
        cd "$dotfiles_dir"
        
        # Check if we can reach remote
        if ! git ls-remote origin &>/dev/null; then
            alerts+=("Cannot reach remote repository")
        else
            # Check for unpushed commits
            local unpushed
            unpushed=$(git log origin/main..HEAD --oneline 2>/dev/null | wc -l)
            
            if [[ $unpushed -gt 0 ]]; then
                alerts+=("$unpushed unpushed commits to remote")
            else
                success "Repository synced with remote"
            fi
        fi
    else
        alerts+=("Not in a git repository")
    fi
    
    printf '%s\n' "${alerts[@]}"
}

# Generate health report
generate_health_report() {
    info "Generating health report..."
    
    local timestamp
    timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    
    # Collect all alerts
    local all_alerts=()
    mapfile -t age_alerts < <(check_backup_age)
    mapfile -t count_alerts < <(check_backup_count)
    mapfile -t integrity_alerts < <(validate_backup_integrity)
    mapfile -t disk_alerts < <(check_disk_space)
    mapfile -t sops_alerts < <(check_sops_keys)
    mapfile -t remote_alerts < <(check_remote_status)
    
    all_alerts+=("${age_alerts[@]}" "${count_alerts[@]}" "${integrity_alerts[@]}" "${disk_alerts[@]}" "${sops_alerts[@]}" "${remote_alerts[@]}")
    
    # Calculate health score (0-100)
    local total_checks=6
    local failed_checks=0
    
    [[ ${#age_alerts[@]} -gt 0 ]] && ((failed_checks++))
    [[ ${#count_alerts[@]} -gt 0 ]] && ((failed_checks++))
    [[ ${#integrity_alerts[@]} -gt 0 ]] && ((failed_checks++))
    [[ ${#disk_alerts[@]} -gt 0 ]] && ((failed_checks++))
    [[ ${#sops_alerts[@]} -gt 0 ]] && ((failed_checks++))
    [[ ${#remote_alerts[@]} -gt 0 ]] && ((failed_checks++))
    
    local health_score=$((100 * (total_checks - failed_checks) / total_checks))
    
    # Generate JSON report
    cat > "$HEALTH_REPORT" << EOF
{
  "timestamp": "$timestamp",
  "health_score": $health_score,
  "status": "$([ $health_score -ge 80 ] && echo "healthy" || [ $health_score -ge 50 ] && echo "warning" || echo "critical")",
  "alerts": [
$(printf '    "%s"' "${all_alerts[@]}" | sed 's/"/\\"/g' | paste -sd ',' -)
  ],
  "checks": {
    "backup_age": {
      "status": "$([ ${#age_alerts[@]} -eq 0 ] && echo "pass" || echo "fail")",
      "alerts": [$(printf '"%s",' "${age_alerts[@]}" | sed 's/,$//' | sed 's/"/\\"/g')]
    },
    "backup_count": {
      "status": "$([ ${#count_alerts[@]} -eq 0 ] && echo "pass" || echo "fail")",
      "alerts": [$(printf '"%s",' "${count_alerts[@]}" | sed 's/,$//' | sed 's/"/\\"/g')]
    },
    "integrity": {
      "status": "$([ ${#integrity_alerts[@]} -eq 0 ] && echo "pass" || echo "fail")",
      "alerts": [$(printf '"%s",' "${integrity_alerts[@]}" | sed 's/,$//' | sed 's/"/\\"/g')]
    },
    "disk_space": {
      "status": "$([ ${#disk_alerts[@]} -eq 0 ] && echo "pass" || echo "fail")",
      "alerts": [$(printf '"%s",' "${disk_alerts[@]}" | sed 's/,$//' | sed 's/"/\\"/g')]
    },
    "sops_keys": {
      "status": "$([ ${#sops_alerts[@]} -eq 0 ] && echo "pass" || echo "fail")",
      "alerts": [$(printf '"%s",' "${sops_alerts[@]}" | sed 's/,$//' | sed 's/"/\\"/g')]
    },
    "remote": {
      "status": "$([ ${#remote_alerts[@]} -eq 0 ] && echo "pass" || echo "fail")",
      "alerts": [$(printf '"%s",' "${remote_alerts[@]}" | sed 's/,$//' | sed 's/"/\\"/g')]
    }
  },
  "metrics": {
    "backup_count": {
      "snapshots": $(ls "$BACKUP_ROOT"/snapshots/snapshot-*.tar.gz 2>/dev/null | wc -l),
      "bundles": $(ls "$BACKUP_ROOT"/snapshots/dotfiles-*.bundle 2>/dev/null | wc -l),
      "sops_keys": $(ls "$BACKUP_ROOT"/sops-keys/keys-*.txt 2>/dev/null | wc -l)
    },
    "disk_usage": {
      "backup_size_mb": $(du -sm "$BACKUP_ROOT" 2>/dev/null | cut -f1),
      "free_space_mb": $(df -m "$BACKUP_ROOT" 2>/dev/null | awk 'NR==2 {print $4}')
    }
  }
}
EOF
    
    success "Health report generated: $HEALTH_REPORT"
    log "Health check completed - Score: $health_score/100, Status: $([ $health_score -ge 80 ] && echo "healthy" || [ $health_score -ge 50 ] && echo "warning" || echo "critical")"
    
    return $((100 - health_score))  # Return error code based on health
}

# Send alerts (extensible for different notification methods)
send_alerts() {
    local health_score="$1"
    
    if [[ $health_score -lt 50 ]]; then
        error "🚨 Critical backup health issues detected!"
        
        # Console notification
        echo "Backup Health Report:" >&2
        cat "$HEALTH_REPORT" | jq -r '.alerts[]' 2>/dev/null || grep -o '"alerts":\s*\[[^]]*\]' "$HEALTH_REPORT" >&2
        
        # Could add additional notification methods here:
        # - Email via sendmail
        # - Slack webhook
        # - Desktop notification
        # - System log
        
        # System notification (macOS)
        if command -v osascript &>/dev/null; then
            osascript -e 'display notification "Critical backup issues detected" with title "Dotfiles Backup Alert"' 2>/dev/null || true
        fi
        
    elif [[ $health_score -lt 80 ]]; then
        warn "⚠️ Backup health warnings detected"
        log "Backup health warnings - check report for details"
    else
        success "✅ Backup health is good"
    fi
}

# Cleanup old monitoring data
cleanup_old_reports() {
    info "Cleaning up old monitoring data..."
    
    # Keep last 30 days of logs
    find "$BACKUP_ROOT" -name "health-report-*.json" -type f -mtime +30 -delete 2>/dev/null || true
    
    # Rotate log file if it's too large (>10MB)
    if [[ -f "$LOG_FILE" ]] && [[ $(du -m "$LOG_FILE" | cut -f1) -gt 10 ]]; then
        mv "$LOG_FILE" "${LOG_FILE}.old"
        touch "$LOG_FILE"
        log "Log file rotated due to size"
    fi
    
    success "Monitoring data cleanup completed"
}

# Main health check
run_health_check() {
    echo "Backup Health Check"
    echo "=================="
    echo ""
    
    mkdir -p "$BACKUP_ROOT" "$(dirname "$LOG_FILE")"
    
    log "Starting backup health check..."
    
    local exit_code
    if generate_health_report; then
        exit_code=$?
        health_score=$((100 - exit_code))
    else
        exit_code=$?
        health_score=0
    fi
    
    send_alerts $health_score
    cleanup_old_reports
    
    echo ""
    echo "Health Check Summary:"
    echo "===================="
    if command -v jq &>/dev/null && [[ -f "$HEALTH_REPORT" ]]; then
        echo "Overall Health: $(jq -r '.health_score' "$HEALTH_REPORT")/100 ($(jq -r '.status' "$HEALTH_REPORT"))"
        echo "Timestamp: $(jq -r '.timestamp' "$HEALTH_REPORT")"
        
        if [[ $(jq -r '.alerts | length' "$HEALTH_REPORT") -gt 0 ]]; then
            echo ""
            echo "Active Alerts:"
            jq -r '.alerts[]' "$HEALTH_REPORT" | sed 's/^/  • /'
        fi
    else
        echo "Health Score: $health_score/100"
    fi
    
    echo ""
    echo "Report Location: $HEALTH_REPORT"
    echo "Log Location: $LOG_FILE"
    
    return $exit_code
}

# Show usage
show_usage() {
    echo "Backup Monitoring Script"
    echo "======================="
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  health     - Run complete health check (default)"
    echo "  report     - Show latest health report"
    echo "  status     - Quick status summary"
    echo "  cleanup    - Clean up old monitoring data"
    echo "  help       - Show this help"
    echo ""
    echo "The health check validates:"
    echo "  • Backup freshness (age)"
    echo "  • Backup count and availability"
    echo "  • Backup integrity"
    echo "  • Disk space usage"
    echo "  • SOPS key configuration"
    echo "  • Remote repository sync"
}

# Main execution
case "${1:-health}" in
    "health"|"")
        run_health_check
        ;;
    "report")
        if [[ -f "$HEALTH_REPORT" ]] && command -v jq &>/dev/null; then
            jq . "$HEALTH_REPORT"
        elif [[ -f "$HEALTH_REPORT" ]]; then
            cat "$HEALTH_REPORT"
        else
            error "No health report found. Run health check first."
            exit 1
        fi
        ;;
    "status")
        if [[ -f "$HEALTH_REPORT" ]] && command -v jq &>/dev/null; then
            echo "Backup Status: $(jq -r '.status' "$HEALTH_REPORT") ($(jq -r '.health_score' "$HEALTH_REPORT")/100)"
            echo "Last Check: $(jq -r '.timestamp' "$HEALTH_REPORT")"
        else
            warn "No recent health report available"
        fi
        ;;
    "cleanup")
        cleanup_old_reports
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