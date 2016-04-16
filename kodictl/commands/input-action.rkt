#!/usr/bin/env racket
#lang racket/base
(require json-rpc-client)

(require "../attempt.rkt")

(provide kodictl-input-action)


(define kodictl-input-action
  (λ (action)
    (json-rpc-client
      (getenv "KODI_HOST")
      (forge-payload 
        "Input.ExecuteAction"
        #:params (hasheq 
	  'action action)))))

