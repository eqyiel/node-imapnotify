self: super: {
  yarn2nix = with super.pkgs; import (super.callPackage ./yarn2nix.nix {}) ({
    pkgs = super.pkgs;
    nodejs = super.pkgs.nodejs-6_x;
    yarn = super.pkgs.nodePackages_6_x.yarn;
  });
}
