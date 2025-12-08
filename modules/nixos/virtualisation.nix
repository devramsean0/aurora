{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    qemu
  ];
  programs.virt-manager.enable = true;

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    docker.enable = true;
  };
}
