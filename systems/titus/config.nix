{ lib, ... }:
{
  services.tailscale.useRoutingFeatures = "client";
  
  services.xserver.xkb.layout = lib.mkForce "gb";
  services.xserver.xkb.variant = "mac";
  services.xserver.xkb.model = "apple";
  services.xserver.xkb.options = "lv3:ralt_switch";

  console.useXkbConfig = true;
}
