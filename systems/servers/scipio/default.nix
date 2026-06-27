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
  hasHomeManager = false;
in
{
  nixosConfiguration = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    specialArgs = {
      inherit inputs accountFromUsername system;
      accounts = accountsForSystem canLogin;
      usernames = canLogin;
      virtualMachines = virtual-machines;
    };

    modules =
      with nixosModules;
      [
        useCustomNixpkgsNixosModule

        {
          networking.hostName = hostname;
          system.stateVersion = "25.05";
        }

        core
        bootloader
        fileSystems
        tailscale
        virtualisation
        agenix

        vm.autoupgrade

        inputs.microvm.nixosModules.host

        ./hardware.nix
        ./config.nix
        
      ]
      ++ (if hasHomeManager then [ nixosModules.homeManager ] else [ ]);
  };
  inherit system canLogin hasHomeManager;
}
