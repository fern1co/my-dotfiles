# Home-manager module for development environment
# Usage in home-manager configuration:
#   imports = [ ../../modules/home-manager/dev-environment.nix ];
#   programs.devEnvironment.enable = true;

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
      packages = with pkgs; [
        python312
        python312Packages.pip
        python312Packages.virtualenv
      ];
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
    editors = []; # neovim managed via programs.neovim
    terminals = with pkgs; [ tmux ];
    utils = with pkgs; [ ripgrep fd jq yq-go bat eza fzf ];
    network = with pkgs; [ curl wget httpie ];
    containers = with pkgs; [ docker-compose lazydocker ];
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
      vcs = mkEnableOption "version control tools (git, gh, lazygit)" // { default = true; };
      editors = mkEnableOption "text editors (neovim)" // { default = true; };
      terminals = mkEnableOption "terminal multiplexers (tmux)" // { default = true; };
      utils = mkEnableOption "utility tools (ripgrep, fd, jq, bat, etc)" // { default = true; };
      network = mkEnableOption "network tools (curl, wget, httpie)" // { default = true; };
      containers = mkEnableOption "container tools (docker-compose, lazydocker)" // { default = false; };
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
        lg = "lazygit";

        # Modern replacements
        ls = "eza --icons";
        ll = "eza -la --icons";
        cat = "bat";
        vim = "nvim";

        # Navigation
        ".." = "cd ..";
        "..." = "cd ../..";
      };
      description = "Shell aliases to define.";
    };

    shellFunctions = mkOption {
      type = types.attrsOf types.str;
      default = {
        mkcd = ''
          mkdir -p "$1" && cd "$1"
        '';
        gcom = ''
          git add .
          git commit -m "$1"
        '';
      };
      description = "Shell functions to define.";
    };

    sessionVariables = mkOption {
      type = types.attrsOf types.str;
      default = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
      description = "Environment variables to set.";
    };

    enableGitConfig = mkEnableOption "basic git configuration" // { default = true; };
  };

  config = mkIf cfg.enable {
    # Install language toolchains and tools
    home.packages = mkMerge [
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
    home.shellAliases = cfg.shellAliases;

    # Shell functions
    programs.zsh.initContent = mkIf (cfg.shellFunctions != {}) (
      mkBefore (concatStringsSep "\n" (mapAttrsToList (name: body: ''
        ${name}() {
          ${body}
        }
      '') cfg.shellFunctions))
    );

    # Environment variables (user-defined + language-specific)
    home.sessionVariables = mkMerge [
      # User-defined variables
      cfg.sessionVariables

      # Node.js
      (mkIf (elem "javascript" cfg.languages) {
        NODE_OPTIONS = "--max-old-space-size=4096";
      })

      # Python
      (mkIf (elem "python" cfg.languages) {
        PYTHONDONTWRITEBYTECODE = "1";
      })

      # Go
      (mkIf (elem "go" cfg.languages) {
        GOPATH = "$HOME/go";
        GO111MODULE = "on";
      })

      # Rust
      (mkIf (elem "rust" cfg.languages) {
        CARGO_HOME = "$HOME/.cargo";
        RUSTUP_HOME = "$HOME/.rustup";
      })
    ];

    # Enable programs if their tools are enabled
    programs.git = mkIf (cfg.tools.vcs && cfg.enableGitConfig) {
      enable = true;
      lfs.enable = true;
    };

    programs.neovim = mkIf cfg.tools.editors {
      enable = true;
      viAlias = true;
      vimAlias = true;
    };

    programs.tmux = mkIf cfg.tools.terminals {
      enable = true;
    };

    programs.fzf = mkIf cfg.tools.utils {
      enable = true;
      enableZshIntegration = true;
    };

    programs.bat = mkIf cfg.tools.utils {
      enable = true;
    };

    programs.lazygit = mkIf cfg.tools.vcs {
      enable = true;
    };
  };
}
