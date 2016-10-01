#!/usr/bin/env racket
#lang racket/base
(require json-rpc-client)

(require "../attempt.rkt")

(provide kodictl-notify)


(define kodictl-notify
  (λ arg
    (json-rpc-client
      (getenv "KODI_HOST")
      (forge-payload 
        "GUI.ShowNotification"
        #:params (hasheq 
         'title (car arg)
         'message (cadr arg))))))
