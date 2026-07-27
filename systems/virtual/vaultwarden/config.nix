{ lib, ... }:
{
  services.tailscale.useRoutingFeatures = "client";

  services.tailscaleJoin = {
    secretsFile = "/run/secrets/tailscale-servers-exposed";
    tags = ["tag:servers" "tag:servers-exposed"];
    ssh = true;
  };

  services.vaultwarden = {
    enable = true;
    domain = "vw.sean.cyou";
    config = {
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8000;
    };
  };
}
