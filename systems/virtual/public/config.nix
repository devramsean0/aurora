{ lib, config, inputs, pkgs, ... }:
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

  services.beszel.hub.enable = true;

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


  users.users.trainstationmap = {
    isNormalUser = false;
    isSystemUser = true;
    group = "trainstationmap";
  };

  users.groups.trainstationmap = {};

  systemd.services.train-stations-map = {
    description = "Train Stations Map service";

    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${inputs.train-stations-map.packages.${pkgs.system}.default}/bin/train-stations-map";
      Restart = "on-failure";
      RestartSec = "5s";
      EnvironmentFile = [
        "/run/secrets/trainstationmap"
      ];
      Environment = [
        "RUST_LOG=info"
	"ADDR=0.0.0.0:3001"
      ];
      WorkingDirectory = "/usr/local/trainstationmap";

      User = "trainstationmap"; 
    };
  };
}
