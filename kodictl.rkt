#!/usr/bin/env racket
#lang racket
(require racket/cmdline)
(require net/http-client)
(require json)

(define default-kodi-json-rpc-path "/jsonrpc")
(define default-kodi-host "localhost")
(define default-kodi-port 80)

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
  (λ (jsonstr #:host host #:port port #:uri [uri default-kodi-json-rpc-path]
      #:headers [headers '("Content-Type: application/json")])
     (post-str-to-host jsonstr #:host host 
		       #:port port #:uri uri 
		       #:headers headers)))

; send a string to kodi's json-rpc and return the reponse string
(define kodi-json-rpc-call-str
  (λ (jsonstr #:host [host default-kodi-host] #:port [port default-kodi-port])
     (read-line 
       (port-from-http-response (λ () 
				   (post-str-to-json-rpc-host jsonstr
							      #:host host 
							      #:port port))))))

; send a hash to kodi's json-rpc and return the response string
(define kodi-json-rpc-call
  (λ (payload #:host [host default-kodi-host] #:port [port default-kodi-port])
     (string->jsexpr 
       (kodi-json-rpc-call-str 
	 (jsexpr->string payload) #:host host #:port port))))

(define forge-payload
  (λ (method #:params [params #hash()]
      #:jsonrpc [jsonrpc "2.0"] #:id [id 1])
     (hasheq 'jsonrpc "2.0"
	     'method method
	     'params params
	     'id id)))

(define kodi-json-rpc-action
  (λ (action [param-key #f] [param-value #f]) 
     (let 
       ([params (if param-key
		  (hasheq (string->symbol param-key) (string->number param-value))
		  #hash())])
       (kodi-json-rpc-call (forge-payload action #:params params) #:port 8088))))

(define kodi-json-rpc-introspect
  (λ () 
     (kodi-json-rpc-action "JsonRPC.Introspect")))

(define kodi-json-rpc-all-actions
  (λ ()
     (dict-ref
       (dict-ref 
         (kodi-json-rpc-introspect) 
         (string->symbol "result"))
       (string->symbol "methods"))))

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
  (λ (arg params)
    (let 
      ([actions (kodi-json-rpc-all-actions)])
      (for-each
        (λ (action) 
  	  (printf "~a : ~a\n" action 
		               (dict-ref
			         (dict-ref actions action)
			         (string->symbol "description"))))
  	  (filter-namespace-if-specified arg (hash-keys actions))))))

(define kodi-json-rpc-getactiveplayers
  (λ ()
     (kodi-json-rpc-action "Player.GetActivePlayers")))

(define kodi-json-rpc-list-of-player-ids
  (λ ()
     (map (λ (player) (dict-ref player (string->symbol "playerid")))
	  (dict-ref (kodi-json-rpc-getactiveplayers) 
		    (string->symbol "result")))))

(define kodi-json-rpc-playpause
  (λ ()
     (map (λ (playerid) 
	     (kodi-json-rpc-action "Player.Playpause" "playerid" 
				   (number->string playerid)))
	     (kodi-json-rpc-list-of-player-ids))))

(define kodictl-list-commands
  (λ (arg params)
    (for-each 
      (λ (cmd) (printf "~a : ~a\n" cmd (cdr (dict-ref commands cmd)))) 
      (hash-keys commands))))

(define commands
  (hasheq 
    'playpause (cons (λ (arg params) (kodi-json-rpc-playpause)) 
	         "pause if playing, play if paused")
    'help (cons kodictl-list-commands 
		"list available commands")
    'list (cons kodi-json-rpc-list-actions 
		"list all JSON-RPC actions and descriptions")))

(define evaluate-command-or-api-call
  (λ (cmd args)
     (if (dict-has-key? commands cmd)
       (apply (car (dict-ref commands cmd)) args)
       (apply kodi-json-rpc-action (flatten (cons (symbol->string cmd) args))))))

(define kodictl
  (command-line
    #:program "kodictl"
    #:usage-help "\nCommand line client for Kodi's JSON-RPC API"
    #:ps "\nTo see all available kodictl commands run $ kodictl help"
         "\nExecute JSON-RPC actions from the commandline"
	 "examples: "
	 "$ kodictl AudioLibrary.scan"
	 "$ kodictl Player.Playpause playerid 0"
    #:args (command [arg #f] [params #f])
    (λ () (evaluate-command-or-api-call (string->symbol command) (list arg params)))))

(kodictl)
