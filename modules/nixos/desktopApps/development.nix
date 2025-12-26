{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./apps/postgresql.nix
    ./apps/vscode.nix
  ];

  environment.systemPackages = with pkgs; [
    devcontainer
  ];

}
