{ virtualMachines ? [], ...}:
{
  system.activationScripts.vm-upgrade = {
    text = ''
      ${builtins.listToAttrs (map (vm: "microvm -R -u ${vm.name}\n") virtualMachines)}
    ''
  }
}