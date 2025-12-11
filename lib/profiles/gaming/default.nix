{ config, pkgs, lib, ... }:
{
environment.systemPackages = with pkgs; [
  retroarch
  ppsspp
  polphin-emu
];
}
