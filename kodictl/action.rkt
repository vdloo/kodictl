#!/usr/bin/env racket
#lang racket
(require json)
(require srfi/13)

(require "utils.rkt")
(require "attempt.rkt")
(require "commands/list-actions.rkt")

(provide kodi-json-rpc-action)

(define kodi-json-rpc-try-contains
  (λ (args options)
     (let
       ([option (string-downcase (symbol->string (car options)))])
       (if (empty? (cdr options))
	 #f
         (if (string-contains option (string-downcase (car args)))
	   (kodi-json-rpc-attempt (cons option (cdr args)))
	   (kodi-json-rpc-try-contains args (cdr options)))))))

(define kodi-json-rpc-try-equals
  (λ (args options)
     (if (dict-get options (car args))
       (kodi-json-rpc-attempt args)
       #f)))

(define kodi-json-rpc-dispatch
  (λ (args options)
     (let
       ([output (kodi-json-rpc-try-equals args options)])
       (if output 
	 output 
	 (kodi-json-rpc-try-contains args (hash-keys options))))))

(define kodi-json-rpc-action
  (λ args (kodi-json-rpc-dispatch args (kodi-json-rpc-all-actions))))
