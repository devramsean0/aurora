{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    qemu
  ];
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "sean" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}