#!/usr/bin/env racket
#lang racket
(require json)

(require "../action.rkt")
(require "active-players.rkt")

(provide kodictl-playpause)

; toggle play/pause on active players
(define kodi-json-rpc-playpause
  (λ ()
     (kodi-json-rpc-map-active-players 
       (λ (playerid) 
	  (kodi-json-rpc-action "Player.Playpause" "playerid" 
				(number->string playerid))))))

; playpause active players and blackhole output
(define kodictl-playpause
  (λ ()
     (for-each
       (λ (item) empty)
	  (kodi-json-rpc-playpause))))
