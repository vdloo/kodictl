#!/usr/bin/env racket
#lang racket
(require json)

(provide kodictl-evaluate-command-or-api-call)

(require "utils.rkt")
(require "action.rkt")
(require "commands/main.rkt")

(define kodictl-list-commands
  (λ ()
    (for-each 
      (λ (cmd) (printf "~a : ~a\n" cmd (cdr (dict-ref commands cmd)))) 
      (hash-keys commands))))

(define commands
  (hasheq 
    'help (cons kodictl-list-commands 
		"list available commands")
    'list (cons kodi-json-rpc-list-actions 
		"list all JSON-RPC actions and descriptions")
    'nowplaying (cons kodictl-nowplaying 
		      "output label of currently playing item")
    'playpause (cons kodictl-playpause 
		     "pause if playing, play if paused")
    'previous (cons kodictl-next 
		    "play previous on all active players")
    'next (cons kodictl-next 
		"play next on all active players")
    'shuffle (cons kodictl-partymode
		   "partymode")
    'stop (cons kodictl-stop 
		"stop all active players")))

(define kodictl-evaluate-command-or-api-call
  (λ (args)
     (let 
       ([cmd (car args)]
	[params (cdr args)])
       (if (dict-has-key? commands (string->symbol cmd))
         (apply (car (dict-get commands cmd)) params)
	 (apply kodi-json-rpc-action-and-exit args)))))
