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
    interfaces.eth0.useDHCP = true;

    # LAN
    interfaces.eth1.ipv4.addresses = [{
      address = "192.168.1.1";
      prefixLength = 24;
    }];

    # NAT
    nat = {
      enable = true;
      externalInterface = "eth0";
      internalInterfaces = [ "eth1" ];
    };

    firewall = {
      enable = true;
      trustedInterfaces = [ "eth1" ];
    };
  };

  # DHCP + DNS
  services.dnsmasq = {
    enable = true;

    settings = {
      interface = "eth1"; # Listen on the downstream bridge
      domain-needed = true; # Force a domain part to forward upstream
      bogus-priv = true; # Don't forward to upstream if private dns resolution fails


      dhcp-range = "192.168.1.2,192.168.100.254,12h";
      domain = "local=/localnet"

      dhcp-option = [
        "3,192.168.100.1"  # gateway
        "6,192.168.100.1"  # DNS
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
}
