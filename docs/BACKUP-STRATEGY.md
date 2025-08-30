# 🔄 Comprehensive Backup Strategy

Complete backup solution for your NixOS dotfiles with multiple redundancy layers and automated monitoring.

## 📋 Overview

**Multi-Tier Backup Architecture:**
```
Primary: Git Repository (GitHub)
├── Local: Time Machine + rsync snapshots  
├── Cloud: Multiple providers for redundancy
└── Encrypted: SOPS secrets with separate key backup
```

**Key Features:**
- ✅ **Multi-layer redundancy** (local, remote, cloud)
- ✅ **Encrypted secrets** with SOPS-nix
- ✅ **Automated validation** and health monitoring
- ✅ **Easy restoration** with interactive tools
- ✅ **CI/CD integration** for continuous validation

## 🛠️ Quick Setup

### 1. Set up SOPS Encryption (First Time)
```bash
# Install dependencies and set up age keys
./scripts/setup-sops-backup.sh

# Follow the prompts to:
# - Generate age encryption key
# - Update .sops.yaml configuration  
# - Create encrypted secrets file
# - Backup keys securely
```

### 2. Create Initial Backup
```bash
# Run comprehensive backup
./scripts/backup-dotfiles.sh

# This creates:
# - Local snapshot (compressed)
# - Git bundle backup
# - SOPS key backup
# - Cloud sync (if configured)
```

### 3. Set up Monitoring
```bash
# Run health check
./scripts/monitor-backups.sh

# Set up automated monitoring (optional)
# Add to crontab for daily checks:
echo "0 6 * * * $HOME/path/to/scripts/monitor-backups.sh" | crontab -
```

## 📁 Backup Components

### Git Repository Backup
- **Primary**: GitHub remote repository
- **Local**: Git bundles with full history
- **Validation**: Bundle integrity verification
- **Automation**: GitHub Actions for CI/CD

### Local Snapshots
- **Method**: rsync with compression
- **Storage**: `~/.dotfiles-backups/snapshots/`
- **Retention**: 10 most recent snapshots
- **Format**: `snapshot-YYYYMMDD-HHMMSS.tar.gz`

### SOPS Encrypted Secrets
- **Encryption**: Age keys with SOPS
- **Backup Location**: `~/.dotfiles-backups/sops-keys/`
- **Security**: 600 permissions, multiple backup copies
- **Integration**: Automatic NixOS/Darwin integration

### Cloud Backup (Optional)
Supports multiple cloud providers:
- **rclone**: Universal cloud sync tool
- **AWS S3**: Direct S3 integration
- **Custom**: Extensible for other providers

## 🔧 Scripts Reference

### `backup-dotfiles.sh`
**Comprehensive backup creation**
```bash
./scripts/backup-dotfiles.sh                # Full backup
./scripts/backup-dotfiles.sh validate       # Validate existing backups
./scripts/backup-dotfiles.sh report         # Generate backup report
./scripts/backup-dotfiles.sh cleanup        # Clean up old backups
```

### `setup-sops-backup.sh`
**SOPS encryption setup**
```bash
./scripts/setup-sops-backup.sh              # Complete setup
./scripts/setup-sops-backup.sh backup       # Backup existing keys
./scripts/setup-sops-backup.sh validate     # Validate setup
./scripts/setup-sops-backup.sh show-key     # Display public key
```

### `restore-dotfiles.sh`
**Interactive restoration tool**
```bash
./scripts/restore-dotfiles.sh               # Interactive menu
./scripts/restore-dotfiles.sh remote        # Restore from GitHub
./scripts/restore-dotfiles.sh snapshot file # Restore from snapshot
./scripts/restore-dotfiles.sh bundle file   # Restore from git bundle
```

### `monitor-backups.sh`
**Health monitoring and validation**
```bash
./scripts/monitor-backups.sh                # Complete health check
./scripts/monitor-backups.sh status         # Quick status summary
./scripts/monitor-backups.sh report         # Show detailed report
./scripts/monitor-backups.sh cleanup        # Clean monitoring data
```

## 📊 Health Monitoring

The monitoring system validates:

### ✅ Backup Freshness
- Alert if no backup in 7+ days
- Track last backup timestamp
- Monitor git push status

### ✅ Backup Integrity
- Validate git bundle integrity
- Test archive extraction
- Verify SOPS decryption

### ✅ Storage Health
- Monitor disk space usage
- Track backup size growth
- Alert on storage issues

### ✅ SOPS Security
- Validate key permissions
- Check key backup availability
- Test encryption/decryption

