# 📦 Profiles System Documentation

## Overview

The profiles system provides modular, reusable NixOS configurations that can be composed together to build complete system configurations. This allows for:

- ✅ **Code reuse** across multiple hosts
- ✅ **Consistent configuration** for similar roles
- ✅ **Easy maintenance** with centralized profile updates
- ✅ **Clear separation** between host-specific and shared config

---

## 📁 Directory Structure

```
lib/profiles/
├── default.nix                    # Profile loader
├── base/
│   └── default.nix                # Common config for all systems
├── server/
│   ├── default.nix                # Generic server config
│   └── digitalocean.nix           # DigitalOcean-specific config
├── development/
│   └── default.nix                # Development tools
└── security/
    └── hardened.nix               # Hardened security config
```

---

## 🎯 Available Profiles

### `base` - Foundation Profile

**Purpose:** Common configuration for all systems

**Includes:**
- Nix flakes and nix-command
- Store auto-optimization
- Essential packages (git, curl, wget, htop, neovim)
- Basic environment variables
- Unfree package support

**Use on:** All systems

---

### `server` - Server Profile

**Purpose:** Headless server optimization and security

**Includes:**
- SSH with key-only authentication
- Fail2ban for brute force protection
- Server monitoring tools
- Automatic garbage collection
- Disabled documentation (saves space)
- Firewall enabled by default
- Journald log limits

**Packages:**
- sops, age (secrets management)
- tree, ncdu, iotop, lsof, strace (monitoring)

**Use on:** Servers, VPS, headless systems

---

### `server/digitalocean` - DigitalOcean Optimization

**Purpose:** DigitalOcean-specific configuration

**Includes:**
- Cloud-init for metadata service
- QEMU guest optimization
- UTC timezone by default
- Common web server ports (22, 80, 443)

**Use on:** DigitalOcean droplets only

---

### `development` - Development Tools

**Purpose:** Software development environment

**Includes:**
- Version control (git, gh)
- Build tools (gcc, make)
- Container tools (docker-compose)
- Language servers (nil, nixpkgs-fmt, alejandra)
- Debugging tools (gdb, valgrind)
- File management (ripgrep, fd, jq)
- System monitoring (btop)
- Optional Docker with auto-prune

**Use on:** Developer workstations, build servers

---

### `security/hardened` - Enhanced Security

**Purpose:** Production-grade security hardening

**Includes:**
- Strict SSH configuration (no password, no root)
- Strict firewall (log refused connections)
- Kernel hardening (sysctl)
- Sudo password always required
- Disabled IP forwarding
- SYN cookie protection
- Reverse path filtering

**Use on:** Production servers, security-critical systems

**⚠️ Warning:** This profile is strict. Test thoroughly before deploying to production.

---

## 🔧 Using Profiles

### 1. In hosts.nix

Define which profiles each host should use:

```nix
{
  myserver = {
    hostname = "192.168.1.100";
    system = "x86_64-linux";
    username = "myuser";

    # Define profiles for this host
    profiles = [
      "base"
      "server"
      "development"
    ];
  };
}
```

### 2. In Host Configuration

The profile loader automatically imports profiles:

```nix
{ inputs, username }: { config, pkgs, lib, ... }:

let
  hosts = import ../../../hosts.nix;
  hostConfig = hosts.myserver;

  # Load profiles
  profileLoader = import ../../profiles/default.nix;
  profileImports = profileLoader { profiles = hostConfig.profiles; };
in
{
  imports = [
    # Your host-specific config
  ] ++ profileImports;  # Auto-import profiles

  # Host-specific overrides here
  # ...
}
```

---

## 📝 Creating New Profiles

### Profile Structure

**Simple profile** (single file):
```
lib/profiles/myprofile/default.nix
```

**Profile with submodules:**
```
lib/profiles/myprofile/
├── default.nix
├── variant1.nix
└── variant2.nix
```

### Example: Creating a Monitoring Profile

```nix
# lib/profiles/monitoring/default.nix
{ config, pkgs, lib, ... }:

{
  # Enable Prometheus node exporter
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "systemd" ];
    port = 9100;
  };

  # Open firewall for monitoring
  networking.firewall.allowedTCPPorts = [ 9100 ];

  # Monitoring tools
  environment.systemPackages = with pkgs; [
    grafana
    prometheus
  ];
}
```

