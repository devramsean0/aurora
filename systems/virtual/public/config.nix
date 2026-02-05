{ lib, ... }:
{
  services.tailscale.useRoutingFeatures = "client";

  services.tailscaleJoin = {
    secretsFile = "/run/secrets/tailscale-servers-exposed";
    tags = ["tag:servers" "tag:servers-exposed"];
    ssh = true;
  };


  age.secrets = {
    sitev4 = {
      file = ../../secrets/sitev4.age;
    };
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      "sitev4" = {
        pull = "newer";
        image = "ghcr.io/devramsean0/site-v4:latest";
        autoStart = true;
        ports = [
          "3000:3000"
        ];
        environmentFiles = [
          age.secrets.sitev4.path
        ];
        volumes = [
          "/opt/sitev4/db.sqlite3:/app/db.sqlite3"
          "/opt/sitev4/uploads:/uploads"
        ]
      };
    };
  };
}
