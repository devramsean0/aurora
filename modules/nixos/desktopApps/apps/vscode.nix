{ pkgs, lib, ... }:
{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      github.copilot
      mkhl.direnv
      wakatime.vscode-wakatime
      rust-lang.rust-analyzer
      jnoortheen.nix-ide
      mkhl.direnv
      github.copilot-chat
      astro-build.astro-vscode
    ];
  };
  programs.direnv.enable = true;
}
