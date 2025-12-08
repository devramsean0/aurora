{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gnupg
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
    enableSSHSupport = true;
  };
  environment.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/gnupg/S.gpg-agent.ssh";
  programs.git.config = {
    commit.gpgsign = true;
    tag.gpgsign = true;
    gpg.program = "${pkgs.gnupg}/bin/gpg";
  };
}
