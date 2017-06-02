;; -*- geiser-scheme-implementation: guile -*-

(define compile-port
  (make-parameter
    (current-output-port)
    (lambda (p)
       (unless (output-port? p)
         (errorf 'compile-port "not an output port ~s" p))
       p)))

(define (emit . args)
  (apply fprintf (compile-port) args)
  (newline (compile-port)))

(define (emit-literal expr)
  (emit "mov rax, ~s" expr))

(define (compile-expr expr env)
  (cond
    (number? expr)  (emit-literal expr))
)

(define (compile-program expr env)
  (emit "global _scheme_entry")
  (emit "section .text")
  (emit "_scheme_entry:")
  (compile-expr expr env)
  (emit "ret"))
