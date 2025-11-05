# 🏗️ Architecture Overview

## System Structure

This NixOS flake provides a modular, scalable configuration system for managing multiple machines (Darwin/macOS and NixOS/Linux) with reusable profiles and centralized host metadata.

---

## 📂 Directory Structure

```
.
├── flake.nix                    # Main flake entry point
├── hosts.nix                    # Centralized host metadata
├── lib/
│   ├── default.nix              # System builders (mkDarwin, mkNixos, mkDigitalOceanImage)
│   ├── profiles/                # Reusable configuration profiles
│   │   ├── default.nix          # Profile loader
│   │   ├── base/                # Base configuration for all systems
│   │   ├── server/              # Server-specific configuration
│   │   ├── development/         # Development tools
│   │   └── security/            # Security hardening
│   ├── darwin/                  # macOS-specific configurations
│   │   ├── configuration.nix
│   │   └── macbook-pro/
│   ├── nixos/                   # NixOS-specific configurations
│   │   ├── digitalocean/
│   │   │   ├── configuration.nix
│   │   │   ├── hardware.nix
│   │   │   ├── secrets.nix
│   │   │   └── home.nix
│   │   ├── home-laptop/
│   │   └── n1co-work/
│   └── shared/                  # Shared configuration across platforms
│       ├── home-manager.nix
│       ├── nix.nix
│       └── secrets*.nix
└── secrets/
    └── secrets.yaml             # SOPS-encrypted secrets
```

---

## 🎯 Key Concepts

### 1. **Host Metadata** (`hosts.nix`)

Centralized configuration for all hosts:

```nix
{
  digitalocean = {
    hostname = "64.225.51.178";
    username = "ferock";
    profiles = [ "base" "server" "server/digitalocean" "development" ];
    role = "server";
    environment = "production";
    # ... more metadata
  };
}
```

**Benefits:**
- ✅ Single source of truth for host info
- ✅ Easy to see all hosts at a glance
- ✅ Metadata for documentation and automation
- ✅ Deployment configuration included

### 2. **Profiles System** (`lib/profiles/`)

Modular, reusable configuration units:

```nix
profiles = [
  "base"              # Essential config for all systems
  "server"            # Server optimizations
  "development"       # Dev tools
  "security/hardened" # Security hardening
]
```

**Benefits:**
- ✅ Code reuse across hosts
- ✅ Consistent configuration
- ✅ Easy to maintain
- ✅ Composable architecture

### 3. **System Builders** (`lib/default.nix`)

Functions to build complete system configurations:

```nix
# NixOS system
mkNixos {
  system = "x86_64-linux";
  configPath = ./nixos/myhost/configuration.nix;
  username = "myuser";
}

# Darwin (macOS) system
mkDarwin {
  system = "aarch64-darwin";
  configPath = ./darwin/configuration.nix;
  username = "myuser";
}

# DigitalOcean image
mkDigitalOceanImage {
  username = "myuser";
  system = "x86_64-linux";
}
```

---

## 🔄 Configuration Flow

### NixOS Host Configuration

```
flake.nix
  ↓
lib/default.nix::mkNixos
  ↓
lib/nixos/myhost/configuration.nix
  ↓
hosts.nix (metadata)
  ↓
lib/profiles/default.nix (profile loader)
  ↓
lib/profiles/{base,server,...}/default.nix
  ↓
Final system configuration
```

### Example: DigitalOcean Host

```nix
# flake.nix
nixosConfigurations.digitalocean = mkNixos {
  system = "x86_64-linux";
  configPath = ./lib/nixos/digitalocean/configuration.nix;
  username = "ferock";
};

# lib/nixos/digitalocean/configuration.nix
let
  hosts = import ../../../hosts.nix;
  hostConfig = hosts.digitalocean;
  profileImports = profileLoader { profiles = hostConfig.profiles; };
in {
  imports = [ ./secrets.nix ./hardware.nix ] ++ profileImports;
  # Host-specific config only
}
```

---

## 🎨 Design Patterns

### 1. **Separation of Concerns**

| Layer | Purpose | Location |
|-------|---------|----------|
| **Host Metadata** | Non-sensitive host info | `hosts.nix` |
| **Secrets** | Sensitive data | `secrets/secrets.yaml` |
| **Profiles** | Reusable config | `lib/profiles/` |
| **Host Config** | Host-specific overrides | `lib/{darwin,nixos}/*/configuration.nix` |
| **Hardware** | Hardware detection | `lib/nixos/*/hardware.nix` |

### 2. **Composition over Inheritance**

Hosts compose multiple profiles instead of inheriting from a base:

```nix
# ✅ Good: Composition
profiles = [ "base" "server" "development" ];

# ❌ Avoid: Monolithic inheritance
imports = [ ./everything.nix ];
```

### 3. **Overridable Defaults**

Profiles use `lib.mkDefault` for values that hosts can override:

```nix
# In profile
networking.firewall.enable = lib.mkDefault true;

# In host (overrides)
networking.firewall.enable = false;
```

### 4. **Feature Flags**

Optional features controlled via `hosts.nix`:

```nix
# In hosts.nix
features = {
  docker = true;
  monitoring = false;
};

# In configuration
virtualisation.docker.enable = hostConfig.features.docker or false;
```

---

## 📦 Module Inputs

### Common Inputs

All configuration modules receive these inputs:

