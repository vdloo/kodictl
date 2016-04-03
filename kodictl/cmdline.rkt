#!/usr/bin/env racket
#lang racket/base
(require racket/cmdline)

(provide parse-args)

(define env-if-not-defined
  (λ (key)
    (λ (value)
       (if (not (getenv key))
         (putenv key value)
	 #f))))

(define set-kodi-host 
  (env-if-not-defined "KODI_HOST"))

(define parse-args 
  (λ (entrypoint)
    (command-line
      #:program "kodictl"
      #:once-each
      [("-r" "--remote") host "Specify Kodi host. Like: http://localhost:8080/jsonrpc" 
			 (set-kodi-host host)]
      #:usage-help "\nCommand line client for Kodi's JSON-RPC API"
      #:ps "\nTo see all available kodictl commands run $ kodictl help"
       "\nExecute JSON-RPC actions from the commandline"
       "examples: "
       "$ kodictl AudioLibrary.scan"
       "$ kodictl Player.Playpause playerid 0"
      #:args args
      (begin
	(set-kodi-host "http://localhost:8080/jsonrpc")
	(entrypoint args)))))
