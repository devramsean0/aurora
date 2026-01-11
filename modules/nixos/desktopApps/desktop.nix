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
    libreoffice
    spotify
    obsidian
    filezilla
    signal-desktop
    starship
    picocom

    slurp
    wl-clipboard
    mako
    grim
    sway-contrib.grimshot

    kicad

    bambu-studio
  ];
}
