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

    modules = with nixosModules; [
      useCustomNixpkgsNixosModule
      useNixvimModule

      {
        networking.hostName = hostname;
        system.stateVersion = "25.05";

        nix.settings = {
          extra-substituters = [
            "https://nixos-apple-silicon.cachix.org"
          ];
          extra-trusted-public-keys = [
            "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
         ];
        };
	nixpkgs.config.allowUnsupportedSystem = true;
      }
      core
      bootloader
      fileSystems
      tailscale
#      virtualisation
      desktop
      shell
      git
      gpg
      agenix
      
      hardware.audio
      hardware.battery
      hardware.bluetooth
      hardware.yubikey

      desktopApps.core
      desktopApps.desktop
      desktopApps.development

      inputs.apple-silicon.nixosModules.default

      # Hack to override the Asahi Kernel for the FairyDust (external USB Display) with relevant patches
      ({ pkgs, lib, ... }: {
        hardware.asahi.overlay = lib.composeExtensions
          (import "${inputs.apple-silicon}/apple-silicon-support/packages/overlay.nix")
          (final: prev: {
            linux-asahi = prev.callPackage
              ({ lib, buildLinux, linuxPackagesFor, _kernelPatches ? [] }:
                lib.recurseIntoAttrs (linuxPackagesFor (buildLinux rec {
                  pname = "linux-asahi";
                  version = "7.0.13";
                  modDirVersion = version;
                  src = final.fetchFromGitHub {
                    owner = "AsahiLinux";
                    repo = "linux";
                    rev = "c83992242bc1e38bfc861a91696534479a2dbdf4";
                    hash = "sha256-sGcgrrf/rpb8u9dvwiTFdNjp18UyuRhW94biH1WMO5I=";
                  };
                  kernelPatches = prev.linux-asahi.kernel.kernelPatches ++ _kernelPatches;
                })))
              {};
          });
      })

      ./hardware.nix
      ./config.nix

    ] ++ (if hasHomeManager then [ nixosModules.homeManager ] else [ ]);
  };
  inherit system canLogin hasHomeManager;
}
