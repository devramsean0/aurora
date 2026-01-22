{ lib, inputs, config, ... }:
{
  imports = [
    inputs.agenix.nixosModules.default
  ];

  age.secrets = {
    immich-apikey.file = ../../secrets/immich-apikey.age;
  };
}