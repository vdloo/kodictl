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
(define set-kodi-port 
  (env-if-not-defined "KODI_PORT"))
(define set-kodi-json-rpc-path
  (env-if-not-defined "KODI_JSON_RPC_PATH"))

(define parse-args 
  (λ (entrypoint)
    (command-line
      #:program "kodictl"
      #:once-each
      [("-r" "--remote") host "Specify Kodi host" (set-kodi-host host)]
      [("-p" "--port") port "Specify Kodi port" (set-kodi-port port)]
      [("-j" "--json-rpc-path") path "Specify Kodi JSON_RPC path" 
  			       (set-kodi-json-rpc-path path)]
      #:usage-help "\nCommand line client for Kodi's JSON-RPC API"
      #:ps "\nTo see all available kodictl commands run $ kodictl help"
       "\nExecute JSON-RPC actions from the commandline"
       "examples: "
       "$ kodictl AudioLibrary.scan"
       "$ kodictl Player.Playpause playerid 0"
      #:args args
      (begin
	(set-kodi-host "localhost")
	(set-kodi-port "80")
	(set-kodi-json-rpc-path "/jsonrpc")
	(entrypoint args)))))
