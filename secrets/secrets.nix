let
  backup = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHfrKqOTYvCejD7bcZeJH0InGyVIdLvYvPqqI91ssNqj";
  sean = "age1yubikey1qgecwkndshtahukxjmht50dscw8m8xywh3gytr35ch0pkph4xtr7s2xc5gj";
  titus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIf5GYnmoU0fZ6DdS1Wt2dV72Jfuyvf2pkKkEa+tOq1t";
in
{
  "immich.age".publicKeys = [ titus backup sean ];
}
