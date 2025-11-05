# 🔄 Migration Guide: Implementing Profiles System

## Overview

This guide walks you through migrating your existing host configurations to use the new profiles system.

---

## ✅ What's Been Implemented

### 1. **Profiles System** (`lib/profiles/`)

Created modular configuration profiles:
- ✅ `base/` - Common configuration for all systems
- ✅ `server/` - Server-specific optimizations
- ✅ `server/digitalocean` - DigitalOcean-specific config
- ✅ `development/` - Development tools and environment
- ✅ `security/hardened` - Security hardening profile

### 2. **Enhanced hosts.nix**

Upgraded with comprehensive metadata:
- Network configuration (hostname, IP, SSH)
- Profile assignments
- Role and environment tags
- Resource information
- Deployment configuration
- Feature flags

### 3. **Profile Loader** (`lib/profiles/default.nix`)

Automatic profile import system that:
- Loads profiles based on `hosts.nix` configuration
- Supports nested profiles (`server/digitalocean`)
- Provides clean composition

### 4. **Refactored DigitalOcean Config**

Updated `lib/nixos/digitalocean/configuration.nix` to:
- Use profile loader
- Import config from `hosts.nix`
- Significantly reduced lines of code
- Improved maintainability

---

## 📋 Migration Checklist

### For DigitalOcean Host (Already Done ✅)

- [x] Create profile structure
- [x] Extract common config to profiles
- [x] Update hosts.nix with metadata
- [x] Refactor configuration.nix to use profiles
- [x] Test build

### For Other Hosts (TODO)

#### Home Laptop
- [ ] Review current configuration
- [ ] Identify common patterns to extract
- [ ] Add profile assignments to hosts.nix
- [ ] Update configuration.nix
- [ ] Test build

#### N1co Work Machine
- [ ] Review current configuration
- [ ] Identify common patterns to extract
- [ ] Add profile assignments to hosts.nix
- [ ] Update configuration.nix
- [ ] Test build

#### Darwin Configurations
- [ ] Create Darwin-specific profiles
- [ ] Update hosts.nix structure
- [ ] Refactor configurations
- [ ] Test builds

---

## 🔧 Step-by-Step Migration

### Step 1: Analyze Current Configuration

Look at your existing host config and identify:

1. **What's common** (goes to profiles)
   - SSH configuration
   - Basic packages
   - Nix settings
   - Firewall rules

2. **What's specific** (stays in host config)
   - Hostname
   - User definitions
   - Hardware-specific settings
   - Host-unique services

### Step 2: Choose Appropriate Profiles

Based on the host's role, select profiles:

**Server:**
```nix
profiles = [ "base" "server" "development" ];
```

**Workstation:**
```nix
profiles = [ "base" "development" ];
```

**Hardened Server:**
```nix
profiles = [ "base" "server" "security/hardened" ];
```

### Step 3: Update hosts.nix

Add complete metadata for the host:

```nix
{
  myhost = {
    # Network
    hostname = "192.168.1.100";
    hostName = "myhost";

    # System
    system = "x86_64-linux";
    username = "myuser";

    # Profiles
    profiles = [
      "base"
      "server"
      "development"
    ];

    # Metadata
    role = "server";
    environment = "production";
    platform = "physical";

    # Features
    features = {
      docker = true;
      monitoring = false;
    };
  };
}
```

### Step 4: Refactor configuration.nix

Transform from monolithic to modular:

**Before:**
```nix
{ config, pkgs, ... }:
{
  # 200+ lines of mixed configuration
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  # ... tons more config
}
```

**After:**
```nix
{ inputs, username }: { config, pkgs, lib, ... }:

let
  hosts = import ../../../hosts.nix;
  hostConfig = hosts.myhost;
  profileLoader = import ../../profiles/default.nix;
  profileImports = profileLoader { profiles = hostConfig.profiles; };
in
{
  imports = [
    ./hardware.nix
  ] ++ profileImports;

  # Only host-specific config
  networking.hostName = hostConfig.hostName;

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  system.stateVersion = "24.05";
}
```

### Step 5: Test Build

```bash
# Build locally
nix build .#nixosConfigurations.myhost.config.system.build.toplevel

# Or with nixos-rebuild
nixos-rebuild build --flake .#myhost
```

### Step 6: Deploy (if needed)

```bash
# For deploy-rs
nix run .#deploy -- --remote-build .#myhost

# Or with nixos-rebuild
nixos-rebuild switch --flake .#myhost --target-host myhost
```

