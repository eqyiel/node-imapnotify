{ nixpkgs ? <nixpkgs>, system ? builtins.currentSystem }:

let

  nixpkgsLocal = import nixpkgs { inherit system; };

  nixpkgsUnstable = with nixpkgsLocal.pkgs; callPackage (stdenv.mkDerivation rec {
    name = "nixpkgs-unstable-${version}";
    version = "2017-12-07";

    src = fetchFromGitHub {
      owner = "NixOS";
      repo = "nixpkgs-channels";
      rev = "a88146d308fb5fa8e3cc466fffecaf0fe9ff9a2e";
      sha256 = "0siy03n2kc34axxh34x8bpqiwz0nzklyl5zxc951jks9gwb85j8v";
    };

    dontBuild = true;
    preferLocalBuild = true;

    installPhase = ''
      cp -a . $out
    '';
  }) {};

in with nixpkgsUnstable.pkgs; stdenv.mkDerivation rec {
  name = "node-imapnotify-env";
  env = buildEnv { name = name; paths = buildInputs; };
  buildInputs = with pkgs; [
    nodejs-6_x
    flow
  ] ++ (with nodePackages_6_x; [
    yarn
  ]);
  shellHook = ''
    echo ✨ environment ready!
  '';
}
