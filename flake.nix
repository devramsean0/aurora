{
  description = "NixOS configuration for my shenanigans";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    supertram-next-departures = {
      url = "github:devramsean0/supertram-next-departures";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-silicon = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    immich-background-tool = {
      url = "github:devramsean0/immich-background-tool";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nixvim,
      supertram-next-departures,
      apple-silicon,
      immich-background-tool,
      agenix,
      microvm,
      ...
    }@inputs:
    let
      # Which accounts can access which systems is handled per-system.
      accounts = [
        {
          username = "sean";
          realname = "Sean Outram";
          email = "me@sean.cyou";
          # profileicon = ./users/headb.png;
          sshkeys = [
            # TODO: Add SSH keys
          ];
          # The first GPG key is used as the default for signing git commits.
          gpgkeys = [
            # TODO: Add GPG keys
            "F5BEFD69E00A6916E3038E64433C1F3597F06C92"
          ];
          groups = [
            "libvirtd"
          ];
          trusted = true; # Root access (trusted-user, wheel)
          hashedPassword = "$6$XxzpK4DwPBUdEP48$p/4MlWxtRAi8/l3jw3WftC2AhVHpznJt6O/xAEFnEq9Z71hAUl3.X3g4LcJH3XVhZwnoSLCFfwSHCEZ4QOv5u0";
        }
      ];

      virtual-machines = [
        {
          name = "immich";
          autostart = true;
          vcpu = 4;
          mem = 4096;

          disks = [
            {
              image = "/var/lib/microvms/immich.qcow2";
              size = 51200; # Size in MB
              mountPoint = "/";
            }
          ];

          interfaces = [
            {
              type = "user";
              id = "vm-immich";
              mac = "02:00:00:00:00:01";
            }
          ];

          forwardPorts = [
            { from = "host"; host.port = 2222; guest.port = 22; }
          ];

          shares = [
            {
              tag = "tailscale-secret";
              source = "/run/agenix";
              mountPoint = "/run/secrets";
              proto = "virtiofs";
            }
          ];
        }
      ];

      # Packages in nixpkgs that I want to override.
      nixpkgs-overlay = (
        final: prev: rec {
          # Make pkgs.unstable.* point to nixpkgs unstable branch.
          unstable = import inputs.nixpkgs-unstable {
            system = final.system;
            config = {
              allowUnfree = true;
            };
          };
          home-manager = inputs.home-manager.packages.${final.system}.default;
        }
      );

      # Configuration for nixpkgs.
      nixpkgs-config = {
        allowUnfree = true;
      };

      # Find all system paths (e.g., "hosts/gaius", "isos/install-iso") that have a default.nix
      findSystems =
        baseDir:
        let
          # Get category directories (hosts, isos, servers)
          categories = builtins.attrNames (
            inputs.nixpkgs.lib.filterAttrs (name: type: type == "directory") (builtins.readDir baseDir)
          );
          # For each category, get the system directories inside it
          systemsInCategory = category:
            let
              categoryPath = baseDir + "/${category}";
              systems = builtins.attrNames (
                inputs.nixpkgs.lib.filterAttrs (name: type: type == "directory") (builtins.readDir categoryPath)
              );
            in
            builtins.map (system: "${category}/${system}") systems;
        in
        inputs.nixpkgs.lib.flatten (builtins.map systemsInCategory categories);

      # An array of every system path in ./systems (e.g., "hosts/gaius", "isos/install-iso").
      systemNames = findSystems ./systems;

      # Recursively find all .nix files in a directory and return them as a nested attribute set.
      findModules =
        dir:
        let
          entries = builtins.readDir dir;
          processEntry =
            name: type:
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
        inputs.nixpkgs.lib.foldl' (acc: entry: acc // (processEntry entry.name entry.value)) { } (
          inputs.nixpkgs.lib.mapAttrsToList (name: value: { inherit name value; }) entries
        );

      # An attribute set of all the NixOS modules in ./modules/nixos (including subdirectories).
      nixosModules = findModules ./modules/nixos;

      # An attribute set of all the NixOS modules in ./modules/home-manager (including subdirectories).
      homeManagerModules = findModules ./modules/home-manager;

      # Extract hostname from system path (e.g., "hosts/maximus" -> "maximus")
      hostnameFromPath = path: inputs.nixpkgs.lib.last (inputs.nixpkgs.lib.splitString "/" path);

      # Create a mapping from hostname to system path
      hostnameToPath = inputs.nixpkgs.lib.listToAttrs (
        builtins.map (path: {
          name = hostnameFromPath path;
          value = path;
        }) systemNames
      );

      # List of just hostnames (for nixosConfigurations keys)
      hostnames = builtins.attrNames hostnameToPath;

      # A filtered array of system paths that have home-manager modules
      systemPathsWithHomeManager = builtins.filter (
        system: (callSystem system).hasHomeManager
      ) systemNames;

      # A function that takes a username and a system path and returns whether that user can log in to that system.
      canLoginToSystem = username: system: builtins.elem username (callSystem system).canLogin;

      usernames = builtins.map (account: account.username) accounts;
      usernamesAtHostsWithHomeManager = inputs.nixpkgs.lib.flatten (
        builtins.map (
          username:
          builtins.map (
            systemPath: if canLoginToSystem username systemPath then "${username}@${hostnameFromPath systemPath}" else null
          ) systemPathsWithHomeManager
        ) usernames
      );
      # A function that returns the account for a given username.
      accountFromUsername =
        username: builtins.elemAt (builtins.filter (account: account.username == username) accounts) 0;

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
      callSystem = (
        systemPath:
        let
          # Extract just the hostname (last component) from paths like "isos/install-iso"
          hostname = inputs.nixpkgs.lib.last (inputs.nixpkgs.lib.splitString "/" systemPath);
        in
        import ./systems/${systemPath} {
          # Pass on the inputs and nixosModules.
          inherit
            inputs
            nixosModules
            hostname
            useCustomNixpkgsNixosModule
            useNixvimModule
            accountFromUsername
            virtual-machines
            ;

          # Pass on a function that returns a filtered list of accounts based on an array of usernames.
          accountsForSystem =
            canLogin: builtins.filter (account: builtins.elem account.username canLogin) accounts;
        }
      );
    in
    {
      inherit nixosModules homeManagerModules;

      # Gets the NixOS configuration for every system in ./systems.
      nixosConfigurations = inputs.nixpkgs.lib.genAttrs hostnames (
        hostname: (callSystem hostnameToPath.${hostname}).nixosConfiguration
      );

      homeConfigurations = inputs.nixpkgs.lib.genAttrs usernamesAtHostsWithHomeManager (
        username-hostname:
        let
          username-hostname-split = builtins.split "@" username-hostname;
          username = builtins.elemAt username-hostname-split 0;
          hostname = builtins.elemAt username-hostname-split 2;
          architecture =
            (callSystem hostnameToPath.${hostname}).system;
        in
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = inputs.nixpkgs.legacyPackages.${architecture};
          extraSpecialArgs = {
            inherit inputs homeManagerModules useCustomNixpkgsNixosModule hostname;
            account = accountFromUsername username;
          };
          modules = [ ./users/${username}.nix ];
        }
      );

      # Expose packages, specifically the ISO image for install-iso
      packages.x86_64-linux = {
        # Build the install-iso as a package
        install-iso = (callSystem "isos/install-iso").nixosConfiguration.config.system.build.isoImage;
        desktop-iso = (callSystem "isos/desktop-iso").nixosConfiguration.config.system.build.isoImage;
      };
    };
}
