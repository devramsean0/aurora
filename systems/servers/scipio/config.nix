{ inputs, lib, config, virtualMachines ? [], ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
  ];
  services.tailscale.useRoutingFeatures = "server";
  boot.initrd.luks.devices = lib.mkForce {};

  # Enable auto upgrade
  #system.autoUpgrade = {
  #  enable = true;
  #  allowReboot = true;
  #  dates = "daily";
  #  flake = "github:devramsean0/aurora";
  #};

  # Dynamically configure MicroVMs from the virtual-machines array
  microvm.vms = builtins.listToAttrs (map (vm: {
    name = vm.name;
    value = {
      flake = inputs.self;
      autostart = vm.autostart or true;
    };
  }) virtualMachines);
   

  age.secrets = {
    sitev4 = {
      file = ../../../secrets/sitev4.age;
    };
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
