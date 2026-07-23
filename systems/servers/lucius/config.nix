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

    allowedUDPPorts = [
      5060 # SIP
    ];
    allowedUDPPortRanges = [
      {
        from = 10000;
        to = 20000;
      }
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
          proxyPass = "http://public.tail28b34.ts.net:3000";
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

        extraConfig = ''
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
        '';

        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://immich.tail28b34.ts.net:2283";
          proxyWebsockets = true;
        };
      };
    };
  };

  # Asterisk

  age.secrets.pjsip-secrets = {
    file = ../../secrets/pjsip-secrets.age;
    owner = "asterisk";
    group = "asterisk";
    mode = "0440";
  };

  services.asterisk = {
    enable = true;
    confFiles = {
      "pjsip.conf" = ''
        ; ───────────────────────── Transports ─────────────────────────
        [transport-udp]
        type=transport
        protocol=udp
        bind=0.0.0.0:5060
        ; If this box is behind NAT (home router, cloud VM with a private
        ; + floating IP, etc.), uncomment and fill these in so SIP/RTP
        ; advertise your real public address:
        ; external_media_address=<YOUR_PUBLIC_IP>
        ; external_signaling_address=<YOUR_PUBLIC_IP>
        ; local_net=192.168.0.0/16
        ; local_net=10.0.0.0/8
        ; local_net=172.16.0.0/12

        ; ── Secrets, pulled in from the agenix-decrypted file. Must come
        ; before anything below that references twilio-auth / myphone-auth.
        #include ${config.age.secrets.pjsip-secrets.path}

        ; ───────────────────── Twilio trunk (outbound) ─────────────────
        [twilio-aor]
        type=aor
        contact=sip:seano-us-phone-gateway.pstn.twilio.com:5060
        qualify_frequency=30

        [twilio-endpoint]
        type=endpoint
        transport=transport-udp
        context=from-twilio
        disallow=all
        allow=ulaw
        allow=alaw
        outbound_auth=twilio-auth
        aors=twilio-aor
        from_domain=seano-us-phone-gateway.pstn.twilio.com
        from_user=+18023556415
        rtp_symmetric=yes
        force_rport=yes
        rewrite_contact=yes

        ; ───────────────── Twilio trunk (inbound, by IP) ───────────────
        ; Twilio's SIP signaling IPs vary by edge/region, so pull the
        ; current list from Twilio's docs and list them here. Example
        ; ranges shown -- verify against Twilio's published IP list
        ; before relying on this.
        [twilio-identify]
        type=identify
        endpoint=twilio-endpoint
        match=54.172.60.0/23
        match=54.244.51.0/24
        match=54.171.127.192/26
        match=35.156.191.128/25
        match=54.65.63.192/26
        match=54.65.63.0/26

        ; ───────────────── Softphone app (your SIP client) ─────────────
        ; auth is myphone-auth, defined in the included secrets file above.
        [myphone-aor]
        type=aor
        max_contacts=1
        remove_existing=yes

        [myphone]
        type=endpoint
        transport=transport-udp
        context=from-internal
        disallow=all
        allow=ulaw
        allow=alaw
        auth=myphone-auth
        aors=myphone-aor
        rtp_symmetric=yes
        force_rport=yes
        rewrite_contact=yes
        direct_media=no
      '';

      "extensions.conf" = ''
        [from-internal]
        ; Softphone dials any number -> goes out over the Twilio trunk.
        exten => _X.,1,NoOp(Outbound call to ''${EXTEN})
         same => n,Dial(PJSIP/''${EXTEN}@twilio-endpoint,30)
         same => n,Hangup()

        [from-twilio]
        ; Inbound call from Twilio -> ring the softphone.
        exten => _X.,1,NoOp(Inbound call from Twilio to ''${EXTEN})
         same => n,Dial(PJSIP/myphone,20)
         same => n,Hangup()
      '';

      "rtp.conf" = ''
        [general]
        rtpstart=10000
        rtpend=20000
      '';
    };
  };
}
