{ inputs, lib, config, pkgs, usernames, accountFromUsername, ... }:
let
  trustedUsernames = builtins.filter (username: (accountFromUsername username).trusted) usernames;
in
{
  imports = [
    ./desktopApps/apps/vim.nix
  ];
  # Delete the /tmp directory every boot.
  boot.tmp.cleanOnBoot = true;

  # Add Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
  ];

  # Set regonal settings.
  networking.networkmanager.enable = true;
  environment.localBinInPath = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";
  services.automatic-timezoned.enable = true;

  # Standard packages that I want on all machines + minor package allowance
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    trusted-users = trustedUsernames;
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
    download-buffer-size = 524288000; # 500MiB
  };

  # Add each input as a flake registry to make nix commands consistent.
  nix.registry = lib.mkOverride 10 ((lib.mapAttrs (_: flake: { inherit flake; })) ((lib.filterAttrs (_: lib.isType "flake")) inputs));

  # Add each input to the system channels, to make nix-command consistent too.
  nix.nixPath = [ "/etc/nix/path" ];
  environment.etc =
    lib.mapAttrs'
      (name: value: {
        name = "nix/path/${name}";
        value.source = value.flake;
      })
      config.nix.registry;

  # Use next-gen nixos switch.
  system.switch = {
    enable = false;
    enableNg = true;
  };

  # Configure SSH Globally
  services.openssh = {
    enable = true;
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    #settings.PermitRootLogin = "yes";
  };

  security.polkit.enable = true;

  users.users = lib.genAttrs usernames
    (username:
      let
        account = accountFromUsername username;
      in
      {
        description = account.realname;
        isNormalUser = true;
        # password = "demo";
        hashedPassword = account.hashedPassword;
        extraGroups = (if account.trusted then [ "wheel" "dialout" ] else [ ]);
      }
    );
  users.mutableUsers = false;
  networking.domain = lib.mkDefault "lan";
}