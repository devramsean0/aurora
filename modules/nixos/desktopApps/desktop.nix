{
  config,
  lib,
  pkgs,
  inputs,
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

    # bambu-studio
  ] ++ [
    inputs.taut.packages.${pkgs.system}.default
  ];

  programs.steam.enable = pkgs.stdenv.hostPlatform.isx86_64;
}
