{
  description = "NixOS configuration for my shenanigans";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixpkgs-unstable, nixvim, ... }@inputs:
    let
      # Which accounts can access which systems is handled per-system.
      accounts = [
        {
          username = "sean";
          realname = "Sean Outram";
          email = "me@edwardh.dev";
          # profileicon = ./users/headb.png;
          sshkeys = [
            # TODO: Add SSH keys
          ];
          # The first GPG key is used as the default for signing git commits.
          gpgkeys = [
            # TODO: Add GPG keys
          ];
          groups = [
            "libvirtd"
          ];
          trusted = true; # Root access (trusted-user, wheel)
          hashedPassword = "$6$XxzpK4DwPBUdEP48$p/4MlWxtRAi8/l3jw3WftC2AhVHpznJt6O/xAEFnEq9Z71hAUl3.X3g4LcJH3XVhZwnoSLCFfwSHCEZ4QOv5u0";
        }
      ];

      # Packages in nixpkgs that I want to override.
      nixpkgs-overlay = (
        final: prev:
          {
            # Make pkgs.unstable.* point to nixpkgs unstable branch.
            unstable = import inputs.nixpkgs-unstable {
              system = final.system;
              config = {
                allowUnfree = true;
              };
            };
          }
      );

      # Configuration for nixpkgs.
      nixpkgs-config = {
        allowUnfree = true;
      };

      # An array of every system folder in ./systems.
      systemNames = builtins.attrNames (inputs.nixpkgs.lib.filterAttrs (path: type: type == "directory") (builtins.readDir ./systems));

      # Recursively find all .nix files in a directory and return them as a nested attribute set.
      findModules = dir:
        let
          entries = builtins.readDir dir;
          processEntry = name: type:
            let
              path = dir + "/${name}";
            in
            if type == "directory" then
              # Recursively process subdirectories
              { "${name}" = findModules path; }
            else if type == "regular" && inputs.nixpkgs.lib.hasSuffix ".nix" name then
              # Add .nix files (excluding .gitkeep and other non-.nix files)
              { "${inputs.nixpkgs.lib.removeSuffix ".nix" name}" = path; }
            else
              { };
        in
        inputs.nixpkgs.lib.foldl' (acc: entry: acc // (processEntry entry.name entry.value)) { } (inputs.nixpkgs.lib.mapAttrsToList (name: value: { inherit name value; }) entries);

      # An attribute set of all the NixOS modules in ./modules/nixos (including subdirectories).
      nixosModules = findModules ./modules/nixos;

      # A function that takes a username and a system name and returns whether that user can log in to that system.
      canLoginToSystem = username: system: builtins.elem username (callSystem system).canLogin;

      # A function that returns the account for a given username.
      accountFromUsername = username: builtins.elemAt (builtins.filter (account: account.username == username) accounts) 0;

      # A mini-module that configures nixpkgs to use our custom overlay and configuration.
      useCustomNixpkgsNixosModule = {
        nixpkgs = {
          overlays = [ nixpkgs-overlay ];
          config = nixpkgs-config;
        };
      };

      # A mini-module that imports nixvim at the system level.
      useNixvimModule = inputs.nixvim.nixosModules.nixvim;

      # A function that returns for a given system's name:
      # - its NixOS configuration (nixosConfiguration)
      # - its system architecture (system)
      # - the accounts that can log in to it (canLogin)
      callSystem = (hostname: import ./systems/${hostname} {
        # Pass on the inputs and nixosModules.
        inherit inputs nixosModules hostname useCustomNixpkgsNixosModule useNixvimModule accountFromUsername;

        # Pass on a function that returns a filtered list of accounts based on an array of usernames.
        accountsForSystem = canLogin: builtins.filter (account: builtins.elem account.username canLogin) accounts;
      });
    in
    {
      inherit nixosModules;

      # Gets the NixOS configuration for every system in ./systems.
      nixosConfigurations = inputs.nixpkgs.lib.genAttrs systemNames (hostname: (callSystem hostname).nixosConfiguration);
    };
}