# Add derivations to be built from the cache to this file
{ system ? builtins.currentSystem }:
let
  pkgs = import ./nix { inherit system; };

  nixos-generators = toString pkgs.sources.nixos-generators;

  eval-nixos-generator = import "${nixos-generators}/nixos-generate.nix";

  eval-nixos = configuration: system:
    (import "${toString pkgs.path}/nixos") {
      inherit configuration system;
    };

  build-kexec = configuration: system:
    let
      x = eval-nixos-generator {
        formatConfig = "${toString pkgs.sources.nixos-generators}/formats/kexec.nix";
        inherit configuration system;
        nixpkgs = pkgs.path;
      };
    in
    x.config.system.build.kexec_bundle;

in
pkgs.nix-community-infra // rec {
  build01 = eval-nixos ./build01/configuration.nix "x86_64-linux";
  build01-kexec = build-kexec ./build01/configuration.nix "x86_64-linux";
  build01-system = build01.system;
  build02 = eval-nixos ./build02/configuration.nix "x86_64-linux";
  build02-system = build02.system;
  build03 = eval-nixos ./build02/configuration.nix "x86_64-linux";
  build03-system = build03.system;
}
