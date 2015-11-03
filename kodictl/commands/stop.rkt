#!/usr/bin/env racket
#lang racket
(require json)

(require "../action.rkt")
(require "active-players.rkt")

(provide kodictl-stop)

; stop all active players
(define kodi-json-rpc-stop
  (λ ()
     (kodi-json-rpc-map-active-players
       (λ (playerid) 
	  (kodi-json-rpc-action "Player.Stop" "playerid" 
				(number->string playerid))))))

; stop active  players and blackhole output
(define kodictl-stop
  (λ ()
     (for-each
       (λ (item) empty)
	  (kodi-json-rpc-stop))))
