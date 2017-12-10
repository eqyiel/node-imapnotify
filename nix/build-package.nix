{ nixpkgs ? <nixpkgs>, system ? builtins.currentSystem }:

let
  nixosUnstable = import (import ./nixos-unstable.nix {
    inherit nixpkgs system;
  }) {
    inherit system;
    overlays = [(import ./yarn2nix-overlay.nix)];
  };
in (nixosUnstable.callPackage ./.. {})
