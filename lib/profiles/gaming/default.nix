{ config, pkgs, lib, ... }:
{
  imports = [
    ./papermc.nix
  ];

  environment.systemPackages = with pkgs; [
    retroarch
    ppsspp
    dolphin-emu
    papermc
    screen
  ];

  programs.gamemode.enable = true;

  programs.steam.enable = true;
  # Ejemplo de configuración de PaperMC
  # Descomenta y configura según tus necesidades:
  #
  services.papermc = {
    enable = true;
    eula = true;  # Acepta el EULA de Mojang
    openFirewall = true;
    jvmOpts = "-Xmx4096M -Xms4096M -XX:+UseG1GC";
    serverProperties = {
      server-port = 25565;
      gamemode = "survival";
      difficulty = "normal";
      max-players = 20;
      motd = "Mi Servidor de Minecraft";
      white-list = false;
      online-mode = false;  # Permite cuentas no premium
      enable-rcon = true;
      "rcon.port" = 25575;
      "rcon.password" = "minecraft123";  # Cambia esto a una contraseña segura
    };

    plugins = [
    {
      name = "EssentialsX";
      url = "https://github.com/EssentialsX/Essentials/releases/download/2.21.2/EssentialsX-2.21.2.jar";
    }
    {
      name = "Vault";
      url = "https://github.com/MilkBowl/Vault/releases/download/1.7.3/Vault.jar";
    }
    {
      name = "WorldEdit";
      url = "https://hangarcdn.papermc.io/plugins/EngineHub/WorldEdit/versions/7.3.18/PAPER/worldedit-bukkit-7.3.18.jar";
    }
    {
      name = "Chunky";
      url = "https://hangarcdn.papermc.io/plugins/pop4959/Chunky/versions/1.4.40/PAPER/Chunky-Bukkit-1.4.40.jar";
    }
    {
      name = "Bluemap";
      url = "https://hangarcdn.papermc.io/plugins/Blue/BlueMap/versions/5.15/PAPER/bluemap-5.15-paper.jar";
    }
    {
      name = "MythicMobs";
      url = "https://mythiccraft.io/downloads/mythicmobs/free/MythicMobs-5.11.0.jar";
    }
    {
      name = "LuckPerms";
      url = "https://download.luckperms.net/1612/bukkit/loader/LuckPerms-Bukkit-5.5.24.jar";
    }
    {
      name = "";
      url = "https://ci.minebench.de/job/chestshop-3-1.12/30/artifact/target/ChestShop.jar";
    }
    ];
  };
}
