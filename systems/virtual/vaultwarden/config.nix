{ lib, ... }:
{
  services.tailscale.useRoutingFeatures = "client";

  # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "daily";
    flake = "github:devramsean0/aurora";
  };

  services.tailscaleJoin = {
    secretsFile = "/run/secrets/tailscale-servers-exposed";
    tags = ["tag:servers" "tag:servers-exposed"];
    ssh = true;
  };
}
