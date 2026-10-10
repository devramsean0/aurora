{ lib, ... }:
{
  services.tailscale.useRoutingFeatures = "client";

  services.xserver.xkb.layout = lib.mkForce "gb";
  services.xserver.xkb.variant = "mac";
  services.xserver.xkb.model = "apple";
  services.xserver.xkb.options = "lv3:ralt_switch";

  console.keyMap = lib.mkForce "uk";
  console.useXkbConfig = true;

  hardware.asahi.enable = true;

  # x86 emulation
  #boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
  #nix.settings.extra-platforms = [ "x86_64-linux" ];
}
