#!/usr/bin/env racket
#lang racket/base
(require json)

(require "../attempt.rkt")
(require "active-players.rkt")

(provide kodictl-previous)
(provide kodictl-next)


(define kodictl-json-rpc-goto
  (λ (to)
     (kodi-json-rpc-map-active-players
       (λ (playerid)
	  (kodi-json-rpc-call 
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
