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
        packages.templates = pkgs.buildNpmPackage {
          name = "breathtaking-comics-templates";
          nativeBuildInputs = with pkgs; [ nodejs_22 ];
          src = self;
          npmDepsHash = "sha256-6fpW4yb2b0RQvMPgSm6KWhbKRl4+TZ9/TVmcPTyw1HA=";
          installPhase = ''
            mkdir $out
            cp -a *.tex $out/
          '';
        };
        packages.pandoc = pkgs.stdenvNoCC.mkDerivation {
          name = "breathtaking-comics-pandoc";
          nativeBuildInputs = [
            pkgs.pandoc
          ];
          src = self;
          dontBuild = true;
          installPhase = ''
            mkdir $out
            ls *.md | sed -e 's/\.md$//' | xargs -I @ pandoc -f markdown -t context -o $out/@.tex @.md
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
            cp -a ${self.packages.${system}.pandoc}/*.tex .
            ls -la
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
            pkgs.pandoc
          ];
        };
      }
    );
}
