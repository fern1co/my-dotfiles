# Dependency Management

This repository uses automated tools to keep Nix flake inputs up to date.

## Renovate Bot

We use [Renovate](https://github.com/renovatebot/renovate) for automated dependency updates.

### Configuration

Renovate is configured via `.github/renovate.json` with the following settings:

- **Schedule**: Weekly updates on Monday mornings
- **Automerge**: Disabled by default (requires manual review)
- **Grouping**: All Nix flake inputs grouped together
- **Security Updates**: High priority, checked anytime

### Update Types

#### Patch & Minor Updates

- Labeled as `automerge-candidate`
- Low risk, but still require manual review
- Example: `1.0.0` → `1.0.1` or `1.1.0`

#### Major Updates

- Labeled as `major-update`
- Require careful manual review
- May include breaking changes
- Example: `1.0.0` → `2.0.0`

#### Security Updates

- Labeled as `security`
- Processed immediately (not on schedule)
- High priority for review and merging

### Dependency Dashboard

Renovate creates a "Dependency Dashboard" issue listing:
- All pending updates
- Detected security vulnerabilities
- Update scheduling information
- Manual approval status

## Manual Updates

### Update All Inputs

```bash
# Update all flake inputs to latest
nix flake update

# Commit the changes
git add flake.lock
git commit -m "chore(deps): update flake.lock"
```

### Update Specific Input

```bash
# Update only nixpkgs
nix flake lock --update-input nixpkgs

# Update only home-manager
nix flake lock --update-input home-manager
```

### Check for Available Updates

```bash
# Show outdated inputs
nix flake metadata --json | jq '.locks.nodes'

# Or use nix-update
nix run nixpkgs#nix-update
```

## Testing Updates

### Before Merging Updates

1. **Build All Configurations**:
   ```bash
   # Darwin
   nix build .#darwinConfigurations.macbook-pro.system

   # NixOS
   nix build .#nixosConfigurations.digitalocean.config.system.build.toplevel
   ```

2. **Run Checks**:
   ```bash
   nix flake check --all-systems
   ```

3. **Test on Non-Production First**:
   ```bash
   # Test on development machine first
   darwin-rebuild build --flake .
   # Or for NixOS
   nixos-rebuild build --flake .
   ```

4. **Verify Functionality**:
   - Test critical applications
   - Check service status
   - Verify secrets are accessible

### Rollback if Needed

If an update causes issues:

```bash
# Git rollback
git revert HEAD

# System rollback (if already activated)
darwin-rebuild switch --rollback
# Or for NixOS
sudo nixos-rebuild switch --rollback
```

## Pinning Versions

### When to Pin

Pin versions when you need:
- Stable, reproducible builds
- To avoid breaking changes
- To wait for fixes in newer versions

### How to Pin

In your flake.nix:

```nix
inputs = {
  # Pin to specific commit
  nixpkgs.url = "github:NixOS/nixpkgs/abc123def456...";

  # Pin to specific release
  nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";

  # Follow a specific branch
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
};
```

## Update Strategy

### Recommended Workflow

1. **Weekly Review**:
   - Check Renovate PRs every Monday
   - Review dependency dashboard

2. **Categorize Updates**:
   - **Safe**: Patch updates, documentation changes
   - **Medium**: Minor version bumps
   - **Risky**: Major version changes

3. **Merge Strategy**:
   - Merge safe updates immediately
   - Test medium updates in development
   - Schedule risky updates for maintenance windows

4. **Monitor**:
   - Watch for CI failures
   - Check system logs after updates
   - Monitor application behavior

### Emergency Updates

For security vulnerabilities:

1. **Immediate Action**:
   ```bash
   # Update affected input
   nix flake lock --update-input affected-package

   # Build and test
   nix build .#nixosConfigurations.digitalocean.config.system.build.toplevel

   # Deploy immediately
   nix run .#deploy
   ```

2. **Document**:
   - Create issue for tracking
   - Note in commit message
   - Update changelog

## Monitoring

### Check Update History

```bash
# View flake.lock changes
git log --oneline --follow flake.lock

# Diff specific update
git diff HEAD~1 flake.lock
```

### Verify Input Sources

```bash
# List all inputs and their sources
nix flake metadata

# Show specific input info
nix flake metadata --json | jq '.locks.nodes.nixpkgs'
```

## Best Practices

### For Security

1. **Enable Vulnerability Alerts**: Already configured in renovate.json
2. **Review Security Labels**: Prioritize PRs with `security` label
3. **Update Promptly**: Apply security updates within 24-48 hours
4. **Test Thoroughly**: Even security updates can break things

### For Stability

1. **Test Before Production**: Always test in dev/staging first
2. **Read Changelogs**: Review release notes for breaking changes
3. **Backup Before Major Updates**: Create restore points
4. **Update Incrementally**: Don't skip multiple major versions

### For Efficiency

1. **Group Related Updates**: Let Renovate group Nix inputs
2. **Batch Minor Updates**: Merge multiple safe updates together
3. **Schedule Maintenance**: Updates during low-traffic periods
4. **Automate Testing**: Let CI catch issues early

## Troubleshooting

### Renovate Not Creating PRs

1. Check Renovate configuration:
   ```bash
   # Validate renovate.json
   npx --package renovate -- renovate-config-validator
   ```

2. Check GitHub App permissions
3. Review Renovate dashboard for errors

### Update Breaks Build

1. Check build logs in CI
2. Review the specific change:
   ```bash
   git diff HEAD~1 flake.lock
   ```
3. Try updating one input at a time
4. Check input project's issue tracker

### Flake Lock Conflicts

```bash
# Reset to remote state
git fetch origin
git checkout origin/main -- flake.lock

# Re-run update
nix flake update
```

## Resources

- [Renovate Documentation](https://docs.renovatebot.com/)
- [Nix Flakes Manual](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html)
- [nixpkgs Releases](https://github.com/NixOS/nixpkgs/releases)
