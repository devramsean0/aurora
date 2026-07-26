{ pkgs, lib, ... }:
{
  services.beszel.agent = {
    enable = true;
    smartmon.enable = true;
    environment = {
      LISTEN = "45876";
      HUB_URL = "https://beszel.sean.cyou";
    };
    environmentFile = "/run/secrets/beszel-agent"
  };
}