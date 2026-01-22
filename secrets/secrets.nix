let
  sean = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMwFh3BTQGMb/tO71WBntK02FZ4MaF2FfsnTnUXVsNOb";
in
{
  "immich-apikey.age".publicKeys = [ sean ];
}