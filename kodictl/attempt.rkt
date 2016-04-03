#!/usr/bin/env racket
#lang racket/base
(require json)
(require json-rpc-client)

(require "utils.rkt")

(provide forge-payload)
(provide kodi-json-rpc-attempt)


(define forge-payload
  (λ (method #:params [params #hash()]
      #:jsonrpc [jsonrpc "2.0"] #:id [id 1])
     (hasheq 'jsonrpc "2.0"
	     'method method
	     'params params
	     'id id)))

(define kodi-json-rpc-try-call
  (λ (args params)
     (let
       ([output (json-rpc-client (getenv "KODI_HOST") 
				 (forge-payload (car args) #:params params))])
       (if (dict-get output "error")
	   #f
	   output))))

(define kodi-json-rpc-attempt
  (λ (args)
     (let
       ([params (if (< 1 (length args))
		  (hasheq (string->symbol (cadr args))
			  (cond
			    [(< 1 (length (cddr args)))
			     (create-hash-from-arguments (cddr args))]
			    [else (cast-string-to-type (caddr args))]))
		  #hash())])
       (kodi-json-rpc-try-call args params))))
