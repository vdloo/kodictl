#!/usr/bin/env racket
#lang racket/base
(require json-rpc-client)

(require "../attempt.rkt")

(provide kodictl-mute)
(provide kodictl-volumedown)
(provide kodictl-volumeup)


(define kodictl-input-action
  (λ (action)
    (json-rpc-client
      (getenv "KODI_HOST")
      (forge-payload 
        "Input.ExecuteAction"
        #:params (hasheq 
	  'action action)))))

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

