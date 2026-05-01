{ pkgs, lib, ... }:
{
 environment.systemPackages = with pkgs; [
   javaPackages.compiler.openjdk25
   prismlauncher
];
}
