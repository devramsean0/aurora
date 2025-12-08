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
  hasHomeManager = false;
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

        (
          { lib, pkgs, ... }:
          {
            networking.hostName = hostname;
            system.stateVersion = "25.05";

            # Enable cross-compilation support
            nixpkgs.buildPlatform = "x86_64-linux";
            nixpkgs.hostPlatform = "aarch64-linux";

            # Disable features that don't cross-compile well
            documentation.nixos.enable = false;
            programs.nixvim.enable = lib.mkForce false;

            # Install basic packages without gh
            environment.systemPackages = with pkgs; [ 
              vim 
              difftastic
            ];
            
            # Configure git without gh
            programs.git = {
              enable = true;
              prompt.enable = true;
              config = {
                diff.external = "${pkgs.difftastic}/bin/difft --color auto --background dark --display inline";
                init.defaultBranch = "main";
                pull.rebase = false;
              };
            };
          }
        )

        core
        shell
        tailscale

        ./hardware.nix
        ./config.nix
      ]
      ++ (if hasHomeManager then [ nixosModules.homeManager ] else [ ]);
  };
  inherit system canLogin hasHomeManager;
}
