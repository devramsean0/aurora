{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/profiles/all-hardware.nix") ];

  # File Systems
  boot.initrd.luks.devices."cryptusbroot".device = "/dev/disk/by-partlabel/encryptedusbroot";
  fileSystems."/" = {
    device = "/dev/disk/by-label/usbnixos";
    fsType = "ext4";
  };

  boot.loader.systemd-boot.configurationLimit = 5;   # keeps the ESP from filling up
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;  

  fileSystems."/boot" = {
    options = [
      "fmask=0137"
      "dmask=0027"
    ];
    device = "/dev/disk/by-label/usbboot";
    fsType = "vfat";
  };
}
