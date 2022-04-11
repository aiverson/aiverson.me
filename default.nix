{ pkgs ? import <nixpkgs> { }, ... }:

with pkgs;

let
  luvitPkgs = callPackage (fetchFromGitHub {
    owner = "aiverson";
    repo = "luvit-nix";
    rev = "master";
    sha256 = "1wd7lbj4s4lni850hqlmnw88nwqby6fhznf0d4h43a1rfyd7kwk0";
    # date = 2020-05-11T23:22:42-05:00;
  }) { };

in with luvitPkgs;
makeLitPackage {
  pname = "aiverson.me";
  name = "aiverson.me-0.0.2";
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
}
