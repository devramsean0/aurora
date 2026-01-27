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

  fileSystems."/mnt/library" = {
    device = "//192.168.1.123/Volume2/Immich-Media";
    fsType = "nfs";
  };

  services.immich = {
    enable =  true;
    port = 2283;
    openFirewall = true;
    host = "::";
    mediaLocation = "/mnt/library";
  };
}
