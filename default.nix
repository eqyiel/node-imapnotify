{ yarn2nix }:

with yarn2nix; mkYarnPackage {
  name = "imapnotify";
  src = ./.;
  packageJson = ./package.json;
  yarnLock = ./yarn.lock;
}
