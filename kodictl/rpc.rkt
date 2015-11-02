#!/usr/bin/env racket
#lang racket/base

(require net/http-client)

(provide post-str-to-json-rpc-host)
(provide port-from-http-response)

; http-rendrecv returns three values, we only care about the port
; because it contains the response json from the json-rpc API
(define port-from-http-response
  (λ (http-response)
     (caddr (call-with-values http-response list))))

; http post data in the form of a string
(define post-str-to-host
  (λ (str #:host host #:port port #:uri uri #:headers headers)
     (http-sendrecv host uri #:port port #:method "POST"
                	     #:headers headers #:data str)))

; post string to json-rpc
(define post-str-to-json-rpc-host
  (λ (jsonstr #:host host #:port port #:uri uri 
	      #:headers [headers '("Content-Type: application/json")])
     (post-str-to-host jsonstr #:host host 
		       #:port port #:uri uri 
		       #:headers headers)))
