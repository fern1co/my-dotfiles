# My Dotfiles

Nix-based system configuration for macOS (nix-darwin) and NixOS with centralized home-manager setup.

## 📁 Repository Structure

```
.
├── flake.nix              # Main flake configuration
├── hosts.nix              # Host-specific configuration (IPs, usernames)
├── lib/                   # Core configuration library
│   ├── darwin/            # macOS configurations
│   ├── nixos/             # NixOS configurations
│   └── shared/            # Shared configurations
├── modules/               # Reusable modules
│   ├── darwin/            # macOS-specific modules
│   ├── nixos/             # NixOS-specific modules
│   └── shared/            # Cross-platform modules
├── profiles/              # Configuration presets
│   ├── workstation.nix    # Full desktop environment
│   ├── server.nix         # Minimal server setup
│   └── development.nix    # Development-focused
├── secrets/               # Encrypted secrets (sops-nix)
├── scripts/               # Utility scripts
└── docs/                  # Additional documentation

```

## 🚀 Quick Start

### Prerequisites

- **macOS**: Install Nix with [Determinate Systems installer](https://zero-to-nix.com/start/install)
- **NixOS**: Nix is already installed
- Git

### First-Time Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/my-dotfiles.git
   cd my-dotfiles
   ```

2. **Build and switch** (choose your platform):

   **macOS**:
   ```bash
   # For Apple Silicon
   nix run nix-darwin -- switch --flake .#aarch64

   # For Intel Mac
   nix run nix-darwin -- switch --flake .#x86_64

   # For MacBook Pro (custom config)
   nix run nix-darwin -- switch --flake .#macbook-pro
   ```

   **NixOS**:
   ```bash
   # Replace 'hostname' with your configuration name
   sudo nixos-rebuild switch --flake .#hostname
   ```

3. **Subsequent updates**:
   ```bash
   # macOS
   darwin-rebuild switch --flake .

   # NixOS
   sudo nixos-rebuild switch --flake .
   ```

## 🖥️ Configurations

### Darwin (macOS)

- **aarch64**: Apple Silicon generic configuration
- **x86_64**: Intel Mac generic configuration
- **macbook-pro**: Custom MacBook Pro setup with:
  - AeroSpace window manager
  - SketchyBar status bar
  - Custom aerospace keybindings

### NixOS

- **n1co**: Work laptop configuration
- **home_laptop**: Personal laptop
- **digitalocean**: DigitalOcean droplet (server)

## 🔐 Secrets Management

This repository uses [sops-nix](https://github.com/Mic92/sops-nix) for encrypted secrets.

### Setup Secrets

1. **Generate age key**:
   ```bash
   nix-shell -p age --run "age-keygen -o ~/.config/sops/age/keys.txt"
   ```

2. **Configure .sops.yaml** with your public key

3. **Edit secrets**:
   ```bash
   nix run nixpkgs#sops -- secrets/secrets.yaml
   ```

See [secrets/README.md](secrets/README.md) for detailed instructions.

## 🚢 Deployment

### DigitalOcean Droplet

Deploy to DigitalOcean using deploy-rs:

1. **Update host configuration** in `hosts.nix`:
   ```nix
   digitalocean = {
     hostname = "your.droplet.ip";
     sshUser = "your-user";
     # ...
   };
   ```

2. **Deploy**:
   ```bash
   nix run .#deploy
   ```

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for advanced deployment options.

## 📦 Profiles

Profiles provide preset configurations for different use cases:

```nix
imports = [
  ./profiles/workstation.nix  # Full desktop environment
  ./profiles/server.nix        # Minimal server setup
  ./profiles/development.nix   # Development tools
];
```

See [profiles/README.md](profiles/README.md) for details.

## 🛠️ Common Tasks

### Update Flake Inputs

```bash
nix flake update
```

### Check Flake

```bash
nix flake check
```

### Build Without Switching

```bash
# macOS
darwin-rebuild build --flake .

# NixOS
sudo nixos-rebuild build --flake .
```

### Format Nix Files

```bash
nix fmt
```

## 🏗️ Adding a New Machine

1. **Create configuration directory**:
   ```bash
   mkdir -p lib/{darwin,nixos}/new-machine
   ```

2. **Create configuration.nix**:
   ```nix
   { inputs, username }: { pkgs, ... }:
   {
     imports = [
       # Your imports
     ];

     # Your configuration
   }
   ```

3. **Add to flake.nix**:
   ```nix
   darwinConfigurations.new-machine = self.lib.mkDarwin {
     system = "aarch64-darwin";  # or x86_64-darwin
     configPath = ./lib/darwin/new-machine/configuration.nix;
     username = "your-username";
   };
   ```

## 🔧 Customization

### Using Modules

Modules provide type-safe, configurable options for specific software:

**Available Modules**:
- **Darwin**: `aerospace`, `sketchybar`, `yabai`
- **NixOS**: `firewall-rules`
- **Shared**: `dev-environment`

**Example Usage**:

```nix
# Import module
imports = [
  ../../modules/darwin/aerospace.nix
];

# Configure it
programs.aerospace = {
  enable = true;
  gaps = { inner = 10; outer = 10; };
  keybindings = {
    "cmd-h" = "focus left";
    "cmd-l" = "focus right";
  };
};
```

**Create Your Own Module**:

```nix
# modules/shared/my-module.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.myModule;
in
{
  options.programs.myModule = {
    enable = mkEnableOption "My Module";

    setting = mkOption {
      type = types.str;
      default = "value";
      description = "A configurable setting";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.myPackage ];
  };
}
```

See [docs/MODULES_GUIDE.md](docs/MODULES_GUIDE.md) for complete guide and [examples/modules-usage.nix](examples/modules-usage.nix) for usage examples.

### Home Manager

Shared home-manager configuration is in `lib/shared/home-manager.nix`.

Per-machine customization in individual configuration files.

## 🐛 Troubleshooting

### Build Fails

1. Check flake inputs are up to date: `nix flake update`
2. Clear build cache: `nix-collect-garbage -d`
3. Check for syntax errors: `nix flake check`

### Darwin Activation Fails

```bash
# Remove old generation and retry
darwin-rebuild switch --flake . --rollback
```

### SSH Keys Not Working

Ensure sops secrets are properly configured and age key is accessible.

## 📚 Additional Documentation

### Guides
- **[Modules Guide](docs/MODULES_GUIDE.md)** - Complete guide to creating custom modules
- **[Profiles Guide](PROFILES.md)** - Using and creating configuration profiles
- **[Architecture](ARCHITECTURE.md)** - System architecture overview
- **[Migration Guide](MIGRATION.md)** - Migrating configurations to profile system

### Deployment & Operations
- [Deploy-rs Guide](README-DEPLOY.md) - Remote deployment with deploy-rs
- [Backup Strategy](docs/BACKUP-STRATEGY.md) - Backup and recovery
- [Secrets Management](secrets/README.md) - Managing encrypted secrets with sops-nix

### Examples
- [Module Usage Examples](examples/modules-usage.nix) - Complete module usage examples
- [More Examples](examples/) - Additional configuration examples

## 🤝 Contributing

This is a personal dotfiles repository, but feel free to:
- Open issues for questions
- Submit PRs for bug fixes
- Fork and adapt for your own use

## 📝 License

MIT License - Feel free to use and modify as needed.

## 🔗 Useful Links

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [NixOS Options Search](https://search.nixos.org/options)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/index.html)
- [Zero to Nix](https://zero-to-nix.com/)
