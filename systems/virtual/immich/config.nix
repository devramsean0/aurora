{ lib, pkgs, ... }:
{
  services.tailscale.useRoutingFeatures = "client";

  services.tailscaleJoin = {
    secretsFile = "/run/secrets/tailscale-servers-exposed";
    tags = ["tag:servers" "tag:servers-exposed"];
    ssh = true;
  };

  fileSystems."/mnt/library" = {
    device = "//192.168.1.123/Volume2/Immich-Media";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" ];
  };

  boot.supportedFilesystems = [ "nfs" ];

  services.immich = {
    enable =  true;
    port = 2283;
    openFirewall = true;
    host = "::";
    mediaLocation = "/mnt/library";
  };
}
