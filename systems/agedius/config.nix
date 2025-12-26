{ ... }:
{
  services.tailscale.useRoutingFeatures = "client";
  
  # Optimize for limited resources
  nix.settings.max-jobs = 1;
  nix.settings.cores = 4;
}
