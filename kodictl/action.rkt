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

(define kodi-json-rpc-permutations
  (λ (permutations options)
     (if (empty? permutations)
       #f
       (let
         ([output (kodi-json-rpc-dispatch (car permutations) options)])
         (if output 
   	   output 
           (kodi-json-rpc-permutations (cdr permutations) options))))))

(define kodi-json-rpc-get-signature
  (λ (permutations options)
     (printf "Can't make anything out of that command, sorry!\nTry $kodictl introspect for more information.\n")))

(define kodi-json-rpc-try-or-introspect
  (λ (permutations options) 
     (let ([output (kodi-json-rpc-permutations 
		     permutations
		     options)]) 
       (if output 
	 output 
	 (kodi-json-rpc-get-signature permutations options)))))

(define kodi-json-rpc-action
  (λ args (kodi-json-rpc-try-or-introspect 
	     (permutations args) 
	     (kodi-json-rpc-all-actions))))
