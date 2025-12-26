# Referencia Rápida de Módulos

Guía de consulta rápida para crear módulos en NixOS/nix-darwin.

## Template Básico

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.myApp;
in
{
  options.programs.myApp = {
    enable = mkEnableOption "My Application";

    setting = mkOption {
      type = types.str;
      default = "value";
      description = "Description";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.myApp ];
  };
}
```

## Tipos Comunes

```nix
# Booleano
enable = mkEnableOption "feature";

# String
name = mkOption {
  type = types.str;
  default = "default";
};

# Entero
port = mkOption {
  type = types.port;  # 1-65535
  default = 8080;
};

# Enum
level = mkOption {
  type = types.enum [ "debug" "info" "error" ];
  default = "info";
};

# Lista
items = mkOption {
  type = types.listOf types.str;
  default = [ ];
};

# Atributos
settings = mkOption {
  type = types.attrsOf types.str;
  default = { };
};

# Submodule
database = mkOption {
  type = types.submodule {
    options = {
      host = mkOption { type = types.str; default = "localhost"; };
      port = mkOption { type = types.port; default = 5432; };
    };
  };
};
```

## Validación

```nix
config = mkIf cfg.enable {
  # Assertions (bloquean build)
  assertions = [
    {
      assertion = cfg.port > 1024;
      message = "port must be > 1024";
    }
  ];

  # Warnings (no bloquean)
  warnings = optionals (cfg.debug) [
    "debug mode enabled"
  ];
};
```

## Generación de Archivos

```nix
let
  configFile = pkgs.writeText "config.conf" ''
    setting = ${cfg.setting}
    port = ${toString cfg.port}
  '';
in
{
  environment.etc."myapp/config".source = configFile;
}
```

## Condicionales

```nix
config = mkIf cfg.enable {
  # Simple
  environment.variables = mkIf cfg.debug {
    DEBUG = "1";
  };

  # Merge múltiples
  environment.systemPackages = mkMerge [
    [ pkgs.base ]
    (mkIf cfg.feature1 [ pkgs.feature1 ])
    (mkIf cfg.feature2 [ pkgs.feature2 ])
  ];
};
```

## Darwin Launch Agent

```nix
launchd.user.agents.myApp = {
  serviceConfig = {
    ProgramArguments = [ "${cfg.package}/bin/myapp" ];
    RunAtLoad = true;
    KeepAlive = true;
    ProcessType = "Interactive";
    StandardOutPath = "/tmp/myapp.log";
    StandardErrorPath = "/tmp/myapp.error.log";
  };
};
```

## NixOS Systemd Service

```nix
systemd.services.myApp = {
  description = "My Application";
  wantedBy = [ "multi-user.target" ];
  after = [ "network.target" ];

  serviceConfig = {
    ExecStart = "${cfg.package}/bin/myapp --port ${toString cfg.port}";
    Restart = "always";
    User = "myapp";
    Group = "myapp";
  };
};
```

## Profiles Predefinidos

```nix
options.services.myApp = {
  profile = mkOption {
    type = types.enum [ "minimal" "standard" "full" ];
    default = "standard";
  };
};

config = mkIf cfg.enable {
  services.myApp.workers = mkDefault (
    if cfg.profile == "minimal" then 1
    else if cfg.profile == "standard" then 4
    else 8
  );
};
```

## Testing

```bash
# Verificar sintaxis
nix-instantiate --parse module.nix

# Evaluar opción
nix eval .#nixosConfigurations.host.config.programs.myApp.enable

# Build dry-run
nix build .#nixosConfigurations.host.config.system.build.toplevel --dry-run

# Aplicar
darwin-rebuild switch --flake .
sudo nixos-rebuild switch --flake .
```

## Mejores Prácticas

### ✅ Hacer

- Usar tipos específicos (`types.port` en vez de `types.int`)
- Documentar todas las opciones
- Proveer defaults sensibles
- Validar con assertions
- Usar `mkDefault` para opciones sobreescribibles

### ❌ Evitar

- Defaults peligrosos (ej: puerto 80 requiere root)
- Opciones sin documentación
- Tipos demasiado genéricos
- Lógica compleja sin comentarios

## Shortcuts

```nix
# Import shortcuts
with lib;  # Permite usar mkOption en vez de lib.mkOption

# Enable option
enable = mkEnableOption "feature";
# Expande a:
enable = mkOption {
  type = types.bool;
  default = false;
  description = "Whether to enable feature.";
};

# Package option con defaultText
package = mkOption {
  type = types.package;
  default = pkgs.myApp;
  defaultText = literalExpression "pkgs.myApp";
};

# Lista de strings vacía
items = mkOption {
  type = types.listOf types.str;
  default = [ ];
};

# Atributos vacíos
settings = mkOption {
  type = types.attrs;
  default = { };
};
```

## Namespaces Recomendados

```nix
# Programas/aplicaciones de usuario
programs.myApp = { };

# Servicios del sistema
services.myService = { };

# Virtualización
virtualisation.myContainer = { };

# Networking
networking.myFirewall = { };

# Hardware
hardware.myDevice = { };

# Security
security.myAuth = { };
```

## Recursos

- [NixOS Module System](https://nixos.org/manual/nixos/stable/#sec-writing-modules)
- [Guía Completa](./MODULES_GUIDE.md)
- [Ejemplos](../examples/modules-usage.nix)
- [Módulos Disponibles](../modules/)
