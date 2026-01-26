{ inputs, lib, config, virtualMachines ? [],... }:
{
  services.tailscale.useRoutingFeatures = "server";
  boot.initrd.luks.devices = lib.mkForce {};

  # Dynamically configure MicroVMs from the virtual-machines array
  microvm.vms = builtins.listToAttrs (map (vm: {
    name = vm.name;
    value = {
      flake = inputs.self;
      autostart = vm.autostart or true;
    };
  }) virtualMachines);

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