## 🔄 Restoration Procedures

### Emergency Full Restore
```bash
# 1. Clone repository
git clone https://github.com/fern1co/my-dotfiles.git ~/dotfiles-restored

# 2. Restore SOPS keys
./scripts/restore-dotfiles.sh sops /path/to/key-backup.txt

# 3. Test configuration
cd ~/dotfiles-restored
nix flake check

# 4. Apply configuration
darwin-rebuild switch --flake .#aarch64  # or appropriate config
```

### Selective Restore
```bash
# Interactive restoration menu
./scripts/restore-dotfiles.sh

# Choose from:
# - Latest from GitHub
# - Specific local snapshot
# - Git bundle restore
# - SOPS keys only
```

### SOPS Key Recovery
```bash
# List available key backups
ls ~/.dotfiles-backups/sops-keys/

# Restore specific backup
./scripts/restore-dotfiles.sh sops keys-20231201-120000.txt

# Test restored key
age-keygen -y ~/.config/sops/age/keys.txt
sops -d secrets/secrets.yaml  # Should decrypt successfully
```

## 🚀 Automation Setup

### GitHub Actions
The included workflow (`.github/workflows/backup-validation.yml`) provides:
- **Daily validation** of configurations
- **Security scanning** for sensitive data
- **Backup bundle creation** on main branch
- **Multi-platform testing** (NixOS + Darwin)

### Crontab Automation
```bash
# Daily backup at 6 AM
0 6 * * * /path/to/scripts/backup-dotfiles.sh >> /tmp/backup.log 2>&1

# Health check at noon
0 12 * * * /path/to/scripts/monitor-backups.sh >> /tmp/monitor.log 2>&1

# Weekly cleanup at midnight Sunday
0 0 * * 0 /path/to/scripts/backup-dotfiles.sh cleanup >> /tmp/cleanup.log 2>&1
```

### Launchd (macOS)
```bash
# Create system service for automated backups
sudo cp scripts/backup-service.plist /Library/LaunchDaemons/
sudo launchctl load /Library/LaunchDaemons/backup-service.plist
```

## 🔒 Security Considerations

### SOPS Key Management
- **Never commit** private age keys to git
- **Store backups** in multiple secure locations
- **Use 600 permissions** for all key files
- **Rotate keys** periodically for security

### Cloud Backup Security
- Use encrypted cloud storage when possible
- Configure provider-specific access controls
- Monitor for unauthorized access
- Regular security audits

### Access Control
- Limit backup script execution permissions
- Use dedicated backup user accounts when possible
- Regular review of backup access patterns
- Audit backup restoration activities

## 🎯 Best Practices

### Regular Operations
1. **Weekly**: Run health checks and review alerts
2. **Monthly**: Test restoration procedures
3. **Quarterly**: Review and rotate SOPS keys
4. **Annually**: Full backup strategy review

### Disaster Recovery Testing
- Test restoration on clean systems
- Validate all configurations build correctly
- Document restoration time and complexity
- Update procedures based on test results

### Documentation Maintenance
- Keep backup documentation current
- Document any custom configurations
- Maintain restoration procedure guides
- Share knowledge with team members

## 🔍 Troubleshooting

### Common Issues

**"No age keys found"**
```bash
# Check key file location and permissions
ls -la ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt

# Restore from backup if needed
./scripts/restore-dotfiles.sh sops /path/to/backup
```

**"Failed to decrypt secrets"**
```bash
# Verify public key matches
age-keygen -y ~/.config/sops/age/keys.txt
grep age1 .sops.yaml

# Re-encrypt if keys don't match
sops updatekeys secrets/secrets.yaml
```

**"Backup validation failed"**
```bash
# Check specific failure
./scripts/monitor-backups.sh report

# Rebuild corrupted backups
./scripts/backup-dotfiles.sh
```

### Support Resources
- [SOPS Documentation](https://github.com/mozilla/sops)
- [Age Encryption](https://github.com/FiloSottile/age)
- [Nix Flakes Guide](https://nixos.wiki/wiki/Flakes)
- [Project Issues](https://github.com/fern1co/my-dotfiles/issues)

---

## 📈 Monitoring Dashboard

Recent health check results are available in:
- JSON Report: `~/.dotfiles-backups/health-report.json`
- Logs: `~/.dotfiles-backups/backup.log`
- Monitoring: `~/.dotfiles-backups/monitoring.log`

**Quick Status Check:**
```bash
./scripts/monitor-backups.sh status
```