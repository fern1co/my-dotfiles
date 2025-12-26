# Guía de Módulos Home-Manager

Guía completa para crear, usar e implementar módulos home-manager en tu configuración.

## 📚 Conceptos Básicos

### System-Level vs Home-Manager

| Aspecto | System-Level | Home-Manager |
|---------|--------------|--------------|
| **Alcance** | Sistema completo (requiere root) | Solo tu usuario |
| **Paquetes** | `environment.systemPackages` | `home.packages` |
| **Configuración** | `/etc`, sistema global | `~/.config`, `~/.*` |
| **Aplicar cambios** | `darwin-rebuild`/`nixos-rebuild` | Automático con rebuild |
| **Uso típico** | Servicios del sistema, daemons | Apps de usuario, dotfiles |

### ¿Cuándo usar cada uno?

**System-Level** (`modules/shared/`, `modules/darwin/`, `modules/nixos/`):
- ✅ Servicios del sistema (nginx, postgresql)
- ✅ Configuración de red, firewall
- ✅ Configuración de hardware
- ✅ Usuarios y grupos del sistema

**Home-Manager** (`modules/home-manager/`):
- ✅ Aplicaciones de usuario (nvim, git, tmux)
- ✅ Dotfiles personales (~/.zshrc, ~/.gitconfig)
- ✅ Configuración de shell y terminal
- ✅ Herramientas de desarrollo

## 🎯 Estructura de un Módulo Home-Manager

```nix
# modules/home-manager/mi-modulo.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.miModulo;
in
{
  # 1. Opciones: Define qué puede configurar el usuario
  options.programs.miModulo = {
    enable = mkEnableOption "mi módulo";

    ejemplo = mkOption {
      type = types.str;
      default = "valor-default";
      description = "Descripción de la opción";
    };
  };

  # 2. Configuración: Qué hace el módulo cuando está habilitado
  config = mkIf cfg.enable {
    home.packages = [ pkgs.mi-paquete ];

    programs.git = {
      enable = true;
      # ...
    };

    home.file.".mi-config".text = ''
      mi configuración personalizada
    '';
  };

  # 3. Metadata (opcional)
  meta = {
    maintainers = [ "tu-nombre" ];
    platforms = lib.platforms.all;
  };
}
```

## 🚀 Uso en tu Configuración

### Opción 1: Import Directo en home-manager

```nix
# lib/default.nix
mkDarwin = { ... }: {
  modules = [
    inputs.home-manager.darwinModules.home-manager {
      home-manager.users.${username} = { pkgs, ... }: {
        imports = [
          # ✅ Importar módulos
          ../../modules/home-manager/dev-environment.nix
          ../../modules/home-manager/terminal.nix
          # O todos a la vez
          # ../../modules/home-manager
        ];

        # ✅ Habilitar y configurar
        programs.devEnvironment = {
          enable = true;
          languages = [ "javascript" "python" "go" ];
          tools.containers = true;
          extraPackages = with pkgs; [ kubectl terraform ];
        };

        programs.terminalConfig = {
          enable = true;
          terminal = "kitty";
          font = {
            name = "Hack Nerd Font";
            size = 14;
          };
          opacity = 0.95;
        };
      };
    }
  ];
};
```

### Opción 2: En Profiles

```nix
# lib/profiles/development/home.nix
{ pkgs, ... }:
{
  imports = [
    ../../modules/home-manager/dev-environment.nix
  ];

  # Configurar el módulo
  programs.devEnvironment = {
    enable = true;
    languages = [ "javascript" "python" "rust" "go" ];

    tools = {
      vcs = true;
      editors = true;
      terminals = true;
      utils = true;
      network = true;
      containers = true;
    };

    extraPackages = with pkgs; [
      kubectl
      k9s
      terraform
      docker-compose
    ];

    shellAliases = {
      # Heredan los defaults + estos custom
      k = "kubectl";
      tf = "terraform";
    };
  };
}
```

### Opción 3: Loader Automático

```nix
# modules/home-manager/default.nix ya importa todos los módulos

# Uso:
imports = [
  ../../modules/home-manager  # Carga TODOS los módulos
];

# Luego habilitas los que quieras:
programs.devEnvironment.enable = true;
programs.terminalConfig.enable = true;
```

## 📦 Módulos Disponibles

