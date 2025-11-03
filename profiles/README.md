# Profiles Directory

Configuration profiles provide preset combinations of packages and settings for different use cases.

## Available Profiles

### `workstation.nix`
Full-featured desktop/laptop environment with:
- Complete development toolchain
- Kubernetes and cloud tools
- Modern terminal setup (kitty, tmux, zsh)
- CLI enhancements (bat, lsd, fzf)

**Use for**: Primary development machines, daily drivers

### `server.nix`
Minimal server environment with:
- Essential command-line tools
- Basic system administration utilities
- Lightweight configuration

**Use for**: Production servers, minimal VPS instances

### `development.nix`
Development-focused environment with:
- Multiple language toolchains (Go, Rust, Python, Node.js, .NET)
- Development-specific tools and utilities
- Container/Kubernetes tools

**Use for**: Specialized development environments, CI/CD runners

## Usage

Import a profile in your home-manager configuration:

```nix
imports = [
  ../../profiles/workstation.nix
];
```

## Customization

Profiles can be:
1. **Extended**: Import a profile and add additional packages
2. **Overridden**: Import and selectively override options
3. **Combined**: Mix multiple profiles (use with caution)

Example extending a profile:

```nix
imports = [
  ../../profiles/development.nix
];

home.packages = with pkgs; [
  # Additional tools specific to this machine
  ansible
  terraform
];
```

## Creating Custom Profiles

When creating a new profile:
1. Start with a clear use case in mind
2. Keep profiles focused and coherent
3. Document the intended use case
4. Test on a fresh system if possible
