{
  config,
  lib,
  pkgs,
  usernames,
  ...
}:
{
  services.xserver = {
    xkb = {
      layout = "gb";
      variant = "";
    };

    enable = true;

    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3lock
        i3blocks
        rofi
        xorg.xbacklight
      ];
      configFile = ../../config/i3;
      package = pkgs.i3-gaps;
    };
  };
  services.displayManager.defaultSession = "none+i3";

  # Create i3blocks config directory and symlink for each user
  systemd.tmpfiles.rules = lib.flatten (map (username: [
    "d /home/${username}/.config/i3blocks 0755 ${username} users -"
    "L+ /home/${username}/.config/i3blocks/top - - - - ${../../config/i3-blocks}"
  ]) usernames);
}