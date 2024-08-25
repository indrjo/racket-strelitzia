#lang racket

(provide make-tex)

(define (tex-command engine main-file)
  (format "perl -e 'print \"\n\"x50' | max_print_line=1000 ~a ~a"
          engine main-file))

(define (make-tex engine main-file)
  (void (system (tex-command engine main-file))))

