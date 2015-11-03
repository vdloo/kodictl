#!/usr/bin/env racket
#lang racket

(provide cast-string-to-type)
(provide split-list-into-list-of-pairs)
(provide dict-get)
(provide create-hash-from-arguments)

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

(define create-hash-from-arguments
  (λ (args)
     (for/hash ([pair (split-list-into-list-of-pairs args)])
	       (values (string->symbol (car pair)) 
		       (cdr pair)))))

