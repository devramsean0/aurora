{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.services.immich-background-tool;
in
{
  options.services.immich-background-tool = {
    enable = mkEnableOption "Immich Background tool";

    secretsFile = mkOption {
      example = "/private/immich-data";
      default = null;
      type = types.nullOr types.path;
      description = ''
        env format file that contains information about your immich endpoint
      '';
    };

    package = mkOption {
      description = "the package to use";
      type = types.package;
      default = inputs.immich-background-tool.packages.${pkgs.system}.default or (throw "immich-background-tool is not available for ${pkgs.system}");
    };
  };

  config = mkIf cfg.enable {
    systemd.user = {
      services.immich-background-tool = {
        Unit = {
          Description = "Immich Background tool service";
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${cfg.package}/bin/immich-background-tool ${cfg.secretsFile} --sww-path \"${pkgs.swww}/bin/swww\"";
        };
      };

      timers.immich-background-tool = {
        Unit = {
          Description = "Immich Background tool timer";
        };

        Timer = {
          OnCalendar = "*:0/5";
          Persistent = true;
          Unit = "immich-background-tool.service";
        };
      };
    };
  };
}
