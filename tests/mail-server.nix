{ nixpkgs ? <nixpkgs>, system ? builtins.currentSystem }:

let
  nixosUnstableDerivation = (import ../nix/nixos-unstable.nix {
    inherit nixpkgs system;
  });

  nixosUnstable = import nixosUnstableDerivation { inherit system; };
in (import "${nixosUnstableDerivation}/nixos/tests/make-test.nix" ({ pkgs, lib, ... }: {
  machine =
    let
      nixos-mailserver = import ../nix/nixos-mailserver.nix {};

      imapnotify-config = (builtins.toJSON {
        host = "mail.example.com";
        port = 993;
        tls = true;
        tlsOptions = { rejectUnauthorized = true; };
        user = "recipient@example.com";
        passwordCommand = "echo hunter2";
        onNotify = "echo got new mail";
        onNotifyPost = "echo OK";
        onSIGTERMpost = "echo 'Bye-Bye'";
        onSIGINTpost = "echo 'Bye-Bye'";
        boxes = ["Inbox"];
      });


    in { config, pkgs, ... }: {
        imports = [ "${nixos-mailserver}/default.nix" ];

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

        environment.systemPackages = with pkgs; [
          msmtp
          (import ./.. { nixpkgs = nixosUnstable; })
        ];
      };

  testScript =
    let
      inherit (nixosUnstable) pkgs;

      msmtprc = pkgs.writeText "msmtprc" ''
        account        test-account
        host           mail.example.com
        port           587
        from           sender@example.com
        user           sender@example.com
        password       hunter2
      '';

      message = pkgs.writeText "message" ''
        From: Sender <sender@example.com>
        To: Recipient <recipient@example.com>
        Subject: This is a test email from sender@example.com to recipient@example.com

        Hello Recipient,

        How's it going?
      '';
    in ''
      $machine->start;
      $machine->waitForUnit("multi-user.target");
      subtest "recipient should receive a notification", sub {
        $machine->succeed("msmtp -C ${msmtprc} -a test-account --tls=on --tls-certcheck=off --auth=on recipient\@example.com < ${message} >&2");
      };

      subtest "imap retrieving mail 2", sub {
        $machine->succeed("sleep 5");
        # test that notification was received??
      };
    '';
})) nixosUnstable
