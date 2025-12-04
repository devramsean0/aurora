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
      package = pkgs.i3;
    };
  };
  services.displayManager.defaultSession = "none+i3";

  # Create i3blocks config directory and symlink for each user
  # systemd.tmpfiles.rules = lib.flatten (map (username: [
  #  "d /home/${username}/.config/i3blocks 777 ${username} users -"
  #  "L+ /home/${username}/.config/i3blocks/top - - - - ${../../config/i3-blocks}"
  #  "z /home/${username}/.config/i3blocks/top 744 named ${username} -"
  #]) usernames);

  environment.etc."config/i3-blocks".source = ../../config/i3-blocks;
}
