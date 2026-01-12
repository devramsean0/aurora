{
  inputs,
  nixosModules,
  useCustomNixpkgsNixosModule,
  useNixvimModule,
  accountsForSystem,
  accountFromUsername,
  hostname,
  ...
}:
let
  system = "aarch64-linux";
  canLogin = [ "sean" ];
  hasHomeManager = true;
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
        bootloader
        fileSystems
        tailscale
        git
        
        ./config.nix
        ./hardware.nix

      ]
      ++ (if hasHomeManager then [ nixosModules.homeManager ] else [ ]);
  };
  inherit system canLogin hasHomeManager;
}
