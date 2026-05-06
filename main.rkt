#lang racket

(require "utils.rkt"
         "say.rkt"
         "tex.rkt"
         "tlmgr.rkt")

(module+ main
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
   (when (imports-file)
     (check-imports (imports-file)))
   (main-program (tex-engine) texfile)))

;; The main program is a function that accepts two arguments:
;;
;; * The former argument is a string containing the name of the TeX
;; engine to be used. The program relies on PATH to find the binaries:
;; hence if you do not have the location containing them in PATH, you
;; should write the TeX engine with the full path to it.
;;
;; * The latter is the name of the TeX file to be given to the TeX
;; engine. Make sure to run strelitzia within the directory of the
;; file.
;;
(define (main-program engine texfile)
  (make-tex engine texfile)
  (let* ([logfile (path-replace-extension texfile ".log")]
         [files-not-found (list-files-not-found logfile)])
    (if (empty? files-not-found)
        (say "no missing files, fine!")
        (begin
          (say (format "missing files: ~a"
                       (bytes-join files-not-found #" ")))
          (if (tlmgr-contact-repository)
              (let ([packages (tlmgr-search files-not-found)])
                (if (empty? packages)
                    (say-error "no packages to install!")
                    (begin
                      (say (format "packages to be installed: ~a"
                                   ;;(string-join packages)
                                   (bytes-join packages #" ")))
                      ;; (unless (tlmgr-install packages)
                      ;;   (say-error "some packages not installed!"))
                      (tlmgr-install packages))))
              (say-error "cannot contact the package repo!")))))
  ;; Install missing fonts too.
  (when (file-exists? "missfont.log")
    (say "missfont.log found! installing missing fonts...")
    (tlmgr-install-fonts "missfont.log")))

;; By default, no preamble file assigned: `check-requires` is not
;; invoked unless you want to do so.
(define imports-file (make-parameter #f))

;; The TeX engine. It defaults to pdflatex; you can modify it with
;; `--engine TEX_ENGINE` or `-e TEX_ENGINE`.
(define tex-engine (make-parameter "pdflatex"))

