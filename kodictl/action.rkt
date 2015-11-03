#!/usr/bin/env racket
#lang racket/base
(require json)

(require "utils.rkt")
(require "rpc.rkt")

(provide kodi-json-rpc-action)

; send a string to kodi's json-rpc and return the reponse string
(define kodi-json-rpc-call-str
  (λ (jsonstr)
     (read-line 
       (port-from-http-response (λ () 
				   (post-str-to-json-rpc-host 
				     jsonstr
				     #:host (getenv "KODI_HOST")
				     #:port (string->number (getenv "KODI_PORT"))
				     #:uri (getenv "KODI_JSON_RPC_PATH")))))))

; send a hash to kodi's json-rpc and return the response string
(define kodi-json-rpc-call
  (λ (payload)
     (kodi-json-rpc-call-str 
       (jsexpr->string payload))))

(define forge-payload
  (λ (method #:params [params #hash()]
      #:jsonrpc [jsonrpc "2.0"] #:id [id 1])
     (hasheq 'jsonrpc "2.0"
	     'method method
	     'params params
	     'id id)))

(define kodi-json-rpc-action
  (λ args
     (let 
       ([params (if (< 1 (length args))
		  (hasheq (string->symbol (cadr args))
			  (cond
			    [(< 1 (length (cddr args)))
			     (create-hash-from-arguments (cddr args))]
			    [else (cast-string-to-type (caddr args))]))
		  #hash())])
       (kodi-json-rpc-call (forge-payload (car args) #:params params)))))
