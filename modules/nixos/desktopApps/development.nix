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

  programs.direnv.enable = true;
  environment.systemPackages = with pkgs; [
    devcontainer
  ];

}
