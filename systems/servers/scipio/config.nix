{ config, virtualMachines ? [],... }:
{

  # Dynamically configure MicroVMs from the virtual-machines array
  microvm.vms = builtins.listToAttrs (map (vm: {
    name = vm.name;
    value = {
      flake = inputs.self;
      autostart = vm.autostart or true;
    };
  }) virtualMachines);
}
