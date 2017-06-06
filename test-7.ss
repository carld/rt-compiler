;; -*- Mode: Scheme; paredit -*-
(load  "compiler2.scm")
(program '(let ((var1 (+ 3 4))
                (var2 (+ 4 3)))
            (* var1 var2)))
