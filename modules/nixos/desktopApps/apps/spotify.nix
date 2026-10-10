{ config, lib, pkgs, inputs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isx86_64 isAarch64;
  x86 = (import inputs.nixpkgs {
    system = "x86_64-linux";
    config = config.nixpkgs.config;
  });

  # patched spotify for arm64 Spotify inside a 4K-page microVM, emulated by FEX
  spotifyFex = pkgs.writeShellScriptBin "spotify-fex" ''
    exec ${pkgs.muvm}/bin/muvm -- ${x86.spotify}/bin/spotify \
      --disable-gpu \
      --disable-gpu-compositing \
      --no-sandbox \
      --disable-dev-shm-usage \
      --disable-crash-reporter --disable-breakpad \
      "$@"
  '';
in {
  boot.binfmt = lib.mkIf isAarch64 {
  registrations.FEX-x86_64 = {
    interpreter = "${pkgs.fex}/bin/FEXInterpreter";
    magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x3e\x00'';
    mask = ''\xff\xff\xff\xff\xff\xfe\xfe\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'';
    fixBinary = true;
    wrapInterpreterInShell = false;
  };
  };

  environment.systemPackages = if isx86_64 then [ pkgs.spotify ] else [ pkgs.muvm pkgs.fex spotifyFex ];
}
