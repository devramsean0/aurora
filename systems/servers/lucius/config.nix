{ ... }:
{
  services.tailscale.useRoutingFeatures = "server";

  # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "daily";
    flake = "github:devramsean0/aurora";
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "postmaster@sean.cyou";

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking.firewall.interfaces.enp0s6 = {
    allowedTCPPorts = [
      80 # HTTP
      443 # HTTPS
    ];
  };

  services.nginx = {
    enable = true;
    resolver = {
      addresses = [ "100.100.100.100" ];
      valid = "30s";
    };
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
      "vw.sean.cyou" = {
        addSSL = true;
        enableACME = true;
        quic = true;
        http3 = true;
        http3_hq = true;

        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://100.94.205.86:4435";
        };
      };
      "immich.sean.cyou" = {
        addSSL = true;
        enableACME = true;
        quic = true;
        http3 = true;
        http3_hq = true;

        extraConfig = """
          client_max_body_size 5000M;
          proxy_request_buffering off;
          client_body_buffer_size 1024k;
          
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;

          proxy_http_version 1.1;
          proxy_redirect off;

          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
          send_timeout 600s;
        """;

        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://immich.tail28b34.ts.net:2283";
          proxyWebsockets = true;
        };
      };
    };
  };
}
