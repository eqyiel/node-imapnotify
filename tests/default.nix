{ yarn2nix }:

with yarn2nix; mkYarnPackage {
  name = "imapnotify-tests";
  src = ./.;
  packageJson = ./package.json;
  yarnLock = ./yarn.lock;
}
