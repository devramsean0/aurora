{ inputs, nixosModules, useCustomNixpkgsNixosModule, useNixvimModule, accountsForSystem, accountFromUsername, hostname, ... }:
let
  system = "aarch64-linux";
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

      nixos-raspberrypi = inputs.nixos-raspberrypi;
    };

    modules = with nixosModules; [
      useCustomNixpkgsNixosModule
      useNixvimModule

      {
        networking.hostName = hostname;
        system.stateVersion = "25.05";
      }

      core
      tailscale
      shell
      git

     inputs.nixos-raspberrypi.nixosModules.raspberry-pi-02.base
     ./hardware

    ] ++ (if hasHomeManager then [nixosModules.homeManager ] else [ ]);
  };
  inherit system canLogin hasHomeManager;
}
