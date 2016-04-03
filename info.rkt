#lang info
(define collection "kodictl")
(define deps '("base"
               "rackunit-lib"
	       "json-rpc-client"))
(define build-deps '("scribble-lib" "racket-doc"))
(define scribblings '(("scribblings/kodictl.scrbl" ())))
(define pkg-desc "Command-line interface for the Kodi JSON-RPC")
(define version "0.1")
(define pkg-authors '(vdloo))
