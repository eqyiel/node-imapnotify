import <nixpkgs/nixos/tests/make-test.nix> {
  machine =
    let
      inherit (import <nixpkgs> {}) pkgs;

      nixos-mailserver = (pkgs.stdenv.mkDerivation rec {
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
      });

      msmtprc = ''
        account        test-account
        host           mail.example.com
        port           587
        from           sender@example.com
        user           sender@example.com
        password       hunter2
      '';

      message = ''
        From: Sender <sender@example.com>
        To: Recipient <recipient@example.com>
        Subject: This is a test email from sender@example.com to recipient@example.com

        Hello Recipient,

        How's it going?
      '';

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
        imports = [ ("${nixos-mailserver}/default.nix") ];

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

        environment.systemPackages = with pkgs; [ msmtp ];
      };

      testScript = ''
        $machine->start;
        $machine->waitForUnit("multi-user.target");
        subtest "recipient should receive a notification", sub {
          $client->succeed("echo '${msmtprc}' > ~/.msmtprc");
          $client->succeed("echo '${message}' > mail.txt");
          $client->succeed("msmtp -a test --tls=on --tls-certcheck=off --auth=on sender\@example.com < mail.txt >&2");
        };

        subtest "imap retrieving mail 2", sub {
          $client->succeed("sleep 5");
          # test that notification was received??
        };
      '';
    }
