#!/usr/bin/env racket
#lang racket/base
(require json-rpc-client)

(require "../attempt.rkt")
(require "active-players.rkt")

(provide kodictl-previous)
(provide kodictl-next)


(define kodictl-json-rpc-goto
  (λ (to)
     (kodi-json-rpc-map-active-players
       (λ (playerid)
	  (json-rpc-client
	    (getenv "KODI_HOST")
	    (forge-payload 
	      "Player.GoTo"
	      #:params (hasheq 
	       'playerid playerid
	       'to to)))))))

(define kodictl-previous
  (λ ()
     (kodictl-json-rpc-goto "previous")))

(define kodictl-next
  (λ ()
     (kodictl-json-rpc-goto "next")))
