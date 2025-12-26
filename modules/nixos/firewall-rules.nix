{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.networking.firewall.profiles;

  # Predefined rule sets
  ruleSets = {
    web = {
      tcp = [ 80 443 8080 8443 ];
      udp = [ ];
      description = "Common web server ports";
    };

    ssh = {
      tcp = [ 22 ];
      udp = [ ];
      description = "SSH access";
    };

    dns = {
      tcp = [ 53 853 ];
      udp = [ 53 ];
      description = "DNS and DNS-over-TLS";
    };

    homelab = {
      tcp = [ 8080 8081 8082 8083 8084 8085 8123 ];
      udp = [ ];
      description = "Common homelab service ports";
    };

    media = {
      tcp = [ 32400 8096 8920 ];  # Plex, Jellyfin
      udp = [ 1900 5353 ];  # DLNA, mDNS
      description = "Media server ports";
    };

    development = {
      tcp = [ 3000 4200 5000 5173 8000 8080 9000 ];
      udp = [ ];
      description = "Common development server ports";
    };

    tailscale = {
      tcp = [ ];
      udp = [ 41641 ];
      description = "Tailscale VPN";
    };
  };

in
{
  options.networking.firewall.profiles = {
    enable = mkEnableOption "predefined firewall rule profiles";

    activeProfiles = mkOption {
      type = types.listOf (types.enum (attrNames ruleSets));
      default = [ ];
      example = [ "web" "ssh" ];
      description = ''
        List of predefined profiles to enable.
        Available profiles: ${concatStringsSep ", " (attrNames ruleSets)}
      '';
    };

    customRules = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          tcp = mkOption {
            type = types.listOf types.port;
            default = [ ];
            description = "TCP ports to allow.";
          };

          udp = mkOption {
            type = types.listOf types.port;
            default = [ ];
            description = "UDP ports to allow.";
          };

          description = mkOption {
            type = types.str;
            default = "";
            description = "Description of the rule set.";
          };
        };
      });
      default = { };
      example = literalExpression ''
        {
          minecraft = {
            tcp = [ 25565 ];
            udp = [ 19132 ];
            description = "Minecraft server";
          };
        }
      '';
      description = "Custom firewall rule sets.";
    };

    trustedInterfaces = mkOption {
      type = types.listOf types.str;
      default = [ "tailscale0" ];
      example = [ "tailscale0" "docker0" "br-*" ];
      description = "Network interfaces to trust completely.";
    };

    blockPing = mkOption {
      type = types.bool;
      default = false;
      description = "Block ICMP ping requests.";
    };

    logRefusedConnections = mkOption {
      type = types.bool;
      default = true;
      description = "Log refused connections.";
    };
  };

  config = mkIf cfg.enable {
    # Collect all TCP ports from active profiles
    networking.firewall.allowedTCPPorts = mkMerge [
      (flatten (map (profile: ruleSets.${profile}.tcp) cfg.activeProfiles))
      (flatten (mapAttrsToList (_: rule: rule.tcp) cfg.customRules))
    ];

    # Collect all UDP ports from active profiles
    networking.firewall.allowedUDPPorts = mkMerge [
      (flatten (map (profile: ruleSets.${profile}.udp) cfg.activeProfiles))
      (flatten (mapAttrsToList (_: rule: rule.udp) cfg.customRules))
    ];

    # Trust specified interfaces
    networking.firewall.trustedInterfaces = cfg.trustedInterfaces;

    # Firewall settings
    networking.firewall = {
      enable = true;
      pingLimit = mkIf cfg.blockPing "--limit 1/minute --limit-burst 5";
      logRefusedConnections = cfg.logRefusedConnections;
      logRefusedPackets = false;  # Reduce log spam
    };

    # System message showing active profiles
    system.activationScripts.firewall-profiles = ''
      echo "Firewall profiles: ${concatStringsSep ", " cfg.activeProfiles}"
      ${concatStringsSep "\n" (mapAttrsToList (name: rule:
        "echo '  ${name}: ${rule.description}'"
      ) (filterAttrs (n: _: elem n cfg.activeProfiles) ruleSets))}
    '';

    # Assertions
    assertions = [
      {
        assertion = length cfg.activeProfiles > 0 || cfg.customRules != {};
        message = "firewall.profiles: At least one profile or custom rule must be defined";
      }
    ];
  };

  meta = {
    maintainers = [ "your-name" ];
    doc = ./firewall-rules.md;
  };
}
