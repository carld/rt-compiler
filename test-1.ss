;; -*- Mode: Scheme; paredit -*-
(program
 (global _scheme_entry)
 (section text
          (label _scheme_entry)
          (movss %xmm0 c1))
 (section data
          (label c1 dd 3.14157))
 )
