{ lib, pkgs, ... }:

{
  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird;
    preferencesStatus = "locked";

    preferences = {
      "mail.openpgp.allow_external_gnupg" = true;
    };
  };
}
