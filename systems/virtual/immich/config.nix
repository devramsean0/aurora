{ lib, pkgs, ... }:
{
  services.tailscale.useRoutingFeatures = "client";

  services.tailscaleJoin = {
    secretsFile = "/run/secrets/tailscale-servers-exposed";
    tags = ["tag:servers" "tag:servers-exposed"];
    ssh = true;
  };

  fileSystems."/mnt/library" = {
    device = "outramnas.tail28b34.ts.net:/volume2/Immich Library";
    fsType = "nfs";
    options = [
      "_netdev"
      "x-systemd.automount"
      "x-systemd.idle-timeout=600"
      "x-systemd.after=tailscaled.service"
      "x-systemd.requires=tailscaled.service"
      "nofail"
      "x-systemd.mount-timeout=30"
    ];
  };

  boot.supportedFilesystems = [ "nfs" ];

  services.immich = {
    enable =  true;
    port = 2283;
    openFirewall = true;
    host = "::";
    mediaLocation = "/mnt/library";
  };

  services.s3Backup = {
    enable = true;
    schedule = "daily";
    environmentFile = "/run/secrets/immich-s3-backup";
    syncTargets = [
      {
        source = "/mnt/library/library";
        destination = "s3://photobackup-devramsean0/library/";
        extraArgs = [ "--storage-class" "DEEP_ARCHIVE"];
      }
      {
        source = "/mnt/library/upload";
        destination = "s3://photobackup-devramsean0/upload/";
        extraArgs = [ "--delete" "--storage-class" "STANDARD"];
      }
      {
        source = "/mnt/library/profile";
        destination = "s3://photobackup-devramsean0/profile/";
        extraArgs = [ "--delete" "--storage-class" "DEEP_ARCHIVE"];
      }
      {
	      source = "/mnt/library/backups";
        destination = "s3://photobackup-devramsean0/backups/";
        extraArgs = [ "--delete" "--storage-class" "STANDARD"];
      }
    ];
  };
}
