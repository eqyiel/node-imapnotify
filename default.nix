{ nixpkgs ? (import <nixpkgs> {}), system ? builtins.currentSystem }:

with (import (import ./nix/yarn2nix.nix {}) rec {
  pkgs = nixpkgs;
  nodejs = nixpkgs.nodejs-6_x;
  yarn = nixpkgs.nodePackages_6_x.yarn;
}); mkYarnPackage {
  name = "imapnotify";
  src = ./.;
  packageJson = ./package.json;
  yarnLock = ./yarn.lock;
}
