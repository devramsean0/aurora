{ pkgs, lib, ... }:
{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      github.copilot
      wakatime.vscode-wakatime
      rust-lang.rust-analyzer
      jnoortheen.nix-ide
      mkhl.direnv
      github.copilot-chat
    ];
  };
}
