{ inputs, lib, config, ... }:
{
  services.tailscale.useRoutingFeatures = "client";
}
