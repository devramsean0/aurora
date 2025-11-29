{ ... }:
{
  # Refer to the partition by its partition-label (set by the installer) instead
  # of a filesystem label. The installer sets the partition name to
  # 'encryptedroot' so /dev/disk/by-partlabel/encryptedroot will exist.
  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-partlabel/encryptedroot";
  fileSystems."/" =
    {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      options = [ "fmask=0137" "dmask=0027" ];
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

  swapDevices = [{
    device = "/swap";
    size = 8 * 1024;
  }];
}