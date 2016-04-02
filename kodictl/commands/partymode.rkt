#!/usr/bin/env racket
#lang racket
(require json)

(require "../action.rkt")
(require "active-players.rkt")

(provide kodictl-partymode)

; shuffle music
(define kodictl-partymode
  (λ ()
     (kodi-json-rpc-action-and-exit "Player.Open" "item" "partymode" "music")))
