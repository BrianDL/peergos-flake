{
  description = "PeerGOS - P2P, secure file storage, social network and application protocol";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        tweetnacl = import ./tweetnacl.nix { inherit pkgs; };

        peergos = pkgs.stdenv.mkDerivation rec {
          pname = "peergos";
          version = "1.16.0";
          
          src = pkgs.fetchFromGitHub {
            owner = "Peergos";
            repo = "web-ui";
            rev = "v${version}";
            hash = "sha256-v8Pw9AlxFDu4DqYeJlx+xF2PJe1xnQxHUVccXCn/jIs=";
            fetchSubmodules = true;
          };

          nativeBuildInputs = [
            pkgs.ant
            pkgs.jdk
            pkgs.stripJavaArchivesHook
            pkgs.makeWrapper
          ];

          postPatch = ''
            substituteInPlace build.xml \
              --replace-fail '${"\${repository.version}"}' '${version}'
          '';

          buildPhase = ''
            runHook preBuild
            ant dist
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall

            install -Dvm644 server/Peergos.jar $out/share/java/peergos.jar
            install -Dvm644 ${tweetnacl}/lib/libtweetnacl.so $out/native-lib/libtweetnacl.so

            makeWrapper ${pkgs.lib.getExe pkgs.jre} $out/bin/peergos \
              --chdir $out \
              --add-flags "-Djava.library.path=native-lib -jar $out/share/java/peergos.jar"

            runHook postInstall
          '';

          passthru.updateScript = pkgs.nix-update-script { };

          meta = {
            changelog = "https://github.com/Peergos/web-ui/releases/tag/v${version}";
            description = "P2P, secure file storage, social network and application protocol";
            downloadPage = "https://github.com/Peergos/web-ui";
            homepage = "https://peergos.org/";
            license = [
              pkgs.lib.licenses.agpl3Only # server
              pkgs.lib.licenses.gpl3Only # web-ui
            ];
            mainProgram = "peergos";
            maintainers = with pkgs.lib.maintainers; [
              raspher
              christoph-heiss
            ];
            platforms = pkgs.lib.platforms.all;
          };
        };

      in
      {
        packages.default = peergos;
      }
    );
}