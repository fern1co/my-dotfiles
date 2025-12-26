# Ejemplos de uso de módulos home-manager
# Este archivo muestra diferentes formas de usar los módulos

{ pkgs, ... }:
{
  # =====================================
  # EJEMPLO 1: Importar módulos individuales
  # =====================================
  imports = [
    ../modules/home-manager/dev-environment.nix
    ../modules/home-manager/terminal.nix
  ];

  # =====================================
  # EJEMPLO 2: Configuración Básica
  # =====================================
  programs.devEnvironment = {
    enable = true;

    # Instalar solo JavaScript y Python
    languages = [ "javascript" "python" ];

    # Habilitar solo herramientas esenciales
    tools = {
      vcs = true;      # git, gh, lazygit
      editors = true;  # neovim
      terminals = false; # No instalar tmux
      utils = true;    # ripgrep, fd, jq, bat, fzf
      network = false; # No instalar curl, wget
      containers = false; # No instalar docker-compose
    };
  };

  # =====================================
  # EJEMPLO 3: Configuración Full-Stack Developer
  # =====================================
  programs.devEnvironment = {
    enable = true;

    # Todos los lenguajes
    languages = [ "javascript" "python" "rust" "go" "java" "nix" ];

    # Todas las herramientas
    tools = {
      vcs = true;
      editors = true;
      terminals = true;
      utils = true;
      network = true;
      containers = true; # Docker tools
    };

    # Herramientas cloud/DevOps adicionales
    extraPackages = with pkgs; [
      # Kubernetes
      kubectl
      k9s
      kubernetes-helm
      kubectx

      # Cloud providers
      google-cloud-sdk
      awscli2
      azure-cli

      # Infrastructure as Code
      terraform
      terragrunt
      ansible

      # Monitoring/Observability
      grafana
      prometheus
    ];

    # Aliases personalizados
    shellAliases = {
      # Kubernetes shortcuts
      k = "kubectl";
      kx = "kubectx";
      kn = "kubens";
      kgp = "kubectl get pods";
      kgs = "kubectl get services";

      # Terraform shortcuts
      tf = "terraform";
      tfi = "terraform init";
      tfp = "terraform plan";
      tfa = "terraform apply";

      # Docker shortcuts
      d = "docker";
      dc = "docker-compose";
      dcu = "docker-compose up -d";
      dcd = "docker-compose down";
    };

    # Funciones de shell útiles
    shellFunctions = {
      # Crear directorio y navegar
      mkcd = ''
        mkdir -p "$1" && cd "$1"
      '';

      # Git commit rápido
      gcom = ''
        git add .
        git commit -m "$1"
      '';

      # Kubectl context switcher con fzf
      kctx = ''
        kubectl config use-context $(kubectl config get-contexts -o name | fzf)
      '';

      # Port forward con fzf pod selector
      kpf = ''
        local pod=$(kubectl get pods -o name | fzf)
        kubectl port-forward "$pod" "$1:$2"
      '';
    };

    # Variables de entorno
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      GOPATH = "$HOME/go";
      CARGO_HOME = "$HOME/.cargo";
      KUBECONFIG = "$HOME/.kube/config";
      AWS_PROFILE = "default";
    };

    # Habilitar configuración básica de git
    enableGitConfig = true;
  };

  # =====================================
  # EJEMPLO 4: Terminal Configuration
  # =====================================
  programs.terminalConfig = {
    enable = true;

    # Usar Kitty (también soporta "alacritty" y "wezterm")
    terminal = "kitty";

    # Fuente Nerd Font
    font = {
      name = "Hack Nerd Font";
      size = 14;
    };

    # Transparencia
    opacity = 0.95;

    # Tema (integrado con Catppuccin)
    theme = "Catppuccin-Mocha";

    # Ligaduras de fuente
    enableLigatures = true;
  };

  # =====================================
  # EJEMPLO 5: Frontend Developer Setup
  # =====================================
  programs.devEnvironment = {
    enable = true;

    # Solo JavaScript/TypeScript
    languages = [ "javascript" "nix" ];

    tools = {
      vcs = true;
      editors = true;
      terminals = true;
      utils = true;
      network = true;
      containers = false;
    };

    extraPackages = with pkgs; [
      # Node version managers
      nodejs_20
      nodejs_18

      # Package managers
      yarn
      pnpm

      # Build tools
      vite
      webpack

      # Testing
      playwright-driver

      # Formatters/Linters
      prettier
      eslint_d
    ];

    shellAliases = {
      # npm shortcuts
      ni = "npm install";
      nr = "npm run";
      nrd = "npm run dev";
      nrb = "npm run build";
      nrt = "npm run test";

      # yarn shortcuts
      yi = "yarn install";
      yr = "yarn run";
      yrd = "yarn dev";
      yrb = "yarn build";

      # pnpm shortcuts
      pi = "pnpm install";
      pr = "pnpm run";
      prd = "pnpm dev";
    };
  };

  # =====================================
  # EJEMPLO 6: Backend/DevOps Setup
  # =====================================
  programs.devEnvironment = {
    enable = true;

    # Python, Go, y Rust para microservicios
    languages = [ "python" "go" "rust" ];

    tools = {
      vcs = true;
      editors = true;
      terminals = true;
      utils = true;
      network = true;
      containers = true; # Docker importante aquí
    };

    extraPackages = with pkgs; [
      # Databases
      postgresql
      redis
      mongodb-tools

      # Message queues
      # rabbitmq (system-level mejor)

      # API tools
      postman
      httpie
      jq
      yq-go

      # Container orchestration
      kubectl
      k9s
      helm
      argocd

      # Monitoring
      prometheus
      grafana-loki
    ];

    shellAliases = {
      # Docker
      d = "docker";
      dc = "docker-compose";
      dps = "docker ps";
      dcu = "docker-compose up -d";
      dcd = "docker-compose down";
      dcl = "docker-compose logs -f";

      # Kubernetes
      k = "kubectl";
      kg = "kubectl get";
      kd = "kubectl describe";
      kl = "kubectl logs";
      kx = "kubectl exec -it";

      # Databases
      pgcli = "psql";
      rediscli = "redis-cli";
    };
  };

  # =====================================
  # EJEMPLO 7: Minimal Setup (Solo lo esencial)
  # =====================================
  programs.devEnvironment = {
    enable = true;

    # Sin lenguajes (instalados manualmente según necesidad)
    languages = [ ];

    # Solo lo básico
    tools = {
      vcs = true;      # git esencial
      editors = true;  # neovim
      terminals = false;
      utils = true;    # ripgrep, fd, jq básicos
      network = false;
      containers = false;
    };

    # Configuración mínima
    shellAliases = {
      vim = "nvim";
      v = "nvim";
    };

    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  # =====================================
  # EJEMPLO 8: Combinar con Configuración Manual
  # =====================================
  programs.devEnvironment = {
    enable = true;
    languages = [ "javascript" "python" ];
    tools.vcs = true;
  };

  # Añadir configuración adicional manualmente
  programs.git = {
    # El módulo ya habilita git, aquí solo añadimos más config
    userName = "Tu Nombre";
    userEmail = "tu@email.com";

    aliases = {
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "log --graph --oneline --all";
    };

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
    };
  };

  programs.neovim = {
    # El módulo ya habilita neovim, aquí personalizamos
    plugins = with pkgs.vimPlugins; [
      # LSP
      nvim-lspconfig
      # Autocompletion
      nvim-cmp
      cmp-nvim-lsp
      # Syntax
      nvim-treesitter
    ];

    extraConfig = ''
      " Tu configuración de neovim
      set number
      set relativenumber
      set expandtab
      set shiftwidth=2
      set tabstop=2
    '';
  };

  # =====================================
  # EJEMPLO 9: Per-Machine Configuration
  # =====================================

  # En lib/profiles/development/home.nix
  programs.devEnvironment = {
    enable = true;
    # Config común a todas las máquinas
    languages = [ "javascript" "python" ];
  };

  # En lib/darwin/macbook-pro/configuration.nix home-manager
  programs.devEnvironment = {
    # Heredar config del profile
    # Añadir específico de MacBook
    extraPackages = with pkgs; [
      # macOS specific tools
    ];
  };

  # =====================================
  # EJEMPLO 10: Deshabilitar Parts del Módulo
  # =====================================
  programs.devEnvironment = {
    enable = true;
    languages = [ "javascript" ];

    # Deshabilitar herramientas que no necesito
    tools = {
      vcs = true;
      editors = true;
      terminals = false;  # Configurado manualmente
      utils = true;
      network = false;    # Ya tengo curl del sistema
      containers = false; # No desarrollo con containers
    };

    # Sin git config (lo configuro yo)
    enableGitConfig = false;

    # Sobrescribir aliases (no usar defaults)
    shellAliases = {
      # Solo mis aliases
      vim = "nvim";
    };
  };

  # Configurar git manualmente
  programs.git = {
    enable = true;
    userName = "Custom Config";
    # ... tu config personalizada
  };
}
