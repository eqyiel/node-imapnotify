{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "yarn2nix-${version}";
  version = "2017-12-11";

  src = fetchFromGitHub {
    owner = "moretea";
    repo = "yarn2nix";
    rev = "1a77b8db34f6b9e7bc879afe0bb722081c5ffabc";
    sha256 = "1n46dvh1g83kp8qk3c8bw69p6729q44ms1dqnxy8d208pigqxgq6";
  };

  dontBuild = true;
  preferLocalBuild = true;

  installPhase = ''
    cp -a . $out
  '';
}
