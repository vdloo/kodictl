#!/usr/bin/env racket
#lang racket/base
(require json-rpc-client)

(require "input-action.rkt")

(provide kodictl-mute)
(provide kodictl-volumedown)
(provide kodictl-volumeup)


(define kodictl-mute
  (λ ()
     (kodictl-input-action "mute")))

(define do-n-times
  (λ (n thunk)
     (for/list ([_ n])
       (thunk))
     (displayln (format "changed by ~a" n))))

(define kodictl-volumedown
  (λ ()
     (do-n-times 
       10 
       (λ () (kodictl-input-action "volumedown")))))

(define kodictl-volumeup
  (λ ()
     (do-n-times 
       10 
       (λ () (kodictl-input-action "volumeup")))))

