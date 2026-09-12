{ config, lib, pkgs, ... }:
let
  lldapCfg = config.services.lldap;

  bootstrapScript = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/lldap/lldap/v${lldapCfg.package.version}/scripts/bootstrap.sh";
    sha256 = "sha256-ttXIsbdK8QaMvv5mpEd2TYH6EtShIZHHaUsYoSRbBUw=";
    executable = true;
  };

  groups = [
  
  ];

  users = [
    {
      id = "tinyauth-observer";
      email = "me+tinyauth-observer@sean.cyou";
      password_file = "/run/secrets/lldapobserverpass";
      groups = [ "lldap_strict_readonly" ];
    }
  ];

  groupConfigs = pkgs.linkFarm "lldap-group-configs" (
    map (g: { name = "${g.name}.json"; path = pkgs.writeText "${g.name}-group.json" (builtins.toJSON g); }) groups
  );

  userConfigs = pkgs.linkFarm "lldap-user-configs" (
    map (u: { name = "${u.id}.json"; path = pkgs.writeText "${u.id}-user.json" (builtins.toJSON u); }) users
  );
in
{

  systemd.services.lldap-bootstrap = {
    description = "Declaratively provision lldap users and groups";
    after = [ "lldap.service" ];
    requires = [ "lldap.service" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ bash coreutils gnused gnugrep curl jq jo ];
    serviceConfig.Type = "oneshot";
    script = ''
      export LLDAP_URL="http://localhost:${toString lldapCfg.settings.http_port}"
      export LLDAP_ADMIN_USERNAME="${lldapCfg.settings.ldap_user_dn}"
      export LLDAP_ADMIN_PASSWORD_FILE="/run/secrets/lldapadminpass";
      export LLDAP_SET_PASSWORD_PATH="${lldapCfg.package}/bin/lldap_set_password"
      export USER_CONFIGS_DIR="${userConfigs}"
      export GROUP_CONFIGS_DIR="${groupConfigs}"
      exec ${bootstrapScript}
    '';
  };
}