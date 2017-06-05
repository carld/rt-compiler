(define-syntax section
  (syntax-rules ()
    [(_ type (instruction ...) ... )

     (let-syntax ([b (syntax-rules ()
                       [(_ i)          (printf "~s~%" 'i )]
                       [(_ i op1)      (printf "~s ~s~%" 'i 'op1)]
                       [(_ i op1 op2)  (printf "~s ~s, ~s~%" 'i 'op1 'op2)])])
       (begin
         (printf "~s ~s~%" 'section 'type)
         (b instruction ...) ...
          ))]))

(define (emit depth . args)
  (printf "~vt" (* 2 depth))
  (apply printf args))


(define (binop? expr)
  (case (car expr)
    [(+ - * /) #t]
    [else #f]))

(define (emit-binop x env depth)
  (emit depth ";;; Enter binop ~%")
  (emit depth "; RHS~%")
  (comp (caddr x) env (+ 1 depth))

  (emit depth "; LHS~%")
  (comp (cadr x) env (+ 1 depth))

;  (emit depth "movss xmm1, [esp+4]~%") ; rhs
;  (emit depth "movss xmm0, [esp]~%") ; lhs

  (emit depth "mov ebx, [esp+4] ~%")
  (emit depth "mov eax, [esp] ~%")
  (emit depth "add esp, 8 ~%")

  (case (car x)
    [(+)  (emit depth "add eax, ebx~%")   ]
    [(-)  (emit depth "sub eax, ebx~%")   ]
    [(*)  (emit depth "imul ebx~%")   ]
    [(/)
     (begin
       (emit depth "mov edx, 0~%")
       (emit depth "idiv ebx~%"))   ]
    )
  (emit depth "push eax ~%")
  (emit depth ";;; Leave binop ~%")
)

(define (comp x env depth)
  (cond
   [(fixnum? x)  (emit depth "push ~a~%" x)]
   [(binop? x)  (emit-binop x env (+ 1 depth))]
   [else (error "bad expression " x)]))

(define (program x)
;  (emit 0 "align 16 ~%")
  (emit 0 "global _scheme_entry~%")
  (emit 0 "section .text~%")
  (emit 0 "_scheme_entry:~%")
  (emit 0 "push ebp~%")
  (emit 0 "mov ebp, esp~%")
;  (emit 0 "and esp, 0FFFFFFF0H ~% ; align stack")
  (comp x '() 0)
  (emit 0 "pop eax~%")
  (emit 0 "mov esp, ebp~%")
  (emit 0 "pop ebp ~%")
  (emit 0 "ret~%")
  )
