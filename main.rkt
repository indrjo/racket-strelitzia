#lang racket

(require "say.rkt"
         "tex.rkt"
         "parsers.rkt"
         "tlmgr.rkt")

;; The main program is a function that accepts two arguments:
;;
;; * The former argument is a string containing the name of the TeX engine
;;   to be used. The program relies on PATH to find the binaries: hence
;;   if you do not have the location containing them in PATH, you should
;;   write the TeX engine with the full path to it. 
;;
;; * The latter is the name of the TeX file to be given to the TeX engine.
;;   Make sure to run strelitzia within the directory of the file.
;;
(define (main-program engine texfile)
  (make-tex engine texfile)
  (let* ([logfile (path-replace-extension texfile ".log")]
         [not-founds (list-not-founds logfile)])
    (if (empty? not-founds)
        (say "no missing files, fine!")
        (begin
          (say (format "missing files: ~a"
                       (string-join not-founds)))
          (if (contact-package-repo)
              (let ([packages (tlmgr-list-package-names not-founds)])
                (begin
                  (if (empty? packages)
                      (say "no packages to install!")
                      (begin
                        (say (format "packages to be installed: ~a"
                                     (string-join packages)))
                        (unless (tlmgr-install packages)
                          (say-error "some packages not installed!"))))))
              (say-error "cannot contact the package repo!"))))))

;; The argument is the file where you have written your \documentclass and
;; \usepackage's, etc etc etc. The function will install the packages whose
;; names are listed as arguments of the *import* keywords.
(define (check-imports file)
  (let ([packages (list-imports (string->path file))])
    (say (format "required packages: ~a" (string-join packages)))
    (tlmgr-install packages)))

;; By default, no preamble file assigned: the function `check-requires` is
;; not invoked unless you want to do so.
(define imports-file (make-parameter #f))

;; The TeX engine. It defaults to pdflatex; you can modify it with
;; `--engine TEX_ENGINE` or `-e TEX_ENGINE`.
(define tex-engine (make-parameter "pdflatex"))

(command-line
 #:program "strelitzia"
 #:once-each
 [("--check-imports" "-c")
  this-file
  "Indicate the file of \\documentclass's, \\usepackage's, etc..."
  (imports-file this-file)]
 [("--engine" "-e")
  this-engine
  "Choose a TeX engine [default: pdflatex]"
  (tex-engine this-engine)]
 #:args (texfile)
 (begin
   (when (imports-file)
     (check-imports (imports-file)))
   (main-program (tex-engine) texfile)))

