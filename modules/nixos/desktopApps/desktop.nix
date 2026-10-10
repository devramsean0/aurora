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
    ./apps/spotify.nix
  ];
  environment.systemPackages = with pkgs; [
    #    slack
    #    discord
    libreoffice
    obsidian
    filezilla
    signal-desktop
    starship
    picocom
    gnucash
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

  services.spotifyd = {
    enable = true;
    settings = {
      bitrate = 320;
    };
  };
}
