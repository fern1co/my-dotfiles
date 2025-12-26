# Homelab profile - Self-hosted services
{ config, pkgs, lib, ... }:

{
    environment.systemPackages = with pkgs; [
        seclists
        whatweb
        tshark
    ];
}
