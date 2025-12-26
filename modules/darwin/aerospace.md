# AeroSpace Module

NixOS/nix-darwin module for [AeroSpace](https://github.com/nikitabobko/AeroSpace) - a tiling window manager for macOS.

## Overview

AeroSpace is an i3-like tiling window manager for macOS. This module provides:
- Declarative configuration via Nix
- Automatic TOML generation from Nix attributes
- Type-safe options with validation
- Default key bindings following i3 conventions
- Launch agent configuration

## Features

- ✅ Type-safe configuration with validation
- ✅ Default vi-style keybindings (hjkl)
- ✅ Workspace management
- ✅ Gap configuration
- ✅ Auto-start at login
- ✅ Custom keybindings
- ✅ Multiple layout algorithms
- ✅ Home Manager integration

## Quick Start

### Basic Usage

```nix
{
  programs.aerospace = {
    enable = true;
    startAtLogin = true;

    gaps = {
      inner = 10;
      outer = 10;
    };
  };
}
```

### Custom Keybindings

```nix
{
  programs.aerospace = {
    enable = true;

    keybindings = {
      # Focus windows (vim-style)
      "cmd-h" = "focus left";
      "cmd-j" = "focus down";
      "cmd-k" = "focus up";
      "cmd-l" = "focus right";

      # Move windows
      "cmd-shift-h" = "move left";
      "cmd-shift-j" = "move down";
      "cmd-shift-k" = "move up";
      "cmd-shift-l" = "move right";

      # Launch applications
      "cmd-enter" = "exec-and-forget open -a kitty";
      "cmd-shift-enter" = "exec-and-forget open -a Firefox";

      # Workspace switching
      "cmd-1" = "workspace 1";
      "cmd-2" = "workspace 2";
      "cmd-3" = "workspace 3";
    };
  };
}
```

### Advanced Configuration

```nix
{
  programs.aerospace = {
    enable = true;
    startAtLogin = true;

    gaps = {
      inner = 8;
      outer = 12;
    };

    workspaces = [ 1 2 3 4 5 6 ];
    autoLayout = "tiles";
    enableSoundEffects = false;

    # Use raw TOML for advanced features
    extraConfig = ''
      # Resize mode
      [mode.resize.binding]
      h = "resize width -50"
      l = "resize width +50"
      k = "resize height -50"
      j = "resize height +50"
      esc = "mode main"

      # Application-specific rules
      [[on-window-detected]]
      if.app-id = 'com.apple.Terminal'
      run = 'move-node-to-workspace 1'

      [[on-window-detected]]
      if.app-id = 'com.google.Chrome'
      run = 'move-node-to-workspace 2'
    '';
  };
}
```

## Options Reference

### `programs.aerospace.enable`
- **Type**: `boolean`
- **Default**: `false`
- **Description**: Whether to enable AeroSpace tiling window manager.

### `programs.aerospace.package`
- **Type**: `package`
- **Default**: `pkgs.aerospace`
- **Description**: The aerospace package to use.

### `programs.aerospace.startAtLogin`
- **Type**: `boolean`
- **Default**: `true`
- **Description**: Whether to start AeroSpace at login via Launch Agent.

### `programs.aerospace.keybindings`
- **Type**: `attribute set of strings`
- **Default**: Vi-style keybindings with `alt` modifier
- **Description**: Key bindings mapping. Format: `"modifier-key" = "command"`.

**Default keybindings**:
```
alt-h/j/k/l          : Focus left/down/up/right
alt-shift-h/j/k/l    : Move left/down/up/right
alt-1..5             : Switch to workspace 1-5
alt-shift-1..5       : Move window to workspace 1-5
alt-r                : Enter resize mode
```

### `programs.aerospace.gaps.inner`
- **Type**: `integer`
- **Default**: `8`
- **Description**: Inner gap between windows in pixels.

### `programs.aerospace.gaps.outer`
- **Type**: `integer`
- **Default**: `8`
- **Description**: Outer gap from screen edge in pixels.

### `programs.aerospace.workspaces`
- **Type**: `list of integers`
- **Default**: `[ 1 2 3 4 5 ]`
- **Description**: List of workspace numbers to configure.

### `programs.aerospace.autoLayout`
- **Type**: `enum`
- **Values**: `"tiles"`, `"accordion"`, `"horizontal"`, `"vertical"`
- **Default**: `"tiles"`
- **Description**: Default automatic layout algorithm.

### `programs.aerospace.enableSoundEffects`
- **Type**: `boolean`
- **Default**: `false`
- **Description**: Whether to enable sound effects for window operations.

### `programs.aerospace.extraConfig`
- **Type**: `strings (multi-line)`
- **Default**: `""`
- **Description**: Extra TOML configuration to append to the config file.

### `programs.aerospace.settings`
- **Type**: `attribute set`
- **Default**: `{}`
- **Description**: Additional settings as Nix attributes (converted to TOML).

## Integration with Profiles

You can create a profile that enables aerospace:

**`lib/profiles/darwin/aerospace.nix`**:
```nix
{ config, pkgs, lib, ... }:

{
  programs.aerospace = {
    enable = lib.mkDefault true;
    startAtLogin = true;

    gaps = {
      inner = 10;
      outer = 10;
    };

    keybindings = {
      "cmd-h" = "focus left";
      "cmd-l" = "focus right";
      "cmd-j" = "focus down";
      "cmd-k" = "focus up";
      "cmd-enter" = "exec-and-forget open -a kitty";
    };
  };
}
```

Then use it in `hosts.nix`:
```nix
{
  darwin.macbook-pro = {
    profiles = [
      "base"
      "development"
      "darwin/aerospace"  # Add aerospace profile
    ];
  };
}
```

## Troubleshooting

### AeroSpace not starting
Check the logs:
```bash
tail -f /tmp/aerospace.log
tail -f /tmp/aerospace.error.log
```

### Configuration not applying
Rebuild your configuration:
```bash
darwin-rebuild switch --flake .#macbook-pro
```

Then restart AeroSpace:
```bash
killall aerospace
open -a AeroSpace
```

### Accessibility permissions
AeroSpace requires accessibility permissions. Grant them in:
**System Preferences → Security & Privacy → Accessibility**

## Resources

- [AeroSpace GitHub](https://github.com/nikitabobko/AeroSpace)
- [AeroSpace Documentation](https://nikitabobko.github.io/AeroSpace/guide)
- [TOML Configuration Format](https://toml.io/)

## Examples

See `examples/aerospace/` directory for complete configuration examples.
