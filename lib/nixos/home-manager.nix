{pkgs, ...}:
{
    programs.gpg.enable = true;
    programs.chromium.enable = true;

    home.packages = [
      pkgs.swaylock
      pkgs.swayidle
      pkgs.killall
      pkgs.swaynotificationcenter
      pkgs.rofi-systemd
      pkgs.rofi-power-menu

      (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
    ];
}