### 1. `dev-environment.nix`

**Propósito**: Entorno de desarrollo unificado con lenguajes y herramientas.

**Opciones**:
```nix
programs.devEnvironment = {
  enable = true;

  # Lenguajes a instalar
  languages = [ "javascript" "python" "rust" "go" "java" "nix" ];

  # Herramientas por categoría
  tools = {
    vcs = true;        # git, gh, lazygit
    editors = true;    # neovim
    terminals = true;  # tmux
    utils = true;      # ripgrep, fd, jq, bat, fzf
    network = true;    # curl, wget, httpie
    containers = true; # docker-compose, lazydocker
  };

  # Paquetes extra
  extraPackages = with pkgs; [ kubectl terraform ];

  # Aliases personalizados
  shellAliases = {
    k = "kubectl";
    tf = "terraform";
  };

  # Funciones de shell
  shellFunctions = {
    mkcd = ''mkdir -p "$1" && cd "$1"'';
  };

  # Variables de entorno
  sessionVariables = {
    EDITOR = "nvim";
    CUSTOM_VAR = "value";
  };

  # Git config básica
  enableGitConfig = true;
};
```

**Lo que instala**:
- ✅ Toolchains de lenguajes seleccionados
- ✅ Herramientas CLI modernas (bat, eza, ripgrep)
- ✅ Git + GitHub CLI + Lazygit
- ✅ Neovim configurado
- ✅ Aliases útiles pre-configurados
- ✅ Variables de entorno por lenguaje

### 2. `terminal.nix`

**Propósito**: Configuración unificada de terminal con theming.

**Opciones**:
```nix
programs.terminalConfig = {
  enable = true;

  # Terminal a usar
  terminal = "kitty";  # "kitty" | "alacritty" | "wezterm"

  # Fuente
  font = {
    name = "Hack Nerd Font";
    size = 14;
  };

  # Apariencia
  opacity = 0.95;
  theme = "Catppuccin-Mocha";
  enableLigatures = true;
};
```

**Lo que configura**:
- ✅ Terminal emulator (Kitty, Alacritty, o WezTerm)
- ✅ Nerd Font configurada
- ✅ Tema Catppuccin
- ✅ Keybindings consistentes
- ✅ Transparencia y efectos
- ✅ Integración con ZSH

## 🔨 Crear tu Propio Módulo

### Ejemplo: Módulo para configurar K9s

```nix
# modules/home-manager/k9s.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.k9sConfig;
in
{
  options.programs.k9sConfig = {
    enable = mkEnableOption "K9s Kubernetes TUI configuration";

    theme = mkOption {
      type = types.str;
      default = "catppuccin-mocha";
      description = "K9s color theme";
    };

    refreshRate = mkOption {
      type = types.int;
      default = 2;
      description = "Refresh rate in seconds";
    };

    enablePlugins = mkOption {
      type = types.bool;
      default = true;
      description = "Enable K9s plugins";
    };
  };

  config = mkIf cfg.enable {
    # Instalar K9s
    home.packages = [ pkgs.k9s ];

    # Configurar K9s
    programs.k9s = {
      enable = true;

      settings = {
        k9s = {
          refreshRate = cfg.refreshRate;
          maxConnRetry = 5;
          enableMouse = true;
          headless = false;
          logoless = false;
          crumbsless = false;
          readOnly = false;
          noIcons = false;
        };
      };

      skins = mkIf (cfg.theme == "catppuccin-mocha") {
        catppuccin-mocha = {
          # ... configuración del tema
        };
      };

      plugins = mkIf cfg.enablePlugins {
        shell = {
          shortCut = "Shift-V";
          description = "Pod Shell";
          scopes = [ "po" ];
          command = "kubectl";
          background = false;
          args = [
            "exec" "-ti" "-n" "$NAMESPACE"
            "--context" "$CONTEXT" "$NAME"
            "--" "sh" "-c" "'clear; (bash || ash || sh)'"
          ];
        };
      };
    };
  };
}
```

**Uso**:
```nix
# En home.nix o profile
imports = [ ../../modules/home-manager/k9s.nix ];

programs.k9sConfig = {
  enable = true;
  theme = "catppuccin-mocha";
  refreshRate = 2;
  enablePlugins = true;
};
```

## 🔄 Integración con tu Config Actual

