{ inputs, lib, config, ... }:
{
  services.tailscale.useRoutingFeatures = "client";

  console.keyMap = lib.mkForce "us";
  services.xserver.xkb.layout = lib.mkForce "us";

  boot.initrd.luks.devices = lib.mkForce {};
}
