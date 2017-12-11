{ nixpkgs ? <nixpkgs>, system ? builtins.currentSystem }:

with (import nixpkgs { inherit system; }); stdenv.mkDerivation rec {
  name = "nixos-unstable-${version}";
  version = "2017-12-11";

  # nix-prefetch-git git@github.com:NixOS/nixpkgs-channels.git --rev refs/heads/nixos-unstable
  src = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "3eccd0b11d176489d69c778f2fcb544438f3ab56";
    sha256 = "1i3p5m0pnn86lzni5y1win0sacckw3wlg9kqaw15nszhykgz22zq";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
