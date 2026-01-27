{ virtualMachines ? [], inputs, system, pkgs, ...}:
{
  system.activationScripts.vm-upgrade = {
    text = ''
      export PATH=${pkgs.systemd}/bin:$PATH
      ${builtins.concatStringsSep "\n" (map (vm: "${inputs.microvm.packages.${system}.microvm}/bin/microvm -R -u ${vm.name}") virtualMachines)}
    '';
  };
}
