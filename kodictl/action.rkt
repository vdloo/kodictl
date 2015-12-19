#!/usr/bin/env racket
#lang racket
(require json)
(require srfi/13)

(require "utils.rkt")
(require "attempt.rkt")
(require "commands/list-actions.rkt")

(provide kodi-json-rpc-action)

(define kodi-json-rpc-try-contains
  (λ (args options match-procedure)
     (let
       ([option (string-downcase (symbol->string (car options)))])
       (if (empty? (cdr options))
	 #f
         (if (string-contains option (string-downcase (car args)))
	   (match-procedure (cons option (cdr args)))
	   (kodi-json-rpc-try-contains args (cdr options) match-procedure))))))

(define kodi-json-rpc-try-equals
  (λ (args options match-procedure)
     (if (dict-get options (car args))
       (match-procedure args)
       #f)))

(define kodi-json-rpc-try-permutations-until-success
  (λ (args options match-procedure)
     (let
       ([output (kodi-json-rpc-try-equals args options match-procedure)])
       (if output 
	 output 
	 (kodi-json-rpc-try-contains args (hash-keys options) match-procedure)))))

(define kodi-json-rpc-dispatch
  (λ (args options)
     (kodi-json-rpc-try-permutations-until-success args options kodi-json-rpc-attempt)))

(define kodi-json-rpc-data-from-introspect
  (λ (args)
     (let 
       ([output (dict-get (downcase-hash-keys (kodi-json-rpc-all-actions)) (car args))])
       (if output
	 (cons args output)
	 #f))))

(define kodi-json-rpc-get-signature
  (λ (args options)
     (let ([output (kodi-json-rpc-try-permutations-until-success args options kodi-json-rpc-data-from-introspect)])
       (if output 
	 (begin 
	   (printf "Arguments ~a are not valid for ~a.\nThe API expects this:\n" (cdar output)(caar output))
	   (pretty-print (cdr output)))
	 (printf "Can't make anything out of that command, sorry!\n")))))

(define kodi-json-rpc-permutations
  (λ (permutations options permutation-procedure)
     (if (empty? permutations)
       #f
       (let
         ([output (permutation-procedure (car permutations) options)])
         (if output 
   	   output 
           (kodi-json-rpc-permutations (cdr permutations) options permutation-procedure))))))

(define kodi-json-rpc-try-or-introspect
  (λ (permutations options) 
     (let ([output (kodi-json-rpc-permutations 
		     permutations
		     options 
		     kodi-json-rpc-dispatch)]) 
       (if output 
	 (begin
	   (printf "Command executed succesfully\n")
	   (pretty-print output)
	 )
	 (kodi-json-rpc-permutations permutations options kodi-json-rpc-get-signature)))))

(define kodi-json-rpc-action
  (λ args (kodi-json-rpc-try-or-introspect 
	     (permutations args) 
	     (kodi-json-rpc-all-actions))))
