#!/usr/bin/env racket
#lang racket/base
(require racket/cmdline)

(provide parse-args)

(define env-if-not-defined
  (λ (value)
    (λ (key)
       (if (not (getenv key))
         (putenv key value)
	 #f))))

(define kodi-host 
  (env-if-not-defined "kodi-host"))
(define kodi-port 
  (env-if-not-defined "kodi-port"))
(define kodi-json-rpc-path
  (env-if-not-defined "kodi-json-rpc-path"))

(define parse-args 
  (λ (entrypoint)
    (command-line
      #:program "kodictl"
      #:once-each
      [("-r" "--remote") host "Specify Kodi host" (kodi-host host)]
      [("-p" "--port") port "Specify Kodi port" (kodi-port 
  					          (string->number port))]
      [("-j" "--json-rpc-path") path "Specify Kodi JSON_RPC path" 
  			       (kodi-json-rpc-path path)]
      #:usage-help "\nCommand line client for Kodi's JSON-RPC API"
      #:ps "\nTo see all available kodictl commands run $ kodictl help"
       "\nExecute JSON-RPC actions from the commandline"
       "examples: "
       "$ kodictl AudioLibrary.scan"
       "$ kodictl Player.Playpause playerid 0"
      #:args args
      (begin
	(kodi-host "localhost")
	(kodi-port "80")
	(kodi-json-rpc-path "/jsonrpc")
	(entrypoint args kodi-host kodi-port kodi-json-rpc-path)))))
