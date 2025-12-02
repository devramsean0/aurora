{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    hyfetch
    git
    unzip
    acpi
    pkg-config
    gnupg
    pinentry
  ];
}