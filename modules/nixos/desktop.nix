{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.xserver = {
    xkb = {
      layout = "gb";
      variant = "";
    };
  };
  services.xserver = {
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
      ];
      configFile = ../../config/i3;
      package = pkgs.i3-gaps;
    };
  };
  services.displayManager.defaultSession = "none+i3";
}