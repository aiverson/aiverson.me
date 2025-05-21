{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    luvitPkgs = {
      url = "github:aiverson/luvit-nix";
      #flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, luvitPkgs, flake-utils }: {
    packages.x86_64-linux.aiverson-me =
      let pkgs = import nixpkgs {
            system = "x86_64-linux";
          };
          #luvit = pkgs.callPackage(inputs.luvitPkgs) {};
          lib = pkgs.lib;
      in luvitPkgs.lib.x86_64-linux.makeLitPackage {
        pname = "aiverson.me";
        version = "0.0.2";
        litSha256 = "sha256-ku6Y95Uw3q6eTXQw4XlZq8TBAG1Vi36YuNVZRwDyOM8=";

        src = lib.sourceFilesBySuffices ./. [
          ".lua"
          ".html"
          ".c"
          ".h"
          ".t"
          ".js"
          ".css"
          ".png"
          ".dat"
        ];
      };
    # Specify the default package
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.aiverson-me;
  };
}
