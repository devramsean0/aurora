{ pkgs, ... }:
{
  services.tailscale.enable = true;
  networking.resolvconf.enable = true;  
}
