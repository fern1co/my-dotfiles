{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.devEnvironment;

  # Language-specific package sets
  languageSets = {
    javascript = {
      packages = with pkgs; [ nodejs_20 yarn pnpm ];
      description = "JavaScript/TypeScript development";
    };

    python = {
      packages = with pkgs; [ python312 python312Packages.pip python312Packages.virtualenv ];
      description = "Python development";
    };

    rust = {
      packages = with pkgs; [ rustc cargo rustfmt clippy ];
      description = "Rust development";
    };

    go = {
      packages = with pkgs; [ go gopls ];
      description = "Go development";
    };

    java = {
      packages = with pkgs; [ openjdk17 maven gradle ];
      description = "Java development";
    };

    nix = {
      packages = with pkgs; [ nil nixpkgs-fmt alejandra ];
      description = "Nix development";
    };
  };

  # Tool category packages
  toolCategories = {
    vcs = with pkgs; [ git gh lazygit ];
    editors = with pkgs; [ neovim ];
    terminals = with pkgs; [ tmux ];
    utils = with pkgs; [ ripgrep fd jq yq-go bat eza fzf ];
    network = with pkgs; [ curl wget httpie ];
    containers = with pkgs; [ docker-compose ];
  };

in
{
  options.programs.devEnvironment = {
    enable = mkEnableOption "unified development environment";

    languages = mkOption {
      type = types.listOf (types.enum (attrNames languageSets));
      default = [ ];
      example = [ "javascript" "python" "rust" ];
      description = ''
        Programming languages to install toolchains for.
        Available: ${concatStringsSep ", " (attrNames languageSets)}
      '';
    };

    tools = {
      vcs = mkOption {
        type = types.bool;
        default = true;
        description = "Install version control tools (git, gh, lazygit).";
      };

      editors = mkOption {
        type = types.bool;
        default = true;
        description = "Install text editors (neovim).";
      };

      terminals = mkOption {
        type = types.bool;
        default = true;
        description = "Install terminal multiplexers (tmux).";
      };

      utils = mkOption {
        type = types.bool;
        default = true;
        description = "Install utility tools (ripgrep, fd, jq, bat, etc).";
      };

      network = mkOption {
        type = types.bool;
        default = true;
        description = "Install network tools (curl, wget, httpie).";
      };

      containers = mkOption {
        type = types.bool;
        default = false;
        description = "Install container tools (docker-compose).";
      };
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = literalExpression "[ pkgs.kubectl pkgs.terraform ]";
      description = "Additional packages to install.";
    };

    shellAliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        # Git aliases
        g = "git";
        gs = "git status";
        gp = "git pull";
        gc = "git commit";
        gco = "git checkout";

        # Modern replacements
        ls = "eza --icons";
        ll = "eza -la --icons";
        cat = "bat";

        # Navigation
        ".." = "cd ..";
        "..." = "cd ../..";
      };
      example = literalExpression ''
        {
          k = "kubectl";
          tf = "terraform";
        }
      '';
      description = "Shell aliases to define.";
    };

    shellFunctions = mkOption {
      type = types.attrsOf types.str;
      default = {
        mkcd = ''
          mkdir -p "$1" && cd "$1"
        '';
      };
      example = literalExpression ''
        {
          gcom = '''
            git add .
            git commit -m "$1"
          ''';
        }
      '';
      description = "Shell functions to define.";
    };

    sessionVariables = mkOption {
      type = types.attrsOf types.str;
      default = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
      example = literalExpression ''
        {
          GOPATH = "$HOME/go";
          CARGO_HOME = "$HOME/.cargo";
        }
      '';
      description = "Environment variables to set.";
    };

    enableGitConfig = mkOption {
      type = types.bool;
      default = true;
      description = "Enable basic git configuration.";
    };
  };

  config = mkIf cfg.enable {
    # Install language toolchains
    environment.systemPackages = mkMerge [
      # Language packages
      (flatten (map (lang: languageSets.${lang}.packages) cfg.languages))

      # Tool packages
      (mkIf cfg.tools.vcs toolCategories.vcs)
      (mkIf cfg.tools.editors toolCategories.editors)
      (mkIf cfg.tools.terminals toolCategories.terminals)
      (mkIf cfg.tools.utils toolCategories.utils)
      (mkIf cfg.tools.network toolCategories.network)
      (mkIf cfg.tools.containers toolCategories.containers)

      # Extra packages
      cfg.extraPackages
    ];

    # Shell configuration
    programs.zsh = mkIf (cfg.shellAliases != {} || cfg.shellFunctions != {}) {
      enable = true;
      shellAliases = cfg.shellAliases;
      shellInit = concatStringsSep "\n" (mapAttrsToList (name: body: ''
        ${name}() {
          ${body}
        }
      '') cfg.shellFunctions);
    };

    # Environment variables
    environment.sessionVariables = cfg.sessionVariables;

    # Git configuration
    programs.git = mkIf cfg.enableGitConfig {
      enable = true;
      lfs.enable = true;
    };

    # Language-specific system configuration
    # Node.js
    environment = mkIf (elem "javascript" cfg.languages) {
      variables = {
        NODE_OPTIONS = "--max-old-space-size=4096";
      };
    };

    # Python
    environment = mkIf (elem "python" cfg.languages) {
      variables = {
        PYTHONDONTWRITEBYTECODE = "1";
      };
    };

    # Go
    environment = mkIf (elem "go" cfg.languages) {
      variables = {
        GOPATH = "$HOME/go";
        GO111MODULE = "on";
      };
    };

    # Rust
    environment = mkIf (elem "rust" cfg.languages) {
      variables = {
        CARGO_HOME = "$HOME/.cargo";
        RUSTUP_HOME = "$HOME/.rustup";
      };
    };

    # Docker (platform-specific)
    virtualisation.docker = mkIf cfg.tools.containers {
      enable = lib.mkDefault false;  # Must be explicitly enabled per host
    };
  };

  meta = {
    maintainers = [ "your-name" ];
    platforms = [ "darwin" "linux" ];
  };
}
