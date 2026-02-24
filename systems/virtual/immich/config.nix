{ lib, pkgs, ... }:
{
  services.tailscale.useRoutingFeatures = "client";

  services.tailscaleJoin = {
    secretsFile = "/run/secrets/tailscale-servers-exposed";
    tags = ["tag:servers" "tag:servers-exposed"];
    ssh = true;
  };

  fileSystems."/mnt/library" = {
    device = "192.168.1.123:/volume2/Immich Library";
    fsType = "nfs";
    options = [
       "x-systemd.automount" 
      "noauto" 
      "x-systemd.idle-timeout=60" 
      "x-systemd.requires=network-online.target"
      "x-systemd.mount-timeout=10s"
      "_netdev"
    ];
  };

  systemd.network.wait-online.enable = true;
  boot.supportedFilesystems = [ "nfs" ];

  services.immich = {
    enable =  true;
    port = 2283;
    openFirewall = true;
    host = "::";
    mediaLocation = "/mnt/library";
  };
}
