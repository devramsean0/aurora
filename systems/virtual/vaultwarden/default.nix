{
  inputs,
  nixosModules,
  useCustomNixpkgsNixosModule,
  useNixvimModule,
  accountsForSystem,
  accountFromUsername,
  hostname,
  virtual-machines,
  ...
}:
let
  system = "x86_64-linux";
  canLogin = [ "sean" ];
  hasHomeManager = true;
  # Find this VM's configuration from the virtual-machines array
  vmConfig = builtins.head (builtins.filter (vm: vm.name == hostname) virtual-machines);
in
{
  nixosConfiguration = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = {
      inherit inputs accountFromUsername system;
      accounts = accountsForSystem canLogin;
      usernames = canLogin;
    };

    modules =
      with nixosModules;
      [
        useCustomNixpkgsNixosModule
        useNixvimModule

        {
          networking.hostName = hostname;
          system.stateVersion = "25.05";
        }

        core
        tailscale
        git

        custom.tailscale-join
        
        ./config.nix

        inputs.microvm.nixosModules.microvm

        # MicroVM guest configuration
        {
          microvm = {
            hypervisor = "qemu";
            vcpu = vmConfig.vcpu or 2;
            mem = vmConfig.mem or 2048;
            interfaces = vmConfig.interfaces or [];
            forwardPorts = vmConfig.forwardPorts or [];
            volumes = map (disk: {
              mountPoint = disk.mountPoint or "/";
              image = disk.image;
              size = disk.size or 10240;
            }) (vmConfig.disks or []);
            shares = vmConfig.shares or [];
          };
        }

      ]
      ++ (if hasHomeManager then [ nixosModules.homeManager ] else [ ]);
  };
  inherit system canLogin hasHomeManager;
}
