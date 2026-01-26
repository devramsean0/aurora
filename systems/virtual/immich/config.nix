{ lib, pkgs, ... }:
{
  services.tailscale.useRoutingFeatures = "client";

  services.tailscaleJoin = {
    secretsFile = "/run/secrets/tailscale-servers-exposed";
    tags = ["tag:servers" "tag:servers-exposed"];
    ssh = true;
  };

  # Setup SMB share for photos
  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  #fileSystems."/mnt/library" = {
  #  device = "//192.168.1.123/Volume2/Immich-Media";
  #  fsType = "cifs";
  #  options = let
      # this line prevents hanging on network split
  #    automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

  #    in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
  #};

  services.immich.enable = true;
  services.immich.port = 2283;
}
