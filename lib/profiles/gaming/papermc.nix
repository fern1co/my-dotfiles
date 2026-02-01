{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.papermc;
in
{
  options.services.papermc = {
    enable = mkEnableOption "PaperMC Minecraft Server";

    package = mkOption {
      type = types.package;
      default = pkgs.papermc;
      description = "The PaperMC package to use";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/papermc";
      description = "Directory to store PaperMC data";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open ports in the firewall for the server";
    };

    serverProperties = mkOption {
      type = types.attrsOf (types.oneOf [ types.bool types.int types.str ]);
      default = { };
      example = {
        server-port = 25565;
        gamemode = "survival";
        difficulty = "normal";
        max-players = 20;
        motd = "A Minecraft Server";
        white-list = false;
        enable-rcon = false;
      };
      description = ''
        Minecraft server.properties configuration.
        See https://minecraft.fandom.com/wiki/Server.properties for options.
      '';
    };

    jvmOpts = mkOption {
      type = types.separatedString " ";
      default = "-Xmx2048M -Xms2048M";
      example = "-Xmx4096M -Xms4096M -XX:+UseG1GC";
      description = "JVM options for the server";
    };

    plugins = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Plugin name (for identification)";
          };

          url = mkOption {
            type = types.str;
            description = "Direct download URL for the plugin JAR file";
          };

          sha256 = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Optional SHA256 hash of the plugin JAR for verification";
          };
        };
      });
      default = [ ];
      example = literalExpression ''
        [
          {
            name = "EssentialsX";
            url = "https://github.com/EssentialsX/Essentials/releases/download/2.20.1/EssentialsX-2.20.1.jar";
            sha256 = "...";
          }
          {
            name = "Vault";
            url = "https://github.com/MilkBowl/Vault/releases/download/1.7.3/Vault.jar";
          }
        ]
      '';
      description = ''
        List of plugins to install. Each plugin requires a name and download URL.
        The plugins will be downloaded and placed in the plugins directory.
      '';
    };

    eula = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether you agree to Mojang's EULA.
        This option must be set to true to run the server.
        https://account.mojang.com/documents/minecraft_eula
      '';
    };
  };

  config = mkIf cfg.enable {
    users.users.papermc = {
      description = "PaperMC Minecraft server service user";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "papermc";
    };

    users.groups.papermc = { };

    systemd.services.papermc = {
      description = "PaperMC Minecraft Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.jre}/bin/java ${cfg.jvmOpts} -jar ${cfg.package}/lib/papermc/papermc.jar nogui";
        Restart = "always";
        User = "papermc";
        WorkingDirectory = cfg.dataDir;

        # Hardening
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
        NoNewPrivileges = true;
      };

      preStart = ''
        # Create directory structure
        mkdir -p ${cfg.dataDir}/plugins

        # Accept EULA
        ${optionalString cfg.eula ''
          echo "eula=true" > ${cfg.dataDir}/eula.txt
        ''}

        # Generate server.properties
        cat > ${cfg.dataDir}/server.properties << EOF
        ${concatStringsSep "\n" (
          mapAttrsToList (name: value:
            "${name}=${
              if isBool value then (if value then "true" else "false")
              else toString value
            }"
          ) cfg.serverProperties
        )}
        EOF

        # Download and install plugins
        ${concatMapStringsSep "\n" (plugin: ''
          echo "Installing plugin: ${plugin.name}"
          ${pkgs.curl}/bin/curl -L -o "${cfg.dataDir}/plugins/${plugin.name}.jar" "${plugin.url}"
          ${optionalString (plugin.sha256 != null) ''
            echo "Verifying plugin checksum..."
            echo "${plugin.sha256}  ${cfg.dataDir}/plugins/${plugin.name}.jar" | ${pkgs.coreutils}/bin/sha256sum -c -
          ''}
        '') cfg.plugins}

        # Fix permissions
        chmod -R u+w ${cfg.dataDir}
      '';
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        (cfg.serverProperties.server-port or 25565)
      ] ++ optional (cfg.serverProperties.enable-rcon or false)
        (cfg.serverProperties."rcon.port" or 25575);

      allowedUDPPorts = [
        (cfg.serverProperties.server-port or 25565)
      ];
    };

    assertions = [
      {
        assertion = cfg.enable -> cfg.eula;
        message = ''
          You must accept Mojang's EULA to run PaperMC.
          Set services.papermc.eula = true; after reading:
          https://account.mojang.com/documents/minecraft_eula
        '';
      }
    ];
  };
}