**Usage:**
```nix
# In hosts.nix
profiles = [ "base" "server" "monitoring" ];
```

---

## 🎨 Profile Best Practices

### 1. **Use `lib.mkDefault` for Overridable Options**

Allow host configs to override profile settings:

```nix
# In profile
networking.firewall.enable = lib.mkDefault true;

# In host config (overrides profile)
networking.firewall.enable = false;
```

### 2. **Keep Profiles Focused**

Each profile should have a single, clear purpose:
- ✅ Good: `server`, `development`, `security/hardened`
- ❌ Bad: `everything`, `misc`, `random-stuff`

### 3. **Document Profile Purpose**

Always include comments explaining:
- What the profile does
- When to use it
- Dependencies or requirements

### 4. **Use Feature Flags in hosts.nix**

For optional features within profiles:

```nix
# In hosts.nix
features = {
  docker = true;
  monitoring = false;
};

# In profile
virtualisation.docker.enable = hostConfig.features.docker or false;
```

### 5. **Avoid Conflicts**

Profiles should be composable without conflicts:
- Don't set the same option to different values in different profiles
- Use `lib.mkDefault` for default values
- Use `lib.mkForce` only when absolutely necessary

---

## 📋 Profile Composition Examples

### Minimal Server
```nix
profiles = [ "base" "server" ];
```

### Development Server
```nix
profiles = [ "base" "server" "development" ];
```

### Hardened Production Server
```nix
profiles = [ "base" "server" "security/hardened" ];
```

### DigitalOcean Production
```nix
profiles = [
  "base"
  "server"
  "server/digitalocean"
  "security/hardened"
];
```

### Developer Workstation
```nix
profiles = [ "base" "development" ];
```

---

## 🔍 Debugging Profile Loading

### Check which profiles are loaded:

```bash
# Show imported modules
nix repl
> :lf .
> nixosConfigurations.myhost.config._module.args.profiles
```

### Verify profile exists:

```bash
ls lib/profiles/myprofile/default.nix
```

### Test profile in isolation:

```nix
# Create test configuration
{
  imports = [ ./lib/profiles/myprofile ];
  # ... minimal config
}
```

---

## 🚀 Migration Guide

### From Monolithic to Profiles

**Before:**
```nix
# lib/nixos/myhost/configuration.nix
{ ... }:
{
  # 200 lines of mixed configuration
  services.openssh.enable = true;
  environment.systemPackages = [ ... ];
  networking.firewall.enable = true;
  # etc...
}
```

**After:**
```nix
# hosts.nix
myhost.profiles = [ "base" "server" "development" ];

# lib/nixos/myhost/configuration.nix
{ ... }:
let
  profileLoader = import ../../profiles/default.nix;
  profileImports = profileLoader { profiles = hostConfig.profiles; };
in
{
  imports = profileImports;

  # Only host-specific config
  networking.hostName = "myhost";
  users.users.myuser = { ... };
}
```

---

## 📚 Advanced Usage

### Conditional Profile Loading

```nix
let
  baseProfiles = [ "base" ];
  roleProfiles = if hostConfig.role == "server"
                 then [ "server" ]
                 else [ "desktop" ];
  allProfiles = baseProfiles ++ roleProfiles;
in
profileLoader { profiles = allProfiles; }
```

### Profile Parameters

```nix
# Profile with parameters
{ diskSize ? 50, ... }:
{
  services.myservice.diskLimit = diskSize;
}

# Usage in host config
imports = [
  (import ../../profiles/myprofile { diskSize = 100; })
];
```

---

## 🐛 Troubleshooting

### Issue: Profile not found

**Error:** `error: file 'lib/profiles/myprofile/default.nix' not found`

**Solution:** Check profile name spelling in hosts.nix

### Issue: Infinite recursion

**Cause:** Circular imports between profiles

**Solution:** Remove circular dependencies, use `mkDefault` for defaults

### Issue: Option conflicts

**Error:** `The option 'services.myservice.enable' is defined multiple times`

**Solution:**
- Use `lib.mkDefault` in profiles
- Use `lib.mkForce` in host config to override

---

## 📖 References

- [NixOS Module System](https://nixos.org/manual/nixos/stable/index.html#sec-writing-modules)
- [Module Priorities](https://nixos.org/manual/nixos/stable/index.html#sec-option-definitions)
- [Best Practices](https://nix.dev/tutorials/module-system/index.html)
