{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./apps/firefox.nix
    ./apps/thunderbird.nix
  ];
  environment.systemPackages = with pkgs; [
    #    slack
    #    discord
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
