{ pkgs, ... }:
{
  services.pcscd.enable = true;
  systemd.services.pcscd = {
    wantedBy = [ ];
  };
}
