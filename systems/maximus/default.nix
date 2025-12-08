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
  system = "x86_64-linux";
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

    modules = with nixosModules; [
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
      virtualisation
      desktop
      shell
      git
      gpg

      hardware.audio
      hardware.yubikey

      desktopApps.core
      desktopApps.desktop

      ./hardware.nix
      ./config.nix

    ];
  };
  inherit system canLogin hasHomeManager;
}
