{ inputs, lib, config, ... }:
{
  services.tailscale.useRoutingFeatures = "server";

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers.upsnap = {
    image = "seriousm4x/upsnap:latest";
    autoStart = true;
    extraOptions = [ "--network=host" ];
    volumes = [
      "/var/lib/upsnap:/app/pb_data"
    ];
  };
}
