# Deployment Guide

This guide covers deploying NixOS configurations to remote hosts using deploy-rs.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Deployment](#quick-deployment)
- [Configuration](#configuration)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### On Your Local Machine

1. **Nix with Flakes** enabled
2. **SSH access** to the target host with public key authentication
3. **sudo privileges** on the target host (for the deploy user)

### On the Target Host

1. **NixOS** installed and running
2. **SSH server** enabled
3. **User account** with sudo privileges
4. **Your SSH public key** added to authorized_keys

## Quick Deployment

### Deploy to DigitalOcean Droplet

```bash
# Deploy using the default configuration
nix run .#deploy

# Or use deploy-rs directly
nix run nixpkgs#deploy-rs -- .#digitalocean
```

This will:
1. Build the NixOS configuration locally
2. Copy the build to the remote host
3. Activate the new configuration
4. Run system activation scripts

## Configuration

### Host Configuration

Edit `hosts.nix` to configure your deployment targets:

```nix
{
  digitalocean = {
    hostname = "your.server.ip.address";  # Or domain name
    sshUser = "your-ssh-user";            # User for SSH connection
    deployUser = "root";                   # User for activation (usually root)
    system = "x86_64-linux";
    username = "your-system-user";
  };

  # Add more hosts as needed
  another-host = {
    hostname = "another.server.com";
    sshUser = "deployuser";
    deployUser = "root";
    system = "x86_64-linux";
    username = "mainuser";
  };
}
```

### Deploy Configuration in flake.nix

The deployment is configured in `flake.nix`:

```nix
deploy.nodes.digitalocean = {
  hostname = hosts.digitalocean.hostname;
  profiles.system = {
    sshUser = hosts.digitalocean.sshUser;
    path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos
           self.nixosConfigurations.digitalocean;
    user = hosts.digitalocean.deployUser;
  };
};
```

## Advanced Usage

### Deploy to Specific Profile

```bash
# Deploy only the system profile
nix run .#deploy -- .#digitalocean.system
```

### Fast Activation (Skip Checks)

```bash
# Skip activation checks for faster deployment
nix run .#deploy -- .#digitalocean --skip-checks
```

### Dry Run

```bash
# See what would be deployed without actually deploying
nix run .#deploy -- .#digitalocean --dry-activate
```

### Deploy from Specific Git Revision

```bash
# Deploy from a specific commit
nix run .#deploy -- .#digitalocean --git-ref main
```

### Remote Build

By default, build happens locally. To build on the remote host:

```bash
# Build and activate on remote (slower first time, saves local resources)
nix run .#deploy -- .#digitalocean --remote-build
```

## SSH Configuration

### Recommended SSH Config

Add to `~/.ssh/config` for easier access:

```ssh
Host digitalocean
    HostName 165.227.123.205
    User ferock
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes
```

Then deploy with:

```bash
nix run .#deploy -- .#digitalocean
```

### SSH Key Setup

If you haven't set up SSH keys yet:

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy to remote host
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@hostname
```

## Multiple Hosts

### Deploy to All Hosts

```bash
# Deploy to all configured hosts
nix run .#deploy
```

### Deploy to Specific Hosts

```bash
# Deploy to specific hosts only
nix run .#deploy -- .#digitalocean .#another-host
```

## Rollback

If a deployment fails or causes issues:

### On the Remote Host

```bash
# SSH into the host
ssh user@hostname

# List available generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo /nix/var/nix/profiles/system-*-link/bin/switch-to-configuration switch
```

### Via deploy-rs

Deploy the previous configuration:

```bash
# Checkout previous commit
git checkout HEAD~1

# Deploy
nix run .#deploy
```

## Automation

### CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v20
        with:
          extra_nix_config: experimental-features = nix-command flakes

      - name: Deploy
        env:
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
        run: |
          mkdir -p ~/.ssh
          echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_ed25519
          chmod 600 ~/.ssh/id_ed25519
          nix run .#deploy
```

## Troubleshooting

### Connection Issues

**Problem**: Cannot connect to host

```bash
# Test SSH connection
ssh -v user@hostname

# Check if host is reachable
ping hostname

# Verify SSH service is running
ssh user@hostname "systemctl status sshd"
```

### Build Failures

**Problem**: Build fails on local machine

```bash
# Check flake for errors
nix flake check

# Try building without deploying
nix build .#nixosConfigurations.digitalocean.config.system.build.toplevel

# Check for syntax errors
nix eval .#nixosConfigurations.digitalocean.config.system.name
```

### Activation Failures

**Problem**: Configuration builds but fails to activate

```bash
# Deploy with verbose output
nix run .#deploy -- .#digitalocean --debug

# Check remote system logs
ssh user@hostname "journalctl -xe"
```

### Permission Issues

**Problem**: "Permission denied" during activation

1. Ensure deploy user has sudo privileges
2. Check sudo configuration on target host:
   ```bash
   ssh user@hostname "sudo -l"
   ```
3. Add user to sudoers if needed:
   ```bash
   # On the remote host
   echo "deployuser ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/deployuser
   ```

### Secrets Not Available

**Problem**: Sops secrets not decrypted on deployment

1. Ensure age key is present on target host:
   ```bash
   ssh user@hostname "cat ~/.config/sops/age/keys.txt"
   ```

2. Verify secrets are properly encrypted:
   ```bash
   sops -d secrets/secrets.yaml
   ```

3. Check sops-nix configuration in your system config

## Best Practices

### Safety

1. **Test in Staging**: Always test deployments in a staging environment first
2. **Backup**: Create system backups before major changes
3. **Rollback Plan**: Know how to rollback if something goes wrong
4. **Monitoring**: Monitor system health after deployment

### Efficiency

1. **Use SSH Config**: Configure SSH for easier access
2. **Cache Builds**: Use binary caches (Cachix) to speed up deployments
3. **Incremental Updates**: Deploy frequently with small changes
4. **Remote Build**: Consider remote building for slow local machines

### Security

1. **SSH Keys Only**: Disable password authentication
2. **Limited Sudo**: Grant minimum necessary sudo privileges
3. **Secrets Management**: Use sops-nix for all sensitive data
4. **Audit Logs**: Monitor deployment logs for unauthorized changes

## Additional Resources

- [deploy-rs Documentation](https://github.com/serokell/deploy-rs)
- [NixOS Manual - Deployment](https://nixos.org/manual/nixos/stable/#sec-changing-config)
- [Sops-nix Guide](https://github.com/Mic92/sops-nix)
