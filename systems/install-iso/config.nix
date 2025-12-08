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

  boot.initrd.luks.devices = lib.mkForce { };
  networking.wireless.enable = true;

  environment.etc."setup.sh".source = ../../setup.sh;
  environment.etc."setup.sh".mode = "0755";
  services.getty.autologinUser = lib.mkForce "root";
  networking.networkmanager.enable = lib.mkForce false;
}
