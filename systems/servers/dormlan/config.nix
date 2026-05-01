{ inputs, lib, config, virtualMachines ? [], ... }:
{
  services.tailscale.useRoutingFeatures = "server";
  boot.initrd.luks.devices = lib.mkForce {};

  # Enable auto upgrade
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "daily";
    flake = "github:devramsean0/aurora";
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  networking = {
    # WAN
    interfaces.ens18.useDHCP = true;

    # LAN
    interfaces.ens19.ipv4.addresses = [{
      address = "10.94.69.1";
      prefixLength = 24;
    }];

    # NAT
    nat = {
      enable = true;
      externalInterface = "ens18";
      internalInterfaces = [ "ens19" ];
    };

    firewall = {
      enable = true;
      trustedInterfaces = [ "ens19" ];
    };
  };

  # DHCP + DNS
  services.dnsmasq = {
    enable = true;

    settings = {
      interface = "ens19"; # Listen on the downstream bridge
      domain-needed = true; # Force a domain part to forward upstream
      bogus-priv = true; # Don't forward to upstream if private dns resolution fails


      dhcp-range = "10.94.69.2,10.94.69.254,12h";
      domain = "local=/localnet";

      dhcp-option = [
        "3,10.94.69.1"  # gateway
        "6,10.94.69.1"  # DNS
      ];

      server = [
	"1.1.1.1"
	"1.0.0.1"
	"8.8.8.8"
      ];

      no-resolv = true;
      no-poll = true;
      no-hosts = true;
    };
  };

  services.resolved.enable = false;

  # Hack to ensure interfaces are up
  systemd.services.dnsmasq = {
    after = ["network-online.target"];
    wants = ["network-online.target"];
  };
}
