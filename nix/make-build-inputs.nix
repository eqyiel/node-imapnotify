{ pkgs }:

with pkgs; [
  nodejs-6_x
  flow
  yarn2nix.yarn2nix
] ++ (with nodePackages_6_x; [
  yarn
])
