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

  # Charge limits
  services.udev.extraRules = ''
    KERNEL=="macsmc-battery", SUBSYSTEM=="power_supply", ATTR{charge_control_end_threshold}="80", ATTR{charge_control_start_threshold}="70"
  '';
}
