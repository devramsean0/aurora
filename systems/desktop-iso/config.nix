{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-base.nix"
  ];

  boot.initrd.luks.devices = lib.mkForce {};
}