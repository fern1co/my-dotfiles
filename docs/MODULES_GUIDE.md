# Guía para Crear Módulos en NixOS/nix-darwin

Esta guía te muestra cómo crear módulos personalizados y reutilizables para tu configuración de NixOS o nix-darwin.

## Tabla de Contenidos

1. [¿Qué son los Módulos?](#qué-son-los-módulos)
2. [Diferencia entre Profiles y Modules](#diferencia-entre-profiles-y-modules)
3. [Estructura de un Módulo](#estructura-de-un-módulo)
4. [Tipos de Opciones](#tipos-de-opciones)
5. [Patrones Comunes](#patrones-comunes)
6. [Ejemplos Completos](#ejemplos-completos)
7. [Mejores Prácticas](#mejores-prácticas)

## ¿Qué son los Módulos?

Los módulos en NixOS/nix-darwin son **configuraciones declarativas con opciones**, validación y lógica condicional. Son más potentes que los profiles porque:

- ✅ Definen **opciones configurables** con tipos y validación
- ✅ Permiten **personalización** por parte del usuario
- ✅ Incluyen **documentación integrada**
- ✅ Soportan **validación** y mensajes de error útiles
- ✅ Pueden generar **configuraciones dinámicas**

## Diferencia entre Profiles y Modules

| Característica | Profiles | Modules |
|----------------|----------|---------|
| **Propósito** | Configuraciones predefinidas | Opciones configurables |
| **Personalización** | Limitada (via mkDefault) | Completa (via options) |
| **Validación** | No | Sí (tipos, assertions) |
| **Documentación** | Comentarios | man pages automáticas |
| **Uso** | `profiles = ["base"]` | `programs.foo.enable = true` |

**Cuándo usar cada uno**:
- **Profiles**: Configuraciones completas listas para usar (ej: `development`, `server`)
- **Modules**: Software específico que necesita configuración (ej: `aerospace`, `nginx`)

## Estructura de un Módulo

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.myApp;  # Namespace de tu módulo
in
{
  # 1. OPCIONES: Define qué puede configurar el usuario
  options.programs.myApp = {
    enable = mkEnableOption "My Application";

    setting = mkOption {
      type = types.str;
      default = "value";
      description = "Description of the setting";
    };
  };

  # 2. CONFIG: Define qué hace el módulo cuando está habilitado
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.myApp ];
    # ... más configuración
  };

  # 3. META (opcional): Metadatos del módulo
  meta = {
    maintainers = [ "your-name" ];
    doc = ./myapp.md;
  };
}
```

### Componentes Principales

1. **`let cfg = ...`**: Variable para acceder a la configuración del módulo
2. **`options`**: Define las opciones que el usuario puede configurar
3. **`config`**: Implementación cuando el módulo está habilitado
4. **`meta`**: Información del módulo (opcional)

## Tipos de Opciones

### Tipos Básicos

```nix
{
  # Booleano
  enable = mkEnableOption "feature";

  # String
  name = mkOption {
    type = types.str;
    default = "default";
    description = "A string value";
  };

  # Entero
  port = mkOption {
    type = types.int;
    default = 8080;
    description = "Port number";
  };

  # Float
  ratio = mkOption {
    type = types.float;
    default = 0.5;
    description = "A ratio value";
  };

  # Enum (lista de valores permitidos)
  level = mkOption {
    type = types.enum [ "debug" "info" "warning" "error" ];
    default = "info";
    description = "Log level";
  };
}
```

### Tipos Compuestos

```nix
{
  # Lista
  items = mkOption {
    type = types.listOf types.str;
    default = [ ];
    example = [ "item1" "item2" ];
    description = "List of items";
  };

  # Conjunto de atributos
  settings = mkOption {
    type = types.attrsOf types.str;
    default = { };
    example = { key = "value"; };
    description = "Key-value settings";
  };

  # Submodule (opciones anidadas)
  database = mkOption {
    type = types.submodule {
      options = {
        host = mkOption {
          type = types.str;
          default = "localhost";
        };
        port = mkOption {
          type = types.port;
          default = 5432;
        };
      };
    };
    default = { };
    description = "Database configuration";
  };

  # Package
  package = mkOption {
    type = types.package;
    default = pkgs.myApp;
    defaultText = literalExpression "pkgs.myApp";
    description = "Package to use";
  };
}
```

### Tipos Especiales

```nix
{
  # Múltiples líneas de texto
  script = mkOption {
    type = types.lines;
    default = "";
    description = "Shell script";
  };

  # Ruta (path)
  configFile = mkOption {
    type = types.path;
    description = "Path to config file";
  };

  # Puerto (1-65535)
  port = mkOption {
    type = types.port;
    default = 8080;
    description = "Server port";
  };

  # Cualquier valor (no recomendado)
  raw = mkOption {
    type = types.attrs;
    default = { };
    description = "Raw attributes";
  };
}
```

## Patrones Comunes

### 1. Módulo Simple con Enable

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.myService;
in
{
  options.services.myService = {
    enable = mkEnableOption "My Service";

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port to listen on";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.myService ];

    # Launch service
    systemd.services.myService = {
      description = "My Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.myService}/bin/myservice --port ${toString cfg.port}";
        Restart = "always";
      };
    };
  };
}
```

### 2. Generación de Archivos de Configuración

```nix
let
  cfg = config.programs.myApp;

  # Generar archivo de configuración
  configFile = pkgs.writeText "myapp.conf" ''
    port = ${toString cfg.port}
    host = ${cfg.host}
    debug = ${if cfg.debug then "true" else "false"}
    ${cfg.extraConfig}
  '';
in
{
  config = mkIf cfg.enable {
    environment.etc."myapp/config.conf".source = configFile;
  };
}
```

### 3. Módulo con Múltiples Modos

```nix
{
  options.services.myApp = {
    enable = mkEnableOption "My App";

    mode = mkOption {
      type = types.enum [ "development" "production" ];
      default = "production";
      description = "Operation mode";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.myApp ];

    # Configuración específica por modo
    environment.variables = mkMerge [
      # Común para todos los modos
      { MY_APP_HOME = "/var/lib/myapp"; }

      # Solo en development
      (mkIf (cfg.mode == "development") {
        MY_APP_DEBUG = "1";
        MY_APP_LOG_LEVEL = "debug";
      })

      # Solo en production
      (mkIf (cfg.mode == "production") {
        MY_APP_OPTIMIZE = "1";
        MY_APP_LOG_LEVEL = "warn";
      })
    ];
  };
}
```

### 4. Validación y Assertions

```nix
{
  config = mkIf cfg.enable {
    # ... configuración ...

    # Validaciones
    assertions = [
      {
        assertion = cfg.port > 1024;
        message = "myApp: port must be > 1024 for non-root user";
      }
      {
        assertion = cfg.workers > 0;
        message = "myApp: at least 1 worker required";
      }
      {
        assertion = cfg.maxConnections >= cfg.workers;
        message = "myApp: maxConnections must be >= workers";
      }
    ];

    # Advertencias (no bloquean la build)
    warnings = optionals (cfg.debug) [
      "myApp: debug mode enabled - not recommended for production"
    ];
  };
}
```

### 5. Perfiles Predefinidos

```nix
{
  options.services.myApp = {
    enable = mkEnableOption "My App";

    profile = mkOption {
      type = types.enum [ "minimal" "standard" "full" ];
      default = "standard";
      description = "Preset configuration profile";
    };
  };

  config = mkIf cfg.enable {
    services.myApp.workers = mkDefault (
      if cfg.profile == "minimal" then 1
      else if cfg.profile == "standard" then 4
      else 8
    );

    services.myApp.cacheSize = mkDefault (
      if cfg.profile == "minimal" then "128M"
      else if cfg.profile == "standard" then "512M"
      else "2G"
    );
  };
}
```

### 6. Módulo Darwin (Launch Agent)

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.myDaemon;
in
{
  options.services.myDaemon = {
    enable = mkEnableOption "My Daemon";
    interval = mkOption {
      type = types.int;
      default = 3600;
      description = "Run interval in seconds";
    };
  };

  config = mkIf cfg.enable {
    launchd.user.agents.myDaemon = {
      serviceConfig = {
        ProgramArguments = [ "${pkgs.myDaemon}/bin/mydaemon" ];
        StartInterval = cfg.interval;
        RunAtLoad = true;
        KeepAlive = false;
        ProcessType = "Background";
        StandardOutPath = "/tmp/mydaemon.log";
        StandardErrorPath = "/tmp/mydaemon.error.log";
      };
    };
  };
}
```

## Ejemplos Completos

### Ejemplo 1: AeroSpace (Window Manager)

Ver: [`modules/darwin/aerospace.nix`](../modules/darwin/aerospace.nix)

**Características**:
- ✅ Opciones configurables (gaps, keybindings, workspaces)
- ✅ Conversión de Nix a TOML
- ✅ Keybindings predeterminados
- ✅ Launch Agent para auto-inicio
- ✅ Validación de opciones
- ✅ Documentación completa

**Uso**:
```nix
{
  programs.aerospace = {
    enable = true;
    gaps = { inner = 10; outer = 10; };
    keybindings = {
      "cmd-h" = "focus left";
      "cmd-l" = "focus right";
    };
  };
}
```

### Ejemplo 2: Firewall Profiles (NixOS)

Ver: [`modules/nixos/firewall-rules.nix`](../modules/nixos/firewall-rules.nix)

**Características**:
- ✅ Perfiles predefinidos (web, ssh, dns, homelab)
- ✅ Reglas personalizadas
- ✅ Trusted interfaces
- ✅ Logging configurable
- ✅ Activation scripts informativos

**Uso**:
```nix
{
  networking.firewall.profiles = {
    enable = true;
    activeProfiles = [ "web" "ssh" "homelab" ];
    customRules = {
      minecraft = {
        tcp = [ 25565 ];
        udp = [ 19132 ];
        description = "Minecraft server";
      };
    };
  };
}
```

### Ejemplo 3: Development Environment (Shared)

Ver: [`modules/shared/dev-environment.nix`](../modules/shared/dev-environment.nix)

**Características**:
- ✅ Multi-lenguaje (JS, Python, Rust, Go, Java, Nix)
- ✅ Herramientas por categorías
- ✅ Shell aliases y functions
- ✅ Variables de entorno
- ✅ Funciona en NixOS y Darwin

**Uso**:
```nix
{
  programs.devEnvironment = {
    enable = true;
    languages = [ "javascript" "python" "rust" ];
    tools.containers = true;
    extraPackages = [ pkgs.kubectl ];
  };
}
```

## Mejores Prácticas

### 1. Organización

```nix
# ✅ Bueno: Namespace lógico
config.programs.myApp.enable
config.services.myService.enable

# ❌ Malo: Sin namespace
config.myApp.enable
```

### 2. Defaults Sensibles

```nix
# ✅ Bueno: Valores por defecto seguros
port = mkOption {
  type = types.port;
  default = 8080;  # Puerto no privilegiado
  description = "Port to listen on";
};

# ❌ Malo: Default peligroso
port = mkOption {
  type = types.port;
  default = 80;  # Requiere root
};
```

### 3. Documentación

```nix
# ✅ Bueno: Documentación completa
setting = mkOption {
  type = types.str;
  default = "value";
  example = "custom-value";
  description = ''
    Detailed description of what this setting does.
    Can include multiple lines and examples.
  '';
};

# ❌ Malo: Sin documentación
setting = mkOption {
  type = types.str;
  default = "value";
};
```

### 4. Validación

```nix
# ✅ Bueno: Validar inputs
assertions = [
  {
    assertion = cfg.maxConnections >= cfg.minConnections;
    message = "maxConnections must be >= minConnections";
  }
];

# ❌ Malo: Sin validación (puede causar errores confusos)
```

### 5. Composición

```nix
# ✅ Bueno: Usar mkMerge para combinar
config = mkIf cfg.enable {
  environment.systemPackages = mkMerge [
    [ pkgs.basePackage ]
    (mkIf cfg.feature1 [ pkgs.feature1Package ])
    (mkIf cfg.feature2 [ pkgs.feature2Package ])
  ];
};

# ❌ Malo: Lógica compleja anidada
```

### 6. Tipos Específicos

```nix
# ✅ Bueno: Usar tipos específicos
port = mkOption {
  type = types.port;  # Solo 1-65535
  default = 8080;
};

# ❌ Malo: Tipo demasiado genérico
port = mkOption {
  type = types.int;  # Permite negativos
  default = 8080;
};
```

## Cómo Usar los Módulos

### Método 1: Importar Directamente

```nix
# En tu configuration.nix
{
  imports = [
    ../../modules/darwin/aerospace.nix
    ../../modules/shared/dev-environment.nix
  ];

  programs.aerospace.enable = true;
  programs.devEnvironment.enable = true;
}
```

### Método 2: Importar Todo el Directorio

```nix
# En tu configuration.nix
{
  imports = [
    ../../modules/darwin/default.nix  # Carga todos los módulos darwin
  ];

  programs.aerospace.enable = true;
}
```

### Método 3: Via Flake

```nix
# En tu flake.nix
{
  nixosConfigurations.myHost = nixpkgs.lib.nixosSystem {
    modules = [
      ./configuration.nix
      {
        imports = [ ./modules/nixos/firewall-rules.nix ];
        networking.firewall.profiles.enable = true;
      }
    ];
  };
}
```

## Testing de Módulos

```bash
# Verificar sintaxis
nix-instantiate --parse modules/darwin/aerospace.nix

# Evaluar opciones
nix eval .#nixosConfigurations.myHost.config.programs.aerospace.enable

# Build dry-run
nix build .#nixosConfigurations.myHost.config.system.build.toplevel --dry-run

# Aplicar configuración
darwin-rebuild switch --flake .#myHost
# o
sudo nixos-rebuild switch --flake .#myHost
```

## Recursos

- [NixOS Module System](https://nixos.org/manual/nixos/stable/#sec-writing-modules)
- [Nix Pills - Module System](https://nixos.org/guides/nix-pills/nixos-module-system.html)
- [nix-darwin Modules](https://github.com/LnL7/nix-darwin/tree/master/modules)
- [Home Manager Modules](https://github.com/nix-community/home-manager/tree/master/modules)

## Conclusión

Los módulos son la forma más potente de configurar NixOS/nix-darwin:

1. **Define opciones claras** con tipos y validación
2. **Documenta todo** para que otros entiendan tu módulo
3. **Valida inputs** para prevenir errores
4. **Usa defaults sensibles** para facilitar adopción
5. **Compón módulos** para crear configuraciones complejas

Con módulos bien diseñados, tu configuración será:
- ✅ **Mantenible**: Lógica clara y bien organizada
- ✅ **Reutilizable**: Úsala en múltiples hosts
- ✅ **Documentada**: man pages automáticas
- ✅ **Confiable**: Validación previene errores
