#lang racket

;; HELPERS

(provide regexp-matches
         call-with-process-stdout)

;; Takes as arguments a pattern with capturing parenthesis and some
;; input (a string or an input-port for our scopes) and return the list
;; of all the pieces matching the pattern.
(define (regexp-matches pattern input)
  (regexp-match* pattern
                 input
                 #:match-select second))

;; Make the host OS run some shell command and wait until it
;; ends. Finally apply some function to that string.
(define (call-with-process-stdout f cmd)
  (f (with-output-to-bytes
        (λ () (system (format "~a 2>&1" cmd))))))

