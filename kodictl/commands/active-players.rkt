#!/usr/bin/env racket
#lang racket/base
(require json)

(require "../action.rkt")
(require "../utils.rkt")

(provide kodi-json-rpc-map-active-players)

(define kodi-json-rpc-getactiveplayers
  (λ ()
     (kodi-json-rpc-action "Player.GetActivePlayers")))

(define kodi-json-rpc-list-of-player-ids
  (λ ()
     (map (λ (player) (dict-get player "playerid"))
	  (dict-get (string->jsexpr (kodi-json-rpc-getactiveplayers))
		    "result"))))

(define kodi-json-rpc-map-active-players
  (λ (proc)
     (map (λ (playerid) (proc playerid))
	  (kodi-json-rpc-list-of-player-ids))))

