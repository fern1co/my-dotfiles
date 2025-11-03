# Modules Directory

This directory contains reusable NixOS/nix-darwin modules that can be imported into any configuration.

## Structure

- `darwin/` - Darwin-specific modules (macOS)
- `nixos/` - NixOS-specific modules (Linux)
- `shared/` - Cross-platform modules

## Usage

Import modules into your configuration:

```nix
imports = [
  ../../modules/shared/dev-tools.nix
  ../../modules/darwin/aerospace.nix
];
```

## Creating New Modules

Modules should:
1. Be self-contained and reusable
2. Use options for configuration when appropriate
3. Include inline documentation
4. Follow Nix best practices

Example module template:

```nix
{ config, lib, pkgs, ... }:

with lib;

{
  options = {
    myModule.enable = mkEnableOption "Enable my module";
  };

  config = mkIf config.myModule.enable {
    # Module configuration
  };
}
```
