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
[
  (
    self: super:
    let
      dreamSrc = self.fetchFromGitHub {
        owner = "aantron";
        repo = "dream";
        rev = "1.0.0-alpha8";
        hash = "sha256-AJBszLOUVwCXDqryNUkak4UlbmofCkxBIPEm4M0nHEI=";
      };
      multipart_formSrc = self.fetchFromGitHub {
        owner = "dinosaure";
        repo = "multipart_form";
        rev = "v0.6.0";
        hash = "sha256-aW8TOnzzJmuqN4ddUgoLbX8FefBC3nkPXiLn11C7QCs=";
      };
      httpunVer = "0.1.0";
      httpunSrc = self.fetchFromGitHub {
        owner = "anmonteiro";
        repo = "httpun";
        rev = httpunVer;
        hash = "sha256-Sig6+EkMcoHeP4Z+qR0H9khwErX080etoNlI0Bs7+Fk=";
      };
    in
    {
      ocamlPackages = super.ocamlPackages.overrideScope (
        f: p: {
          h2 = p.h2.overrideAttrs (o: rec {
            version = "0.12.0";
            src = self.fetchFromGitHub {
              owner = "anmonteiro";
              repo = "ocaml-h2";
              rev = "0.12.0";
              hash = "sha256-BkivG6p2c+cUoJn8XsxM17NO9plkaEYa4FyogFkBfV4=";
            };
            name = "ocaml${p.ocaml.version}-${o.pname}-${version}";
          });
          httpun-types = p.buildDunePackage {
            pname = "httpun-types";
            version = httpunVer;
            src = httpunSrc;
            propagatedBuildInputs = with f; [
              faraday
            ];
          };
          httpun = p.buildDunePackage {
            pname = "httpun";
            version = httpunVer;
            src = httpunSrc;
            propagatedBuildInputs = with f; [
              httpun-types
              bigstringaf
              angstrom
              faraday
            ];
          };
          httpun-lwt = p.buildDunePackage {
            pname = "httpun-lwt";
            version = httpunVer;
            src = httpunSrc;
            propagatedBuildInputs = with f; [
              gluten-lwt
              httpun
              lwt
            ];
          };
          httpun-lwt-unix = p.buildDunePackage {
            pname = "httpun-lwt-unix";
            version = httpunVer;
            src = httpunSrc;
            propagatedBuildInputs = with f; [
              gluten-lwt-unix
              httpun-lwt
              httpun
            ];
          };
          multipart_form = p.buildDunePackage {
            pname = "multipart_form";
            version = "0.6.0";
            src = multipart_formSrc;
            propagatedBuildInputs = with f; [
              bigstringaf
              logs
              prettym
              uutf
              base64
              ke
              fmt
              pecu
              unstrctrd
              angstrom
            ];
          };
          multipart_form-lwt = p.buildDunePackage {
            pname = "multipart_form-lwt";
            version = "0.6.0";
            src = multipart_formSrc;
            propagatedBuildInputs = with f; [
              multipart_form
              ke
              angstrom
              bigstringaf
              lwt
            ];
          };
          dream-pure = p.buildDunePackage {
            pname = "dream-pure";
            version = "1.0.0~alpha8";
            src = dreamSrc;
            propagatedBuildInputs = with f; [
              base64
              bigstringaf
              hmap
              lwt
              lwt_ppx
              ptime
              uri
            ];
          };
          dream-httpaf = p.buildDunePackage {
            pname = "dream-httpaf";
            version = "1.0.0~alpha8";
            src = dreamSrc;
            propagatedBuildInputs = with f; [
              dream-pure
              gluten
              gluten-lwt-unix
              h2
              h2-lwt-unix
              httpun
              httpun-lwt
              httpun-lwt-unix
              httpun-ws
              lwt
              lwt_ppx
              lwt_ssl
              ssl
            ];
          };
          dream = p.buildDunePackage {
            pname = "dream";
            version = "1.0.0~alpha8";
            src = dreamSrc;
            propagatedBuildInputs = with f; [
              base
              bigarray-compat
              camlp-streams
              caqti
              caqti-lwt
              cstruct
              digestif
              dream-httpaf
              dream-pure
              fmt
              graphql_parser
              graphql-lwt
              lambdasoup
              lwt
              lwt_ppx
              lwt_ssl
              logs
              magic-mime
              markup
              mirage-clock
              mirage-crypto
              mirage-crypto-rng
              mirage-crypto-rng-lwt
              multipart_form
              multipart_form-lwt
              ptime
              ssl
              uri
            ];
          };
          tyxml-syntax = p.buildDunePackage {
            pname = "tyxml-syntax";
            inherit (p.tyxml) version src;
            propagatedBuildInputs =
              with f;
              p.tyxml.propagatedBuildInputs
              ++ [
                ppxlib
              ];
          };
          tyxml-jsx = p.buildDunePackage {
            pname = "tyxml-jsx";
            inherit (p.tyxml) version src;
            propagatedBuildInputs = with f; [
              tyxml
              tyxml-syntax
              ppxlib
            ];
          };
          # dev env
          merlin = p.merlin.overrideAttrs (o: rec {
            version = "5.3-502";
            src = self.fetchurl {
              url = "https://github.com/ocaml/merlin/releases/download/v${version}/merlin-${version}.tbz";
              sha256 = "sha256-LOpG8SOX+m4x7wwNT14Rwc/ZFu5JQgaUAFyV67OqJLw=";
            };
            name = "ocaml${p.ocaml.version}-${o.pname}-${version}";
          });
          jsonrpc = p.jsonrpc.overrideAttrs (o: rec {
            version = "1.20.1";
            src = self.fetchurl {
              url = "https://github.com/ocaml/ocaml-lsp/releases/download/${version}/lsp-${version}.tbz";
              sha256 = "sha256-J+5UOJpGcBASphLczR9vKf81PjSMe6beD+43dn26OSE=";
            };
            name = "ocaml${p.ocaml.version}-${o.pname}-${version}";
          });
          lsp = p.lsp.overrideAttrs (o: rec {
            inherit (p.jsonrpc) version src;
            name = "ocaml${p.ocaml.version}-${o.pname}-${version}";
          });
          ocaml-lsp = p.ocaml-lsp.overrideAttrs (o: rec {
            inherit (p.lsp) version src preBuild;
            name = "ocaml${p.ocaml.version}-${o.pname}-${version}";
          });
        }
      );
    }
  )
]