---

## 🎯 Migration Examples

### Example 1: Simple Server

**Current config (100 lines):**
```nix
{
  services.openssh.enable = true;
  networking.firewall.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = [ pkgs.git pkgs.vim ];
  # ... 90 more lines
}
```

**After migration (15 lines):**
```nix
let
  profileImports = profileLoader { profiles = [ "base" "server" ]; };
in {
  imports = profileImports;
  networking.hostName = "myserver";
  users.users.myuser = { /* ... */ };
  system.stateVersion = "24.05";
}
```

**Savings:** 85 lines → reusable profiles

### Example 2: Development Workstation

**hosts.nix:**
```nix
workstation = {
  hostname = "localhost";
  system = "x86_64-linux";
  username = "developer";
  profiles = [ "base" "development" ];
  role = "workstation";
  features.docker = true;
};
```

**configuration.nix:**
```nix
let
  hostConfig = hosts.workstation;
  profileImports = profileLoader { profiles = hostConfig.profiles; };
in {
  imports = [ ./hardware.nix ] ++ profileImports;

  # Enable Docker (defined in features)
  virtualisation.docker.enable = hostConfig.features.docker;

  # Host-specific
  networking.hostName = hostConfig.hostName;
  users.users.${username} = { /* ... */ };
}
```

---

## 🐛 Common Issues & Solutions

### Issue 1: Profile Not Found

**Error:**
```
error: file 'lib/profiles/myprofile/default.nix' not found
```

**Solution:**
Check spelling in hosts.nix, ensure profile exists:
```bash
ls lib/profiles/myprofile/default.nix
```

### Issue 2: Option Defined Multiple Times

**Error:**
```
The option 'services.openssh.enable' is defined multiple times
```

**Solution:**
Remove duplicate definition from host config (it's in profile) or use `lib.mkForce`:
```nix
services.openssh.enable = lib.mkForce false;
```

### Issue 3: Infinite Recursion

**Error:**
```
error: infinite recursion encountered
```

**Cause:** Circular imports between profiles and host config

**Solution:** Remove circular dependency, ensure profiles don't import host configs

### Issue 4: Missing hostConfig

**Error:**
```
error: attribute 'myhost' missing
```

**Solution:** Ensure host is defined in hosts.nix with correct name

---

## 📊 Migration Progress Tracker

### Hosts Status

| Host | Status | Profiles Used | Lines Saved |
|------|--------|---------------|-------------|
| digitalocean | ✅ Migrated | base, server, server/digitalocean, development | ~70 lines |
| home_laptop | 🔄 TODO | - | - |
| n1co | 🔄 TODO | - | - |
| darwin-aarch64 | 🔄 TODO | - | - |
| darwin-x86_64 | 🔄 TODO | - | - |
| macbook-pro | 🔄 TODO | - | - |

### Profiles Status

| Profile | Status | Hosts Using | Notes |
|---------|--------|-------------|-------|
| base | ✅ Complete | 1 | Core functionality |
| server | ✅ Complete | 1 | Server optimization |
| server/digitalocean | ✅ Complete | 1 | DO-specific |
| development | ✅ Complete | 1 | Dev tools |
| security/hardened | ✅ Complete | 0 | For production |

---

## 🎓 Learning Resources

### Understanding Profiles

```bash
# View profile content
cat lib/profiles/base/default.nix

# See what profiles provide
nix eval .#nixosConfigurations.digitalocean.config.environment.systemPackages
```

### Testing Profiles

```bash
# Build with specific profile
nix build .#nixosConfigurations.myhost.config.system.build.toplevel

# Check what changed
nix diff-closures /run/current-system ./result
```

### Documentation

- [PROFILES.md](./PROFILES.md) - Complete profiles documentation
- [ARCHITECTURE.md](./ARCHITECTURE.md) - System architecture
- [README-DEPLOY.md](./README-DEPLOY.md) - Deployment guide

---

## 🚀 Next Steps

1. **Review this guide** and understand the pattern
2. **Choose next host** to migrate
3. **Follow step-by-step process** above
4. **Test thoroughly** before deploying
5. **Document any new patterns** you discover
6. **Create additional profiles** as needed

---

## 💡 Tips

- Start with a non-critical host for practice
- Test in a VM before deploying to production
- Keep commits small and atomic
- Document profile choices in host comments
- Use `git checkout -b migrate-myhost` for each migration
