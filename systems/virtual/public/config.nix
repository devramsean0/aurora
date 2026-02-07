{ lib, config, inputs, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
  ];
  
  services.tailscale.useRoutingFeatures = "client";

  services.tailscaleJoin = {
    secretsFile = "/run/secrets/tailscale-servers-exposed";
    tags = ["tag:servers" "tag:servers-exposed"];
    ssh = true;
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      "sitev4" = {
        pull = "always";
        image = "ghcr.io/devramsean0/site-v4:latest";
        autoStart = true;
        ports = [
          "3000:3000"
        ];
        environmentFiles = [
          "/run/secrets/sitev4"
        ];
	environment = {
	  HOST = "0.0.0.0";
	  PORT = "3000";
	  UPLOADS_PATH = "/uploads";
	};
        volumes = [
          "/opt/sitev4/db.sqlite3:/app/db.sqlite3"
          "/opt/sitev4/uploads:/uploads"
        ];
      };
    };
  };
}
