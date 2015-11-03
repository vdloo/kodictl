#!/usr/bin/env racket
#lang racket/base

(require "cmdline.rkt")
(require "eval.rkt")

(parse-args kodictl-evaluate-command-or-api-call)
