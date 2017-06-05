;; -*- geiser-scheme-implementation: chez -*-

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

(define (emit-line)
  (newline (compile-port)))

(define make-symbol
  (let ((sym-num 0))
    (lambda ()
      (set! sym-num (+ 1 sym-num))
      (format #f "sym_~s" sym-num))))

(define (binop? expr)
  (and (pair? expr) (= 3 (length expr))))

(define (compile-expr expr env)
  (cond
   ; atomic types
   ((flonum? expr)  (emit "movss %xmm0, ~s" expr))

   ; non-atomic types
   ((binop? expr)  (emit "~s ~s, ~s"
                         (car expr)
                         (compile-expr (cadr expr) env)
                         (compile-expr (caddr expr) env)))

   (else (errorf "unrecognized expression:" expr))))

(define (compile-program expr env)
  (emit "global _scheme_entry")
  (emit "section .text")
  (emit "_scheme_entry:")
  (compile-expr expr env)
  (emit "ret"))
