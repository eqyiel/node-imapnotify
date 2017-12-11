{ nixpkgs ? <nixpkgs>, system ? builtins.currentSystem }:

let

  nixpkgsLocal = import nixpkgs { inherit system; };

  nixpkgsUnstable = import (import ./nix/nixpkgsUnstable.nix {
    inherit nixpkgs system;
  }) { inherit system; };

  yarn2nix = (import (import ./nix/yarn2nix.nix { inherit nixpkgs system; }) rec {
    pkgs = nixpkgsUnstable;
    nodejs = nixpkgsUnstable.nodejs-6_x;
    yarn = nixpkgsUnstable.nodePackages_6_x.yarn;
  });

in with nixpkgsUnstable; stdenv.mkDerivation rec {
  name = "node-imapnotify-env";
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = with pkgs; [
    nodejs-6_x
    flow
    yarn2nix.yarn2nix
  ] ++ (with nodePackages_6_x; [
    yarn
  ]);
  shellHook = ''
    echo ✨ environment ready!
  '';
}
