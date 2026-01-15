{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "usb_storage"
  ];
  boot.kernelModules = [ ];
  boot.initrd.luks.devices."cryptroot".bypassWorkqueues = false;

  # Disable shit
  swapDevices = lib.mkForce [];
  services.thermald.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
}
