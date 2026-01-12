{ ... }:
{
  services.tailscale.useRoutingFeatures = "client";

  # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "daily";
    flake = "github:devramsean0/aurora";
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "postmaster@sean.cyou";

  networking.firewall.interfaces.enp0s6 = {
    allowedTCPPorts = [
      80 # HTTP
      443 # HTTPS
      22
    ];
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "sean.cyou" = {
        default = true;

        addSSL = true;
        enableACME = true;
        quic = true;
        http3 = true;
        http3_hq = true;

        locations."/" = {
	  recommendedProxySettings = true;
          proxyPass = "http://100.94.205.86:4433";
        };
      };
      "grafana.sean.cyou" = {
        addSSL = true;
        enableACME = true;
        quic = true;
        http3 = true;
        http3_hq = true;

        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://100.94.205.86:3000";
        };
      };
      "authentik.sean.cyou" = {
        addSSL = true;
        enableACME = true;
        quic = true;
        http3 = true;
        http3_hq = true;

        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://100.94.205.86:9000";
        };
      };
      "scoreboard.olp.sean.cyou" = {
        addSSL = true;
        enableACME = true;
        quic = true;
        http3 = true;
        http3_hq = true;

        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://100.94.205.86:4434";
        };
      };
    };
  };
}
