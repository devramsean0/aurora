{
  account,
  homeManagerModules,
  useCustomNixpkgsNixosModule,
  ...
}:
{
  imports = with homeManagerModules; [
    useCustomNixpkgsNixosModule
    git
    sway
    waybar
  ];

  home.username = account.username;
  home.homeDirectory = "/home/${account.username}";
  home.stateVersion = "25.05";
}
