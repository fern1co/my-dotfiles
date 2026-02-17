{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.sure;

  # Create a Ruby environment with bundler
  rubyEnv = pkgs.ruby_3_3;

  # State directory for the application
  stateDir = "/var/lib/sure";

  # Application user
  user = "sure";
  group = "sure";

  # PostgreSQL database configuration
  dbName = "sure_production";
  dbUser = "sure";

  # Environment file with all required variables
  envFile = pkgs.writeText "sure.env" ''
    RAILS_ENV=production
    DATABASE_URL=postgresql://${dbUser}@localhost/${dbName}?pool=5
    REDIS_URL=redis://localhost:${toString cfg.redisPort}/0
    RAILS_LOG_TO_STDOUT=true
    RAILS_SERVE_STATIC_FILES=true
    ${optionalString cfg.assumeSsl "RAILS_ASSUME_SSL=true"}
  '';

  # Setup script to prepare the application
  setupScript = pkgs.writeShellScript "sure-setup" ''
    set -euo pipefail

    cd ${stateDir}/sure

    # Install dependencies if needed
    if [ ! -d "vendor/bundle" ] || [ "${stateDir}/sure/Gemfile.lock" -nt "vendor/bundle/.timestamp" ]; then
      echo "Installing Ruby dependencies..."
      ${rubyEnv}/bin/bundle config set --local deployment 'true'
      ${rubyEnv}/bin/bundle config set --local path 'vendor/bundle'
      ${rubyEnv}/bin/bundle install --jobs=$(nproc) --retry=3
      touch vendor/bundle/.timestamp
    fi

    # Load environment variables
    export $(cat ${envFile} | xargs)
    export SECRET_KEY_BASE="${cfg.secretKeyBase}"

    # Precompile assets if needed
    if [ ! -d "public/assets" ] || [ ! -f "public/assets/.sprockets-manifest-*.json" ]; then
      echo "Precompiling assets..."
      ${rubyEnv}/bin/bundle exec rails assets:precompile
    fi

    # Prepare database (create, migrate, load schema)
    echo "Preparing database..."
    ${rubyEnv}/bin/bundle exec rails db:prepare

    echo "Setup complete!"
  '';

  # Start script for the web server
  webStartScript = pkgs.writeShellScript "sure-web" ''
    set -euo pipefail

    cd ${stateDir}/sure

    # Load environment variables
    export $(cat ${envFile} | xargs)
    export SECRET_KEY_BASE="${cfg.secretKeyBase}"

    # Start Rails server
    exec ${rubyEnv}/bin/bundle exec rails server -b ${cfg.bind} -p ${toString cfg.port}
  '';

  # Start script for the worker
  workerStartScript = pkgs.writeShellScript "sure-worker" ''
    set -euo pipefail

    cd ${stateDir}/sure

    # Load environment variables
    export $(cat ${envFile} | xargs)
    export SECRET_KEY_BASE="${cfg.secretKeyBase}"

    # Start Sidekiq worker
    exec ${rubyEnv}/bin/bundle exec sidekiq
  '';

in {
  options.services.sure = {
    enable = mkEnableOption "Sure personal finance application";

    port = mkOption {
      type = types.port;
      default = 3000;
      description = "Port to bind the web server to";
    };

    bind = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address to bind the web server to";
    };

    redisPort = mkOption {
      type = types.port;
      default = 6380;
      description = "Port for the Redis instance used by Sure";
    };

    secretKeyBase = mkOption {
      type = types.str;
      description = "Secret key base for Rails encryption (64-character hex string)";
      example = "abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789";
    };

    assumeSsl = mkOption {
      type = types.bool;
      default = false;
      description = "Set to true when using HTTPS reverse proxy";
    };

    repository = mkOption {
      type = types.str;
      default = "https://github.com/we-promise/sure.git";
      description = "Git repository URL for Sure";
    };

    revision = mkOption {
      type = types.str;
      default = "main";
      description = "Git branch, tag, or commit to use";
    };
  };

  config = mkIf cfg.enable {
    # Install required packages
    environment.systemPackages = with pkgs; [
      rubyEnv
      postgresql
      redis
      git
      nodejs # Required for asset compilation
      yarn   # May be needed for JavaScript dependencies
    ];

    # PostgreSQL service
    services.postgresql = {
      enable = true;
      ensureDatabases = [ dbName ];
      ensureUsers = [{
        name = dbUser;
        ensureDBOwnership = true;
      }];
    };

    # Redis service for Sure
    services.redis.servers.sure = {
      enable = true;
      port = cfg.redisPort;
      bind = "127.0.0.1";
      user = user;
    };

    # Create sure user and group
    users.users.${user} = {
      isSystemUser = true;
      inherit group;
      home = stateDir;
      createHome = true;
      description = "Sure application user";
    };

    users.groups.${group} = {};

    # Setup service - runs once to prepare the application
    systemd.services.sure-setup = {
      description = "Sure Application Setup";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "postgresql.service" "redis-sure.service" ];
      requires = [ "postgresql.service" "redis-sure.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = user;
        Group = group;
        WorkingDirectory = stateDir;
      };

      path = with pkgs; [
        rubyEnv
        git
        postgresql
        nodejs
        yarn
        coreutils
        gnused
        gawk
        gcc
        gnumake
        pkg-config
        libpqxx
        libyaml
      ];

      script = ''
        # Clone or update repository
        if [ ! -d "${stateDir}/sure" ]; then
          echo "Cloning Sure repository..."
          ${pkgs.git}/bin/git clone ${cfg.repository} ${stateDir}/sure
          cd ${stateDir}/sure
          ${pkgs.git}/bin/git checkout ${cfg.revision}
        else
          echo "Updating Sure repository..."
          cd ${stateDir}/sure
          ${pkgs.git}/bin/git fetch origin
          ${pkgs.git}/bin/git checkout ${cfg.revision}
          ${pkgs.git}/bin/git reset --hard origin/${cfg.revision} || ${pkgs.git}/bin/git reset --hard ${cfg.revision}
        fi

        # Run setup script
        ${setupScript}
      '';
    };

    # Web service
    systemd.services.sure-web = {
      description = "Sure Web Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "sure-setup.service" ];
      requires = [ "sure-setup.service" ];

      serviceConfig = {
        Type = "simple";
        User = user;
        Group = group;
        WorkingDirectory = "${stateDir}/sure";
        Restart = "on-failure";
        RestartSec = "10s";

        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ stateDir ];
      };

      path = with pkgs; [
        rubyEnv
        postgresql
      ];

      script = ''
        exec ${webStartScript}
      '';
    };

    # Worker service (Sidekiq)
    systemd.services.sure-worker = {
      description = "Sure Background Worker (Sidekiq)";
      wantedBy = [ "multi-user.target" ];
      after = [ "sure-setup.service" ];
      requires = [ "sure-setup.service" ];

      serviceConfig = {
        Type = "simple";
        User = user;
        Group = group;
        WorkingDirectory = "${stateDir}/sure";
        Restart = "on-failure";
        RestartSec = "10s";

        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ stateDir ];
      };

      path = with pkgs; [
        rubyEnv
        postgresql
      ];

      script = ''
        exec ${workerStartScript}
      '';
    };
  };
}
