{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ];

  boot.kernelPackages = pkgs.linuxPackages_rpi3;
  
  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
  };

  hardware.enableRedistributableFirmware = true;

  boot.tmp.useTmpfs = true;
  fileSystems."/" = {
    options = [ "noatime" ];
  };
}
