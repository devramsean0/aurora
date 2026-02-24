{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.s3Backup;
in
{
  options.services.s3Backup = {
    enable = mkEnableOption "Sync one or more folders to S3 using s5cmd";

    syncTargets = mkOption {
      type = types.listOf (types.submodule {
        options = {
          source = mkOption {
            type = types.path;
            example = "/srv/data";
            description = "Local source folder to sync.";
          };

          destination = mkOption {
            type = types.str;
            example = "s3://my-bucket/backups/";
            description = "S3 destination URL (s3://bucket/path/).";
          };

          extraArgs = mkOption {
            type = types.listOf types.str;
            default = [ "--delete" "--numworkers" "4" ];
            example = [ "--delete" "--numworkers" "8" ];
            description = "Extra arguments passed to s5cmd sync for this target.";
          };
        };
      });
      default = [ ];
      description = ''
        A list of sync targets. Each target specifies a source directory and
        destination S3 path (plus optional per-target arguments).
      '';
      example = [
        { source = "/srv/photos"; destination = "s3://mybucket/photos/"; }
        { source = "/srv/backups"; destination = "s3://mybucket/backups/"; extraArgs = [ "--delete" ]; }
      ];
    };

    schedule = mkOption {
      type = types.str;
      default = "daily";
      example = "*-*-* 03:00:00";
      description = "Systemd OnCalendar schedule for the sync job.";
    };

    user = mkOption {
      type = types.str;
      default = "root";
      description = "User under which to run the sync.";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/etc/s5cmd.env";
      description = ''
        Optional environment file containing AWS credentials or configuration.
        Each line should be of the form KEY=VALUE (e.g. AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION).
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.s5cmd ];

    # generate a single script that loops over sync targets
    systemd.services.s3Backup = {
      description = "S3 Backup/Sync Service";
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;

        ExecStart = pkgs.writeShellScript "s5cmd-sync-multiple" ''
          set -euo pipefail

          echo "[s5cmd-sync] Starting multi-folder sync..."

          ${concatStringsSep "\n" (map (target:
            ''
              echo "→ Syncing ${target.source} → ${target.destination}"
              ${pkgs.s5cmd}/bin/s5cmd sync ${concatStringsSep " " target.extraArgs} \
                ${target.source}/ ${target.destination} || {
                  echo "✗ Failed to sync ${target.source}"
                  exit 1
                }
            ''
          ) cfg.syncTargets)}

          echo "[s5cmd-sync] All syncs completed successfully."
        '';
      } // optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      };
    };

    systemd.timers.s3Backup = {
      description = "Periodic S3 Backup sync";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
        Unit = "s3Backup.service";
      };
    };
  };
}