{ ... }:
{
  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-partlabel/encryptedroot";
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    options = [
      "fmask=0137"
      "dmask=0027"
    ];
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/swap";
      size = 8 * 1024;
    }
  ];
}
