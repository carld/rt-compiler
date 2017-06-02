#!/usr/bin/env chez --script

;; Load the compiler
(load "compiler.scm")

;; Read the program in the file given on the command line
(define prog
  (call-with-input-file (car (command-line-arguments))
                        read))

;; Emit assembly instructions to stdout
(compile-program prog '())
