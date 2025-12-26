{
  config,
  lib,
  pkgs,
  inputs,
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

    inputs.supertram-next-departures.packages.${pkgs.system}.default
  ];
}
