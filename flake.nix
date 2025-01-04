/*
  Tanzanite Website - Copyright (C) 2025 ironmoon (me@ironmoon.dev)

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program. If not, see <https://www.gnu.org/licenses/>.
*/
# inspired by https://github.com/brendanzab/ocaml-flake-example
{
  description = "Tanzanite Discord Bot Website";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      systems,
    }:
    let
      project = "tanzanite_website";
      lib = nixpkgs.lib;
      eachSystem =
        f:
        nixpkgs.lib.genAttrs (import systems) (
          system:
          f (
            import nixpkgs {
              inherit system;
              overlays = (import ./flake-overlays.nix);
            }
          )
        );
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      packages = eachSystem (
        pkgs:
        let
          ocamlPackages = pkgs.ocamlPackages;
          buildDunePackage = ocamlPackages.buildDunePackage;
        in
        {
          default = self.packages.${pkgs.system}.${project};

          ${project} = buildDunePackage {
            pname = "tanzanite_website";
            version = "0.1.0";
            src = ./.;

            buildInputs = [
              ocamlPackages.dream
            ];
          };
        }
      );

      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = eachSystem (
        pkgs:
        let
          ocamlPackages = pkgs.ocamlPackages;
        in
        {
          ${project} =
            let
              patchDuneCommand =
                let
                  subcmds = [
                    "build"
                    "test"
                    "runtest"
                    "install"
                  ];
                in
                lib.replaceStrings (lib.lists.map (subcmd: "dune ${subcmd}") subcmds) (
                  lib.lists.map (subcmd: "dune ${subcmd} --display=short") subcmds
                );
            in

            self.packages.${pkgs.system}.${project}.overrideAttrs (oldAttrs: {
              name = "check-${oldAttrs.name}";
              doCheck = true;
              buildPhase = patchDuneCommand oldAttrs.buildPhase;
              checkPhase = patchDuneCommand oldAttrs.checkPhase;
              # installPhase = patchDuneCommand oldAttrs.checkPhase;
            });

          dune-doc =
            pkgs.runCommand "check-dune-doc"
              {
                ODOC_WARN_ERROR = "true";
                nativeBuildInputs = [
                  ocamlPackages.dune_3
                  ocamlPackages.ocaml
                  ocamlPackages.odoc
                ];
              }
              ''
                echo "checking ocaml documentation"
                dune build \
                  --display=short \
                  --no-print-directory \
                  --root="${./.}" \
                  --build-dir="$(pwd)/_build" \
                  @doc
                touch $out
              '';

          formatting = treefmtEval.${pkgs.system}.config.build.check self;
        }
      );

      devShells = eachSystem (
        pkgs:
        let
          ocamlPackages = pkgs.ocamlPackages;
        in
        {
          default = pkgs.mkShell {
            packages = [
              treefmtEval.${pkgs.system}.config.build.wrapper
              pkgs.fswatch
              ocamlPackages.ocamlformat
              ocamlPackages.merlin
              ocamlPackages.odoc
              ocamlPackages.ocaml-lsp
              ocamlPackages.utop
            ];

            inputsFrom = [
              self.packages.${pkgs.system}.${project}
            ];
          };
        }
      );
    };
}
