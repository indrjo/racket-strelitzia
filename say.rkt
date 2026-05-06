#lang racket

(provide say
         say-error)

(define (say message)
  (displayln (format ":: ~a" message)))

(define (say-error message)
  (displayln (format "!! ~a" message)))
