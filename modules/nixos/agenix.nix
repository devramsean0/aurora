{ lib, pkgs, inputs, config, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    age-plugin-yubikey
  ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets = {
    immich = {
      file = ../../secrets/immich.age;
      owner = "sean";
    };

    tailscale-servers-exposed = {
      file = ../../secrets/tailscale/servers/exposed.age;
    };
  };
}
