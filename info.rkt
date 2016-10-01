#lang info
(define collection "kodictl")
(define deps '("base"
	       "srfi-lite-lib"
	       "json-rpc-client"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/kodictl.scrbl" ())))
(define pkg-desc "Command-line interface for the Kodi JSON-RPC")
(define version "0.1")
(define pkg-authors '(vdloo))
