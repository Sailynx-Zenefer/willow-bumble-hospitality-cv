{
  description = "Build a willow_bumble_foh_cv with markdown";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgs = import nixpkgs {
          inherit system;
          config = {
            permittedInsecurePackages = [ "openssl-1.1.1w" ];
          };
        };

        buildInputs = with pkgs; [
          pandoc
          wkhtmltopdf-bin
        ];

        buildPhase = ''
          pandoc willow_bumble_foh_cv.md \
          -t html -f markdown \
          -c style.css --self-contained \
          -o willow_bumble_foh_cv.html

          wkhtmltopdf --enable-local-file-access \
          willow_bumble_foh_cv.html \
          willow_bumble_foh_cv.pdf
        '';

      in with pkgs; {

        packages = {
          default = stdenvNoCC.mkDerivation {
            inherit buildInputs buildPhase;
            name = "willow_bumble_foh_cv_md";
            src = ./.;
            installPhase = ''
              mkdir -p $out/willow_bumble_foh_cv
              cp willow_bumble_foh_cv.* $out/willow_bumble_foh_cv/
            '';
          };
        };

        checks = {
          default = stdenvNoCC.mkDerivation {
            inherit buildInputs buildPhase;
            name = "willow_bumble_foh_cv-md checks";
            src = ./.;
            installPhase = ''
              mkdir -p $out
            '';
          };
        };

        devShell = mkShell {
          inherit buildInputs;
        };
      });
}

