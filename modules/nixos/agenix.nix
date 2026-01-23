{ lib, inputs, config, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  age.secrets = {
    immich = {
      file = ../../secrets/immich.age;
      owner = "sean";
    };
  };
}