;; -*- Mode: Scheme; paredit -*-
(load  "compiler2.scm")
(compile '(let ((var1 (+ 3 4)))
            (* 2 var1)))
