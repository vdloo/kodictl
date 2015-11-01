#!/usr/bin/env racket
#lang racket/base
(require racket/cmdline)

(provide parse-args)

(define kodi-host (make-parameter "localhost"))
(define kodi-port (make-parameter 80))
(define kodi-json-rpc-path (make-parameter "/jsonrpc"))

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
      (entrypoint args kodi-host kodi-port kodi-json-rpc-path))))
