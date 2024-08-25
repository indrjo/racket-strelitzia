#lang racket

(provide process-output)

;; Make the underlying OS run some shell command: wait until it terminates
;; and return both stderr and stdout in one string.
(define (process-output cmd)
  (match (process (format "~a 2>&1" cmd))
    [(list std-out std-in _ std-err prc-func)
     (begin0
         (port->string std-out)
       (close-input-port std-out)
       (close-output-port std-in)
       (close-input-port std-err)
       (prc-func 'wait))]))

