# Secrets Management with sops-nix

This directory contains encrypted secrets managed by [sops-nix](https://github.com/Mic92/sops-nix) using age encryption.

## Quick Start

### 1. Generate Age Keys

First, install age and sops:

```bash
# Install via nix
nix shell nixpkgs#age nixpkgs#sops

# Or via your package manager
brew install age sops  # macOS
```

Generate your age key:

```bash
# Generate a new age key
age-keygen -o ~/.config/sops/age/keys.txt

# Display the public key
age-keygen -y ~/.config/sops/age/keys.txt
```

### 2. Update .sops.yaml

Replace the placeholder key in `.sops.yaml` with your actual public key:

```yaml
keys:
  - &main_key age1hl8zqn7j9k6j8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k8k  # Replace this!
```

### 3. Create Secrets File

Copy the example and encrypt it:

```bash
# Copy example file
cp secrets.yaml.example secrets.yaml

# Edit with your actual secrets
$EDITOR secrets.yaml

# Encrypt the file
sops -e -i secrets.yaml
```

### 4. Set Up Age Key on Target Systems

#### For NixOS Systems

```bash
# Create the key file directory
sudo mkdir -p /var/lib/sops-nix

# Copy your private key (securely!)
sudo cp ~/.config/sops/age/keys.txt /var/lib/sops-nix/key.txt
sudo chown root:root /var/lib/sops-nix/key.txt
sudo chmod 600 /var/lib/sops-nix/key.txt
```

#### For Darwin Systems

```bash
# Ensure directory exists
mkdir -p ~/.config/sops/age

# Key is already in the right place if you followed step 1
```

### 5. Rebuild System

```bash
# For NixOS
sudo nixos-rebuild switch --flake .#your-hostname

# For Darwin
darwin-rebuild switch --flake .#aarch64  # or x86_64
```

## File Structure

```
secrets/
├── .sops.yaml              # Sops configuration
├── secrets.yaml            # Encrypted secrets (after setup)
├── secrets.yaml.example    # Template for secrets
└── README.md               # This file
```

## Configuration Files

### .sops.yaml

Controls which keys can decrypt which files. Uses age encryption by default.

### secrets.yaml

Main encrypted secrets file containing:
- VPN configurations
- API keys and tokens
- Environment variables
- Other sensitive data

## Managing Secrets

### Add New Secret

```bash
# Edit encrypted file
sops secrets.yaml

# Add your secret in the appropriate section
vpn:
  new-vpn-config: |
    # VPN configuration content
```

### Edit Existing Secret

```bash
# Edit encrypted file
sops secrets.yaml

# Make changes and save
```

### View Secrets (Decrypted)

```bash
# View entire file
sops -d secrets.yaml

# View specific key
sops -d --extract '["vpn"]["n1co-dev"]' secrets.yaml
```

### Rotate Keys

When you need to change keys:

1. Generate new age key
2. Update `.sops.yaml` with new public key
3. Re-encrypt with new key:
   ```bash
   sops updatekeys secrets.yaml
   ```

## Security Best Practices

### ✅ Do's

- Always encrypt secrets before committing
- Use strong age keys (keep them secure)
- Set proper file permissions (600) for key files
- Regularly rotate secrets and keys
- Use different keys for different environments
- Store keys securely (password managers, hardware tokens)

### ❌ Don'ts

- Never commit unencrypted secrets
- Don't share private keys via insecure channels
- Don't use the example key in production
- Don't store keys in the dotfiles repository
- Don't give unnecessary access to secrets

## Integration with Nix Configurations

### NixOS Integration

Secrets are automatically available at system paths:

```nix
# Example: VPN configuration
services.openvpn.servers.my-vpn = {
  config = "config ${config.sops.secrets."vpn/my-vpn".path}";
};
```

### Home Manager Integration

For user-level secrets:

```nix
# Example: API key in shell environment
home.sessionVariables = {
  GITHUB_TOKEN = "$(cat ${config.sops.secrets.github-token.path})";
};
```

## Troubleshooting

### Common Issues

1. **"no age keys found"**
   - Ensure age key file exists at correct path
   - Check file permissions (600)

2. **"failed to decrypt"**
   - Verify public key in `.sops.yaml` matches your private key
   - Run `age-keygen -y ~/.config/sops/age/keys.txt` to get public key

3. **"secret not found"**
   - Check secret path in configuration matches `secrets.yaml`
   - Verify secrets are properly nested in YAML structure

4. **Permission denied**
   - Check file ownership and permissions
   - Ensure sops user has access to key file

### Debug Commands

```bash
# Check if sops can decrypt
sops -d secrets.yaml

# Verify key file
ls -la ~/.config/sops/age/keys.txt  # Darwin
ls -la /var/lib/sops-nix/key.txt    # NixOS

# Test age key
age-keygen -y ~/.config/sops/age/keys.txt
```

## Migration from Plain Text

If you have existing plain text secrets:

1. **Backup existing secrets** (store securely outside repo)
2. **Create encrypted versions** using the workflow above
3. **Update configurations** to use sops paths
4. **Test thoroughly** before removing plain text versions
5. **Clean up** - remove plain text secrets from system and git history

For VPN configs specifically:
```bash
# Example migration
sops secrets.yaml
# Add content from your existing .ovpn files
# Then update the OpenVPN service configuration
```

## Additional Resources

- [sops-nix Documentation](https://github.com/Mic92/sops-nix)
- [Age Encryption](https://github.com/FiloSottile/age)
- [Mozilla SOPS](https://github.com/mozilla/sops)