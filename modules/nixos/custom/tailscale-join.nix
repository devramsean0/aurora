# Module to automatically join a client to my tailnet
{ config, pkgs, lib, ...}:
with lib;
let
  cfg = config.services.tailscaleJoin;
in {
  options.services.tailscaleJoin = {
    secretsFile = mkOption {
      example = "/private/immich-data";
      default = null;
      type = types.nullOr types.path;
      description = ''
        env format file that contains your tailscale access key
      '';
    };

    tags = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of tags to advertise as";
    };

    ephermal = mkOption {
      type = types.bool;
      default = true;
      description = "should the node be ephermal?";
    };

    ssh = mkOption {
      type = types.bool;
      default = false;
      description = "should the node allow ssh";
    };
  };

  config = mkIf (cfg.secretsFile != null) {
    environment.systemPackages = [ pkgs.tailscale ];

    systemd.services.tailscaleJoinUp = {
      description = "Tailscale Join Service";
      after = [ "network-online.target" "tailscaled.service" ];
      wants = [ "tailscaled.service" "network-online.target" ];
      requires = [ "tailscaled.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        EnvironmentFile = cfg.secretsFile;
        # $TAILSCALE_CLIENT_SECRET equals the oauth secret protected by age
        Restart = "on-failure";
        RestartSec = "5s";
      };
      script = let
        tagsArg = if cfg.tags != [] then "--advertise-tags=${concatStringsSep "," cfg.tags}" else "";
        sshArg = if cfg.ssh == true then "--ssh=true" else "--ssh-false";
        ephemeralParam = if cfg.ephermal then "&ephemeral=true" else "";
      in ''
        # Wait for secrets file to be available
        while [ ! -f "${cfg.secretsFile}" ]; do
          echo "Waiting for secrets file ${cfg.secretsFile}..."
          sleep 1
        done
        
        # Wait for tailscaled to be ready
        sleep 2
        
        COMPLETED_AUTH_STRING="$TAILSCALE_CLIENT_SECRET?preauthorized=true${ephemeralParam}"
        ${pkgs.tailscale}/bin/tailscale up --auth-key="$COMPLETED_AUTH_STRING" ${tagsArg} ${sshArg}
      '';
      wantedBy = [ "multi-user.target" ];
    };
  };
}