### Actualizar `lib/shared/home-manager.nix`

```nix
{ inputs }:{git}:{ pkgs, ...}:
{
  # ✅ Importar módulos
  imports = [
    ../../modules/home-manager
  ];

  # ✅ Usar módulos
  programs.devEnvironment = {
    enable = true;
    languages = [ "javascript" "python" "go" ];
    tools.containers = true;
  };

  programs.terminalConfig = {
    enable = true;
    terminal = "kitty";
  };

  # ... resto de configuración existente
}
```

### Actualizar Profiles

```nix
# lib/profiles/development/home.nix
{ pkgs, ... }:
{
  imports = [
    ../../modules/home-manager/dev-environment.nix
  ];

  programs.devEnvironment = {
    enable = true;
    languages = [ "javascript" "python" "rust" ];
  };

  # Paquetes adicionales específicos del profile
  home.packages = with pkgs; [
    postman
    dbeaver
  ];
}
```

## 🎨 Patterns y Best Practices

### 1. Opciones con Defaults Inteligentes

```nix
# ✅ Bueno: Defaults útiles
font.name = mkOption {
  type = types.str;
  default = "Hack Nerd Font";  # La mayoría querrá esto
  description = "Font family";
};

# ❌ Malo: Sin default útil
font.name = mkOption {
  type = types.str;
  description = "Font family";  # Usuario debe especificar siempre
};
```

### 2. Grupos Lógicos de Opciones

```nix
# ✅ Bueno: Agrupado por función
tools = {
  vcs = mkEnableOption "...";
  editors = mkEnableOption "...";
  terminals = mkEnableOption "...";
};

# ❌ Malo: Todo plano
enableVcs = mkEnableOption "...";
enableEditors = mkEnableOption "...";
enableTerminals = mkEnableOption "...";
```

### 3. Composición sobre Duplicación

```nix
# ✅ Bueno: Reutilizar configuración
programs.devEnvironment = {
  enable = true;
  languages = [ "javascript" "python" ];
};

# ❌ Malo: Duplicar paquetes en cada config
home.packages = [
  pkgs.nodejs pkgs.yarn pkgs.pnpm
  pkgs.python312 pkgs.python312Packages.pip
];
```

### 4. Usar mkMerge para Condicionales

```nix
# ✅ Bueno
home.packages = mkMerge [
  (mkIf cfg.tools.vcs toolCategories.vcs)
  (mkIf cfg.tools.editors toolCategories.editors)
];

# ❌ Malo: Muchos if anidados
home.packages =
  if cfg.tools.vcs then toolCategories.vcs
  else if cfg.tools.editors then toolCategories.editors
  else [];
```

## 🧪 Testing

### Verificar Sintaxis

```bash
# Check del flake
nix flake check

# Build específico
nix build .#homeConfigurations.username.activationPackage
```

### Verificar Configuración

```nix
# Ver qué está habilitado
home-manager option programs.devEnvironment.enable

# Ver valor de opción
home-manager option programs.devEnvironment.languages
```

## 📚 Recursos

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [Nixpkgs Module System](https://nixos.org/manual/nixpkgs/stable/#module-system)
- [Writing NixOS Modules](https://nixos.wiki/wiki/NixOS_modules)

## 💡 Tips Avanzados

### Compartir Configuración entre System y Home

```nix
# config/common.nix
{
  gitConfig = {
    userName = "Tu Nombre";
    userEmail = "tu@email.com";
  };

  languages = [ "javascript" "python" "go" ];
}

# System-level usa:
{ config, ... }:
let common = import ./config/common.nix; in {
  # ...
}

# Home-manager usa:
{ config, ... }:
let common = import ./config/common.nix; in {
  programs.devEnvironment.languages = common.languages;
}
```

### Módulos Condicionales por Platform

```nix
config = mkIf cfg.enable {
  home.packages =
    if pkgs.stdenv.isDarwin
    then [ pkgs.darwin-specific ]
    else [ pkgs.linux-specific ];
};
```

### Módulos que Extienden Otros

```nix
# Módulo que extiende dev-environment
imports = [ ./dev-environment.nix ];

config = mkIf cfg.enable {
  # Tu módulo puede añadir sobre dev-environment
  programs.devEnvironment.extraPackages = [ pkgs.custom-tool ];
};
```
