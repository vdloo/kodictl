#lang info
(define collection "kodictl")
(define deps '("base"
	       "srfi-lite-lib"
	       "https://github.com/vdloo/json-rpc-client.git"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/kodictl.scrbl" ())))
(define pkg-desc "Command-line interface for the Kodi JSON-RPC")
(define version "0.1")
(define pkg-authors '(vdloo))
