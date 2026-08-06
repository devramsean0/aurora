{ pkgs, lib, accounts, ... }:
{
  security.polkit.enable = true;

  services.displayManager.gdm.enable = true;
  services.displayManager.defaultSession = "sway-uwsm";

  programs.sway = {
    enable = true;
  };

  programs.uwsm = {
    enable = true;
    waylandCompositors.sway = {
      prettyName = "Sway";
      comment = "An i3-compatible Wayland compositor";
      binPath = "/run/current-system/sw/bin/sway";
    };
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

  hardware.graphics.enable = true;

  environment.systemPackages = with pkgs; [
    swaylock
    ddcutil
    dmenu
    alacritty
    adwaita-icon-theme
    adwaita-qt

    nerd-fonts.sauce-code-pro

    gsettings-desktop-schemas
    gtk3
  ];

  programs.dconf.enable = true;

  environment.sessionVariables = {
    XDG_DATA_DIRS = [
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    ];
  };
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

  # Enable xfce for utils without the desktop
  services.xserver.desktopManager.xfce = {
    enable = true;
    noDesktop = true;
  };

  # Enable xdg-portal
  xdg.portal = {
    wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
  };
}
