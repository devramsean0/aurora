{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./apps/firefox.nix
  ];
  environment.systemPackages = with pkgs; [
    slack
    discord
    flameshot
    libreoffice
    arandr
    spotify
    obsidian
    filezilla
    signal-desktop
    starship
    picocom
  ];
}