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

  services.lldap = {
    enable = true;
    database.type = "postgresql";
    settings = {
      ldap_base_dn = "dc=sean,dc=cyou";
      ldap_user_email = "admin@sean.cyou";
      http_url = "https://ldap.auth.sean.cyou";
      force_ldap_user_pass_reset = "always";
    };

    environment.LLDAP_LDAP_USER_PASS_FILE = "/run/credentials/lldap.service/admin_pass";
  };

  services.tinyauth = {
    enable = true;

    settings = {
      APPURL = "https://auth.sean.cyou";

      LDAP_ADDRESS = "ldap://127.0.0.1:3890";
      LDAP_BINDDN = "uid=tinyauth-observer,ou=people,dc=sean,dc=cyou";
      LDAP_BASEDN = "dc=sean,dc=cyou";
      LDAP_SEARCHFILTER = "(uid=%s)";
      LDAP_INSECURE = true;
      LDAP_BINDPASSWORDFILE = "/run/credentials/tinyauth.service/ldap-bind-password";
      LDAP_GROUPCACHETTL = 300;
    };
  };

  systemd.services = {
    lldap.serviceConfig.LoadCredential = [
      "admin_pass:/run/secrets/lldapadminpass"
    ];
    tinyauth.serviceConfig.LoadCredential = [
      "ldap-bind-password:/run/secrets/lldapobserverpass"
    ];
  };
}
