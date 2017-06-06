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

(define (let? expr)
  (equal? (car expr) 'let))

(define (emit-binop i x env depth)
  (comp i (caddr x) env (+ 1 depth))
  (comp i (cadr x) env (+ 1 depth))

;  (emit depth "movss xmm1, [esp+4]~%") ; rhs
;  (emit depth "movss xmm0, [esp]~%") ; lhs

  (emit depth "mov ebx, [esp+4] ~%")
  (emit depth "mov eax, [esp] ~%")
  (emit depth "add esp, 8 ~%")

  (emit depth "xor edx, edx ~%")
  (case (car x)
    [(+)  (emit depth "add eax, ebx~%")   ]
    [(-)  (emit depth "sub eax, ebx~%")   ]
    [(*)  (emit depth "imul ebx~%")   ]
    [(/)  (emit depth "idiv ebx~%")   ])
  (emit depth "push eax ~%")
)

(define (lookup-sym sym env)
  (let [(val (assoc sym env))]
    (if (pair? val) (cdr val) #f)))

(define (emit-sym sym env depth)
  (let [(si (lookup-sym sym env))]
    (cond
     [si (emit depth "push DWORD [esp+~a]~%" si)]
     [else (errorf 'emit-sym "no reference for symbol: ~a in env: ~a" sym env)])))

(define (emit-let i x env depth)
  (let binding-loop [(si i)
                     (bindings (cadr x))
                     (new-env env)]
    (cond
     [(null? bindings)  ; no more bindings, evaluate let body
      (comp si (caddr x) new-env depth)]
     [else
      (let* [(b1 (car bindings))
             (name (car b1))
             (value (cadr b1))]
        (comp si value new-env depth)
        (binding-loop (+ si 4) (cdr bindings) (cons (cons name si) new-env)))])))

(define (vector? x)
  (equal? 'vec (car x)))

(define (emit-vector i x env depth)
  (emit depth " ; TODO"))

(define (comp i x env depth)
  (cond
   [(fixnum? x)  (emit depth "push DWORD ~a~%" x)]
   [(flonum? x)  (emit depth "push DWORD ~a~%" x)]
   [(symbol? x)  (emit-sym x env depth)]
   [(vector? x)  (emit-vector i x env depth)]
   [(binop? x)   (emit-binop i x env (+ 1 depth))]
   [(let? x)     (emit-let i x env (+ 1 depth))]
   [else (errorf 'comp "bad expression: ~a" x)]))

(define (program x)
  (let [(si 0)
        (depth 0)
        (env '())]
    (emit si "global _scheme_entry~%")
    (emit si "section .text~%")
    (emit si "_scheme_entry:~%")
    (emit si "push ebp~%")
    (emit si "mov ebp, esp~%")
    (emit si "and esp, 0FFFFFFF0H ; align stack to 16 ~%")
    (comp si x env depth)
    (emit si "pop eax~%")
    (emit si "mov esp, ebp~%")
    (emit si "pop ebp ~%")
    (emit si "ret~%")))
