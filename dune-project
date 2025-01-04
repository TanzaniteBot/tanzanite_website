(lang dune 3.16)

(name tanzanite_website)

(generate_opam_files)

(opam_file_location inside_opam_directory)

(source
 (github TanzaniteBot/tanzanite_website))

(authors "IRONM00N")

(license AGPL-3.0)

(package
 (name tanzanite_website)
 (synopsis "Tanzanite Website")
 (description "A website for Tanzanite.") ; todo: expand description
 (depends ocaml dune dream)
 (tags
  (website dashboard)))

; https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
