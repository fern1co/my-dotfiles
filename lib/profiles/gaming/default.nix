{ config, pkgs, lib, ... }:
{
environment.systemPackages = with pkgs; [
  retroarch
  ppsspp
  dolphin-emu
  papermc
];

programs.gamemode.enable = true;
}
