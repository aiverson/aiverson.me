{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.11";
    luvitPkgs = {
      url = "github:aiverson/luvit-nix";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, luvitPkgs }: {
    packages.x86_64-linux.aiverson-me =
      let pkgs = import nixpkgs {
            system = "x86_64-linux";
          };
          luvit = pkgs.callPackage(inputs.luvitPkgs) {};
          lib = pkgs.lib;
      in luvit.makeLitPackage {
        pname = "aiverson.me";
        version = "0.0.2";

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
