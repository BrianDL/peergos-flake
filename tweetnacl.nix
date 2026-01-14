{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "tweetnacl";
  version = "0-unstable-2020-02-12";

  src = pkgs.fetchFromGitHub {
    owner = "ianopolous";
    repo = "tweetnacl-java";
    rev = "6d1bde81ea63051750cda40422b62e478b85d2b0";
    hash = "sha256-BDWzDpUBi4UuvxFwA9ton+RtHOzDcWql1ti+cdvhzks=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail gcc cc
  '';

  makeFlags = [ "jni" ];

  nativeBuildInputs = [
    pkgs.openjdk8-bootstrap # javah
  ];

  installPhase = ''
    install -Dvm644 libtweetnacl.so $out/lib/libtweetnacl.so
  '';
}