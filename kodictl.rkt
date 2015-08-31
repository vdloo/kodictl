#!/usr/bin/env racket
#lang racket
(require racket/cmdline)
(require racket/pretty)
(require net/http-client)
(require json)

(define kodi-host (make-parameter "localhost"))
(define kodi-port (make-parameter 80))
(define kodi-json-rpc-path (make-parameter "/jsonrpc"))

(define dict-get
  (λ (dict attr)
     (dict-ref dict (string->symbol attr))))

; take a list and return a list with pairs of each 2 sequential items
(define split-list-into-list-of-pairs
  (λ (li [spli (list)] [prev empty])
     (let ([argslen (length li)])
          (cond 
            [(zero? argslen) spli]
            [(odd? argslen) 
		  (split-list-into-list-of-pairs 
		    (cdr li) 
		    (append spli (list (cons 
					 (if 
					   (empty? prev)
					   (error "Uneven arguments!")
					   prev)
					 (car li)))))]
	    [else (split-list-into-list-of-pairs 
		    (cdr li) 
		    spli 
		    (car li))]))))

; cast to number if string only contains digits, otherwise cast to symbol
(define cast-string-to-type 
  (λ (str) 
     (if 
       (regexp-match #px"^\\d*$" str)
       (string->number str) 
       (string->symbol str))))

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
  (λ (jsonstr #:host [host (kodi-host)] 
	      #:port [port (kodi-port)] 
	      #:uri [uri (kodi-json-rpc-path)] 
	      #:headers [headers '("Content-Type: application/json")])
     (post-str-to-host jsonstr #:host host 
		       #:port port #:uri uri 
		       #:headers headers)))

; send a string to kodi's json-rpc and return the reponse string
(define kodi-json-rpc-call-str
  (λ (jsonstr)
     (read-line 
       (port-from-http-response (λ () 
				   (post-str-to-json-rpc-host jsonstr))))))

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

; creates a hash with key value each 2 sequential entries in a list
(define create-hash-from-list-pairs
  (λ (li)
     (for/hash ([pair (split-list-into-list-of-pairs li)])
	       (values (string->symbol (car pair)) 
		       (cast-string-to-type (cdr pair))))))

(define list-if-not-list
  (λ (m)
     (if (list? m) m (list m))))

(define create-params-from-list-or-string
  (λ (m)
     (let 
       ([li (list-if-not-list m)])
       (if (> 2 (length li)) 
	 (car li)
	 (create-hash-from-list-pairs li)))))

(define kodi-json-rpc-action
  (λ args
     (kodi-json-rpc-call 
       (forge-payload 
	 (create-params-from-list-or-string (car args))
	 #:params (create-params-from-list-or-string 
		    (cdr args))))))

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

(define kodi-json-rpc-getactiveplayers
  (λ ()
     (kodi-json-rpc-action "Player.GetActivePlayers")))

(define kodi-json-rpc-list-of-player-ids
  (λ ()
     (map (λ (player) (dict-get player "playerid"))
	  (dict-get (string->jsexpr (kodi-json-rpc-getactiveplayers))
		    "result"))))

(define kodi-json-rpc-map-active-players
  (λ (proc)
     (map (λ (playerid) (proc playerid))
	  (kodi-json-rpc-list-of-player-ids))))

; stop all active players
(define kodi-json-rpc-stop
  (λ ()
     (kodi-json-rpc-map-active-players
       (λ (playerid) 
	  (kodi-json-rpc-action "Player.Stop" "playerid" 
				(number->string playerid))))))

; toggle play/pause on active players
(define kodi-json-rpc-playpause
  (λ ()
     (kodi-json-rpc-map-active-players 
       (λ (playerid) 
	  (kodi-json-rpc-action "Player.Playpause" "playerid" 
				(number->string playerid))))))

(define kodi-json-rpc-nowplaying
  (λ ()
     (kodi-json-rpc-map-active-players
       (λ (playerid) 
	  (dict-get
	    (dict-get 
	      (dict-get 
		(string->jsexpr 
		  (kodi-json-rpc-action "Player.GetItem" "playerid" 
					(number->string playerid))) 
		"result") 
	      "item") 
	    "label")))))

; stop active  players and blackhole output
(define kodictl-stop
  (λ ()
     (for-each
       (λ (item) empty)
	  (kodi-json-rpc-stop))))

; playpause active players and blackhole output
(define kodictl-playpause
  (λ ()
     (for-each
       (λ (item) empty)
	  (kodi-json-rpc-playpause))))

(define kodictl-nowplaying
  (λ ()
     (for-each
       (λ (item) (printf "~a\n" item))
       (kodi-json-rpc-nowplaying))))

(define kodictl-list-commands
  (λ ()
    (for-each 
      (λ (cmd) (printf "~a : ~a\n" cmd (cdr (dict-ref commands cmd)))) 
      (hash-keys commands))))

(define commands
  (hasheq 
    'help (cons kodictl-list-commands 
		"list available commands")
    'list (cons kodi-json-rpc-list-actions 
		"list all JSON-RPC actions and descriptions")
    'nowplaying (cons kodictl-nowplaying 
		      "output label of currently playing item")
    'playpause (cons kodictl-playpause 
		     "pause if playing, play if paused")
    'stop (cons kodictl-stop 
		"stop all active players")))

(define kodictl-evaluate-command-or-api-call
  (λ (args)
     (let 
       ([cmd (car args)]
	[params (cdr args)])
       (if (dict-has-key? commands (string->symbol cmd))
         (apply (car (dict-get commands cmd)) params)
         (apply kodi-json-rpc-action args)))))

(command-line
  #:program "kodictl"
  #:once-each
  [("-r" "--remote") host "Specify Kodi host" (kodi-host host)]
  [("-p" "--port") port "Specify Kodi port" (kodi-port 
					      (string->number port))]
  [("-j" "--json-rpc-path") path "Specify Kodi JSON_RPC path" 
			     (kodi-json-rpc-path path)]
  #:usage-help "\nCommand line client for Kodi's JSON-RPC API"
  #:ps "\nTo see all available kodictl commands run $ kodictl help"
   "\nExecute JSON-RPC actions from the commandline"
   "examples: "
   "$ kodictl AudioLibrary.scan"
   "$ kodictl Player.Playpause playerid 0"
  #:args args
  (kodictl-evaluate-command-or-api-call args))
