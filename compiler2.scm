(define-syntax movss
  (syntax-rules ()
    [(_ op1 op2)  (printf "movss ~s, ~s~%" `op1 `op2) ] ))

(define-syntax program
  (syntax-rules ()
    [(_ body ...) (begin  body ...)]))

(define-syntax section
  (syntax-rules ()
    [(_ type body ...)
     (begin
       (printf "section .~s ~%" `type)
       body ...)]

    ))

(define-syntax global
  (syntax-rules ()
    [(_ name) (printf "global ~s~%" `name)]))

(define-syntax label
  (syntax-rules ()
    [(_ name) (printf "~s:~%" `name)]
    [(_ name type value) (printf "~s: ~s ~s~%" `name `type `value)]
    ))