```nix
{ inputs   # Flake inputs (nixpkgs, home-manager, etc.)
, username # Primary user for the system
}:
{ config   # NixOS/nix-darwin config
, pkgs     # Package set
, lib      # Nixpkgs library
, ...
}:
```

### Using Inputs

```nix
{ inputs, username }: { config, pkgs, lib, ... }:
{
  # Access flake inputs
  imports = [ inputs.sops-nix.nixosModules.sops ];

  # Use username
  users.users.${username} = { ... };

  # Access packages
  environment.systemPackages = [ pkgs.git ];

  # Use library functions
  services.myservice.enable = lib.mkDefault true;
}
```

---

## 🚀 Deployment Architecture

### Deploy-RS Integration

```nix
deploy.nodes.digitalocean = {
  hostname = hosts.digitalocean.hostname;
  profiles.system = {
    sshUser = hosts.digitalocean.sshUser;
    path = deploy-rs.lib.x86_64-linux.activate.nixos
           nixosConfigurations.digitalocean;
    user = hosts.digitalocean.deployUser;
  };
};
```

**Deployment Flow:**
1. Local: Build configuration or use remote build
2. Transfer: Copy closure to remote host
3. Activate: Switch to new configuration
4. Rollback: Automatic if activation fails

---

## 🔐 Secrets Management

### SOPS-nix Integration

```yaml
# secrets/secrets.yaml (encrypted)
digitalocean:
  ssh-public-key: <encrypted>
  api-token: <encrypted>

# lib/nixos/digitalocean/secrets.nix
sops = {
  defaultSopsFile = ../../../secrets/secrets.yaml;
  age.keyFile = "/var/lib/sops-nix/key.txt";

  secrets."digitalocean/ssh-public-key" = {
    owner = username;
    path = "/home/${username}/.ssh/authorized_keys";
  };
};
```

**Security Flow:**
1. Secrets encrypted with age/sops
2. Private key on target system
3. Decrypted at activation time
4. Placed in specified paths with correct permissions

---

## 🧩 Extension Points

### Adding a New Host

1. **Add to `hosts.nix`:**
   ```nix
   myhost = {
     hostname = "192.168.1.100";
     system = "x86_64-linux";
     username = "myuser";
     profiles = [ "base" "server" ];
   };
   ```

2. **Create host directory:**
   ```bash
   mkdir -p lib/nixos/myhost
   ```

3. **Create configuration:**
   ```nix
   # lib/nixos/myhost/configuration.nix
   { inputs, username }: { ... }:
   let
     hosts = import ../../../hosts.nix;
     hostConfig = hosts.myhost;
     profileImports = profileLoader { profiles = hostConfig.profiles; };
   in {
     imports = profileImports;
     # Host-specific config
   }
   ```

4. **Add to flake.nix:**
   ```nix
   nixosConfigurations.myhost = mkNixos {
     system = hostConfig.system;
     configPath = ./lib/nixos/myhost/configuration.nix;
     username = hostConfig.username;
   };
   ```

### Adding a New Profile

1. **Create profile directory:**
   ```bash
   mkdir -p lib/profiles/myprofile
   ```

2. **Create profile module:**
   ```nix
   # lib/profiles/myprofile/default.nix
   { config, pkgs, lib, ... }:
   {
     # Profile configuration
   }
   ```

3. **Use in host:**
   ```nix
   # hosts.nix
   myhost.profiles = [ "base" "myprofile" ];
   ```

---

## 📊 Build Targets

### Available Commands

```bash
# Build configurations
nix build .#darwinConfigurations.aarch64.system
nix build .#nixosConfigurations.digitalocean.config.system.build.toplevel

# Generate DigitalOcean image
nix build .#digitalOceanImage

# Deploy to remote
nix run .#deploy -- --remote-build .#digitalocean

# Check flake
nix flake check

# Format code
nix fmt
```

---

## 🔍 Debugging

### Check Profile Loading

```bash
# Enter nix repl
nix repl
> :lf .

# Check host config
> hosts = import ./hosts.nix
> hosts.digitalocean.profiles

# Check profile imports
> profileLoader = import ./lib/profiles/default.nix
> profileLoader { profiles = [ "base" "server" ]; }
```

### Build Configuration Locally

```bash
# Build without deploying
nixos-rebuild build --flake .#digitalocean

# Show what would change
nixos-rebuild dry-build --flake .#digitalocean
```

### Evaluate Options

```bash
# Show final value of an option
nix eval .#nixosConfigurations.digitalocean.config.networking.hostName

# Show all packages
nix eval .#nixosConfigurations.digitalocean.config.environment.systemPackages
```

---

## 📚 Best Practices

### DO ✅

- Use profiles for shared configuration
- Keep host configs minimal (only host-specific overrides)
- Use `lib.mkDefault` in profiles
- Document profile purpose and usage
- Test profiles in isolation
- Use feature flags for optional features
- Keep secrets in SOPS-encrypted files

### DON'T ❌

- Duplicate configuration across hosts
- Put secrets in configuration files
- Use `lib.mkForce` unless necessary
- Create overly complex profiles
- Mix concerns (keep profiles focused)
- Hardcode values that should be in `hosts.nix`

---

## 🔗 References

- [Profiles Documentation](./PROFILES.md)
- [Deploy Guide](./README-DEPLOY.md)
- [NixOS Options](https://search.nixos.org/options)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
