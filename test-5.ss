;; -*- Mode: Scheme; paredit -*-
(load  "compiler2.scm")
(compile 
    '(+
        2
        (*
          2
          (+ 1 3))))
