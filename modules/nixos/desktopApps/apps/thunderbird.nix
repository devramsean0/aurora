{ lib, pkgs, ... }:

{
  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird-esr;
    preferencesStatus = "locked";

    preferences = {
      "mail.openpgp.allow_external_gnupg" = true;
    };
  };
}