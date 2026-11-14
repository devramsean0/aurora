{ lib, inputs, ... }:
{
  imports = [
    inputs.bootvine.nixosModules.default
  ];
  services.bootvine.enable = true;
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        editor = false;
      };
    };
  };
}
