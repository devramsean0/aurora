{ pkgs, lib, accounts, ... }:
{
  security.polkit.enable = true;
  
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  programs.sway = {
    enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    publish = {
      userServices = true;
      hinfo = true;
      workstation = true;
    };
  };

  # Exclude certain xserver packages.
  services.xserver.excludePackages = [ pkgs.xterm ];

  environment.systemPackages = with pkgs; [
    ddcutil
    dmenu
    alacritty
    adwaita-icon-theme
    adwaita-qt

    nerd-fonts.sauce-code-pro
  ];
  boot.kernelModules = [ "i2c-dev" ]; # For ddcutil

  qt = {
    enable = true;
    style = "adwaita-dark";
    platformTheme = "gnome";
  };

  # Symlink fonts into /run/current-system/sw/share/X11/fonts
  fonts.fontDir.enable = true;

  # High-performance version of D-Bus
  services.dbus.implementation = "broker";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GSK_RENDERER = "ngl";
  };

  # Do not wait for network on boot.
  systemd.network.wait-online.timeout = 0;
}
