{
  pkgs,
  lib,
  accounts,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    starship
  ];

  systemd.tmpfiles.rules = lib.forEach accounts (account: "f /home/${account.username}/.zprofile");

  users.defaultUserShell = pkgs.zsh;
  programs.command-not-found.enable = false;

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''
      eval "$(starship init zsh)"
      source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh
    '';
    shellAliases = {
      q = "exit";
      ls = "ls --color=tty -A";
    };
  };

  programs.fzf = {
    keybindings = true;
    fuzzyCompletion = true;
  };

  programs.starship = {
    enable = true;
    presets = [ "pastel-powerline" ];
  };
}
