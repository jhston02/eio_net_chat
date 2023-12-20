(lang dune 3.12)

(name eio_net_chat)

(generate_opam_files true)

(source
 (github jhston02/eio_net_chat))

(authors "jhston02")

(maintainers "Maintainer Name")

(license MIT)

(package
 (name eio_net_chat)
 (synopsis "Simple client server chat with eio")
 (description "A longer description")
 (depends ocaml dune eio_main cmdliner ipaddr ocolor alcotest qcheck)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
