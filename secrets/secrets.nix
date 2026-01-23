let
  sean = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHfrKqOTYvCejD7bcZeJH0InGyVIdLvYvPqqI91ssNqj";
  titus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIf5GYnmoU0fZ6DdS1Wt2dV72Jfuyvf2pkKkEa+tOq1t";
in
{
  "immich.age".publicKeys = [ titus sean ];
}