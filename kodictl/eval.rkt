#!/usr/bin/env racket
#lang racket
(require racket/pretty)
(require json)

(provide kodictl-evaluate-command-or-api-call)

(require "utils.rkt")
(require "action.rkt")
(require "commands/main.rkt")

; stop all active players
(define kodi-json-rpc-stop
  (λ ()
     (kodi-json-rpc-map-active-players
       (λ (playerid) 
	  (kodi-json-rpc-action "Player.Stop" "playerid" 
				(number->string playerid))))))

; toggle play/pause on active players
(define kodi-json-rpc-playpause
  (λ ()
     (kodi-json-rpc-map-active-players 
       (λ (playerid) 
	  (kodi-json-rpc-action "Player.Playpause" "playerid" 
				(number->string playerid))))))

(define kodi-json-rpc-nowplaying
  (λ ()
     (kodi-json-rpc-map-active-players
       (λ (playerid) 
	  (dict-get
	    (dict-get 
	      (dict-get 
		(string->jsexpr 
		  (kodi-json-rpc-action "Player.GetItem" "playerid" 
					(number->string playerid))) 
		"result") 
	      "item") 
	    "label")))))

; stop active  players and blackhole output
(define kodictl-stop
  (λ ()
     (for-each
       (λ (item) empty)
	  (kodi-json-rpc-stop))))

; playpause active players and blackhole output
(define kodictl-playpause
  (λ ()
     (for-each
       (λ (item) empty)
	  (kodi-json-rpc-playpause))))

(define kodictl-nowplaying
  (λ ()
     (for-each
       (λ (item) (printf "~a\n" item))
       (kodi-json-rpc-nowplaying))))

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
    'stop (cons kodictl-stop 
		"stop all active players")))

(define kodictl-evaluate-command-or-api-call
  (λ (args)
     (let 
       ([cmd (car args)]
	[params (cdr args)])
       (if (dict-has-key? commands (string->symbol cmd))
         (apply (car (dict-get commands cmd)) params)
	 (apply kodi-json-rpc-action args)))))
