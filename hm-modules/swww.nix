
# hm-modules/swww.nix
{ config, pkgs, lib, ... }:
let
  # CHANGE THIS path to your image
  wallpaper = "/home/colton/Downloads/photos/wallpapers/pinkwater.png";
in
{
  home.packages = [ pkgs.swww ];

  systemd.user.services.swww-daemon = {
    Unit = {
      Description = "swww daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swww}/bin/swww-daemon";
      Restart = "always";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.swww-set-wallpaper = {
    Unit = {
      Description = "Set wallpaper via swww";
      After = [ "swww-daemon.service" ];
      Requires = [ "swww-daemon.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.swww}/bin/swww img \
          --transition-type any \
          --transition-duration 1.5 \
          ${lib.escapeShellArg wallpaper}
      '';
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
