#!/usr/bin/env racket
#lang racket/base
(require json)

(require "../action.rkt")
(require "../utils.rkt")
(require "active-players.rkt")

(provide kodictl-nowplaying)

(define kodi-json-rpc-nowplaying
  (λ ()
     (kodi-json-rpc-map-active-players
       (λ (playerid) 
	  (dict-get
	    (dict-get 
	      (dict-get 
		(cdr 
		  (kodi-json-rpc-action "Player.GetItem" "playerid" 
					(number->string playerid))) 
		"result") 
	      "item") 
	    "label")))))

(define kodictl-nowplaying
  (λ ()
     (for-each
       (λ (item) (printf "~a\n" item))
       (kodi-json-rpc-nowplaying))))
