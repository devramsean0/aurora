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
}
