{ nixpkgs ? <nixpkgs>, system ? builtins.currentSystem }:

let

  nixpkgsLocal = import nixpkgs { inherit system; };

  nixpkgsUnstable = import (nixpkgsLocal.callPackage ./nix/nixos-unstable.nix {}) {
    inherit system;
    overlays = [(import ./nix/yarn2nix-overlay.nix)];
  };

in with nixpkgsUnstable; stdenv.mkDerivation rec {
  name = "node-imapnotify-env";
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = (import ./nix/make-build-inputs.nix { inherit pkgs; });
  shellHook = ''
    echo ✨ environment ready!
  '';
}
