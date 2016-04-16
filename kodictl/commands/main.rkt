#!/usr/bin/env racket
#lang racket/base

(require "list-actions.rkt")
(require "active-players.rkt")
(require "nowplaying.rkt")
(require "stop.rkt")
(require "playpause.rkt")
(require "goto.rkt")
(require "partymode.rkt")
(require "volumechange.rkt")

(provide kodi-json-rpc-list-actions)
(provide kodi-json-rpc-map-active-players)
(provide kodictl-nowplaying)
(provide kodictl-stop)
(provide kodictl-playpause)
(provide kodictl-previous)
(provide kodictl-next)
(provide kodictl-partymode)
(provide kodictl-mute)
(provide kodictl-volumeup)
(provide kodictl-volumedown)
