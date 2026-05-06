#lang racket

(require "helpers.rkt")

(provide list-files-not-found
         list-invoked-packages)

;; Capture the names the missing files from the log of a TeX
;; command. More precisely, look for pieces of the form
;;
;;   "FILE" not found
;;
;; and isolate FILE.
(define (list-files-not-found fname)
  (call-with-input-file fname capture-files-not-found))

(define (capture-files-not-found input)
  (regexp-matches #px"`([^']+)' not found" input))

;; Take a file, that one containing your preamble, and extracts all
;; the packages invoked for your project.
(define (list-invoked-packages fname)
  (call-with-input-file fname
    (compose fix-imports-list
             (curry regexp-matches invoke-package-regexp))))

(define invoke-package-regexp
  #px"\\\\(?:documentclass|usepackage)(?:\\[[^]]+\\])?\\{([^}]+)\\}")

;; Packages might be invoked in groups, e.g.
;;
;; \usepackage{pack1,pack2,...}
;;
;; That said, merely isolating the piece between the curly braces
;; isn't exactly what we want.
(define (fix-imports-list ls)
  (foldl (λ (x acc)
           (append acc (regexp-split #px"\\s*,\\s*" x)))
         '()
         ls))


