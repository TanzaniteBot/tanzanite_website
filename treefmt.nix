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
{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  settings.global.excludes = [
    "COPYING"
    ".envrc"
    ".ocamlformat"
    "*.opam"
  ];
  programs = {
    deadnix.enable = true;
    nixfmt.enable = true;
    ocamlformat.enable = true;
    jsonfmt.enable = true;
    mdformat.enable = true;
  };
  settings.formatter = {
    "dune-file" = {
      command = "${pkgs.bash}/bin/bash";
      options = [
        "-euc"
        ''
          for file in "$@"; do
            tmp_file=$(mktemp)
            ${pkgs.dune_3}/bin/dune format-dune-file $file > $tmp_file
            mv $tmp_file $file
          done
        ''
        "--"
      ];
      includes = [
        "dune-project"
        "**/dune"
      ];
    };
    "refmt" = {
      command = "${pkgs.ocamlPackages.reason}/bin/refmt";
      options = [
        "--in-place"
      ];
      includes = [
        "*.re"
      ];
    };
  };
}
