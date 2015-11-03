#!/usr/bin/env racket
#lang racket
(require json)

(require "../action.rkt")
(require "../utils.rkt")

(provide kodi-json-rpc-list-actions)

(define kodi-json-rpc-introspect
  (λ () 
     (kodi-json-rpc-action "JsonRPC.Introspect")))

(define kodi-json-rpc-all-actions
  (λ ()
     (dict-get
       (dict-get
	 (with-handlers ([exn:fail? 
			   (λ (x) 
			      (error "ERROR: Server didn't return JSON"))])
			(string->jsexpr (kodi-json-rpc-introspect)))
         "result")
       "methods")))

(define filter-namespace
  (λ (namespace actions)
     (filter
       (λ (action)
	  (regexp-match? (regexp (string-append "^" namespace))
			 (symbol->string action)))
       actions)))

(define filter-namespace-if-specified
  (λ (namespace actions)
     (if namespace
       (filter-namespace namespace actions)
       actions)))

(define kodi-json-rpc-list-actions
  (λ ([arg #f])
    (let 
      ([actions (kodi-json-rpc-all-actions)])
      (for-each
        (λ (action) 
  	  (printf "~a : ~a\n" action 
		               (dict-get
			         (dict-ref actions action)
			         "description")))
  	  (filter-namespace-if-specified arg (hash-keys actions))))))
