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
    "xhci_pci"
    "nvme"
    "sdhci_pci"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  
  boot.initrd.luks.devices."cryptroot".bypassWorkqueues = true; # improve performance of encrypted NVME drives

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
