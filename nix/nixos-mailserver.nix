{ nixpkgs ? <nixpkgs>, system ? builtins.currentSystem }:

with (import nixpkgs { inherit system; }); (pkgs.stdenv.mkDerivation rec {
  name = "nixos-mailserver-${version}";
  version = "2017-12-10";

  src = pkgs.fetchFromGitHub {
    owner = "r-raymond";
    repo = "nixos-mailserver";
    rev = "5068fd1fbd428f3ae59bf2b1bcd775cc85dcc198";
    sha256 = "1bcgf354j6w6da2spwij12nzby4p4ry2kj6mankdjmk8yacxiqnx";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
})
