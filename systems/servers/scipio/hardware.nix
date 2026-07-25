{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" "e1000e" ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;


  boot.supportedFilesystems = [ "zfs" ]; # Enable ZFS FS
  networking.hostId = "12345678"; # Apparently required for ZFS
  boot.zfs.extraPools = [ "vmdisk" ]; # Mount VM disks

  services.zfs = {
    autoScrub.enable = true;
  };
}