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

    modules = with nixosModules; [
      useCustomNixpkgsNixosModule
      useNixvimModule

      ({ modulesPath, lib, ... }: {
        imports = [
          (modulesPath + "/virtualisation/qemu-vm.nix")
        ];

        networking.hostName = hostname;
        system.stateVersion = "25.05";

        virtualisation = {
          memorySize = 2048;
          cores = 2;
          graphics = true;
          qemu.options = [ "-vga virtio" ];
        };

        # Simple grub bootloader for VM
        boot.loader.systemd-boot.enable = lib.mkForce false;
        boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
        boot.loader.grub = {
          enable = lib.mkForce true;
          device = "nodev";
          efiSupport = true;
        };

        # Forward journal to serial console for headless debugging
        services.journald.extraConfig = ''
          ForwardToConsole=yes
          TTYPath=/dev/ttyS0
          MaxLevelConsole=info
        '';
        boot.kernelParams = [ "console=ttyS0,115200n8" "console=tty0" ];
      })

      core
      desktop
      shell

    ];
  };
  inherit system canLogin hasHomeManager;
}
