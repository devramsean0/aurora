{
  account,
  homeManagerModules,
  useCustomNixpkgsNixosModule,
  config,
  ...
}:
{
  imports = with homeManagerModules; [
    useCustomNixpkgsNixosModule
    git
    sway
    waybar
    immich-background-tool
  ];

  home.username = account.username;
  home.homeDirectory = "/home/${account.username}";
  home.stateVersion = "25.05";

  services.immich-background-tool = {
    enable = true;
    secretsFile = "/run/agenix/immich";
  };
}
