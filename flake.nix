{
  description = "A tabletop roleplaying game published on itch.io";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.nodemodules = pkgs.buildNpmPackage {
          name = "breathtaking-comics-nodemodules";
          nativeBuildInputs = with pkgs; [ nodejs_22 ];
          src = nixpkgs.lib.sources.sourceByRegex self ["^package(|-lock)\.json$"];
          npmDepsHash = "sha256-6fpW4yb2b0RQvMPgSm6KWhbKRl4+TZ9/TVmcPTyw1HA=";
          installPhase = ''
            mkdir $out
            cp -a node_modules/. $out/
          '';
        };
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          name = "breathtaking-comics-pdf";
          nativeBuildInputs = [
            pkgs.nodejs_22
            pkgs.texliveConTeXt
          ];
          src = self;
          buildPhase = ''
            cp -a ${self.packages.${system}.nodemodules}/. node_modules/
            export OSFONTDIR=$PWD/fonts
            mtxrun --generate
            mtxrun --script fonts --reload
            context breathtaking-comics.tex --purgeall
          '';
          installPhase = ''
            mkdir $out
            cp breathtaking-comics.pdf $out/
          '';
        };
        devShell = pkgs.mkShell {
          name = "breathtaking-comics";
          packages = [
            pkgs.nodejs_22
            pkgs.texliveConTeXt
          ];
        };
      }
    );
}
