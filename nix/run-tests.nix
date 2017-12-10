{ nixpkgs ? <nixpkgs>, system ? builtins.currentSystem }:

let
  nixpkgsLocal = import nixpkgs { inherit system; };

  nixosUnstableDerivation = (nixpkgsLocal.callPackage ./nixos-unstable.nix {});

  nixosConfig = {
    inherit system;
    overlays = [(import ./yarn2nix-overlay.nix)];
  };

  nixosUnstable = import nixosUnstableDerivation nixosConfig;
in (import "${nixosUnstableDerivation}/nixos/tests/make-test.nix"
  ({ pkgs, lib, ... }: let
    imapnotify = (nixosUnstable.callPackage ./.. {});

    imapnotify-tests = (nixosUnstable.callPackage ./../tests {});
  in {
    machine = { config, lib, pkgs, ... }: {
      imports = [
        (import ((import nixosUnstableDerivation nixosConfig).fetchFromGitHub {
          owner = "r-raymond";
          repo = "nixos-mailserver";
          rev = "refs/tags/v2.0.2";
          sha256 = "117w8da5qk1rchdy6lzx3galw1hks4fpdxz6bglv5may44cz1rqf";
        }) { inherit config lib pkgs; })
      ];

      networking.extraHosts = ''
        127.0.0.1 example.com
        127.0.0.1 mail.example.com
      '';

      mailserver = {
        enable = true;
        fqdn = "mail.example.com";
        domains = [ "example.com" ];

        loginAccounts = {
          "sender@example.com" = {
            hashedPassword = "$6$FGd4XgUPtLdPduXV$OgiyP4DOwo6skYjqgu2oYRwqnYl0ZbiwwWl9/SgPm118aKSWR/xeixM/pwTCN8yc92VKuFtx4cPxaXlOT6umF1";
          };

          "recipient@example.com" = {
            hashedPassword = "$6$FGd4XgUPtLdPduXV$OgiyP4DOwo6skYjqgu2oYRwqnYl0ZbiwwWl9/SgPm118aKSWR/xeixM/pwTCN8yc92VKuFtx4cPxaXlOT6umF1";
          };
        };
      };

      environment.systemPackages = (import ./make-build-inputs.nix {
        inherit (nixosUnstable) pkgs;
      });
    };

      testScript = let
        run-tests = pkgs.writeScript "run-tests" ''
          #!${pkgs.stdenv.shell}

          set -euo pipefail

          export IMAPNOTIFY_COMMAND="${imapnotify}/bin/imapnotify"
          export SENDMAIL_COMMAND="/run/wrappers/bin/sendmail"
          export NODE_PATH="${imapnotify-tests}/node_modules"
          cd ${../tests}
          eval "${imapnotify-tests}/node_modules/jest-cli/bin/jest.js" \
            --no-cache | ${pkgs.utillinuxMinimal}/bin/logger;
        '';
      in ''
      $machine->start;
      $machine->waitForUnit("multi-user.target");
      $machine->succeed("${run-tests}")
    '';
    }
  )
) nixosUnstable
