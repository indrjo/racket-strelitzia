#lang racket

(provide make-tex)

(define (tex-command engine main-file)
  (format "yes \" \" | max_print_line=1000 ~a ~a"
          engine main-file))

(define (make-tex engine main-file)
  (system (tex-command engine main-file)))

