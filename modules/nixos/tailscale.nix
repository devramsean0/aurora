{ pkgs, ... }:
{
  services.tailscale.enable = true;
  networking.resolvconf.enable = true;  
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.checkReversePath = "loose";
}
