#lang racket

(provide tlmgr-search
         tlmgr-install
         tlmgr-install-fonts
         tlmgr-contact-repository
         check-imports)

(require "say.rkt"
         "helpers.rkt"
         "utils.rkt")

;;
;; DESCRIPTION
;;
;; Functions that run `tlmgr` under the hood.
;;

;; From the output of
;;
;; $ tlmgr search --global --file PATTERN
;;
;; list the names the names of the packages that occur. The command is
;; prepared by a function below.
(define (tlmgr-search fnames)
  (call-with-process-stdout capture-package-names
                            (tlmgr-search-command fnames)))

;; Takes as input the standard output port which tlmgr writes logs to
;; and isolates the packages' names.
(define (capture-package-names tlmgr-search-output)
  (regexp-matches #px"\n([^:]+):\n" tlmgr-search-output))

;; Take a list of file names (namely, the ones that are missing) and
;; return the shell command to be issued to search packages.
(define (tlmgr-search-command fnames)
  (format "tlmgr search --global --file '/(~a)'"
          (bytes-join fnames #"|")))

;; We use the shell command
;;
;; $ tlmgr option repository
;;
;; to get the url of the repository you get packages from.
(define (tlmgr-repository-url)
  (call-with-process-stdout capture-repository-url
                            "tlmgr option repository"))

(define (capture-repository-url tlmgr-repository-output)
  (match (regexp-match #px"(?<=: )(https\\S+)" tlmgr-repository-output)
    [(list _ url) url]
    [_            #f]))

;; Attempt to contact the repo determined by the function above.
(define (tlmgr-contact-repository)
  (let ([url (tlmgr-repository-url)])
    (if url
        (wget-spider url)
        (begin
          ;; Just in case... who knows?
          (say-error "contact-package-repo: error during the parsing")
          #f))))

;; A wrapper function for the shell command
;;
;; $ wget -q --spider URL
(define (wget-spider url)
  (system (format "wget -q --spider '~a'" url)))

;; Install all the packages in a given list of package names.
(define (tlmgr-install packages)
  (system (format "tlmgr install ~a"
                  (bytes-join packages #" "))))

;; Read missfont.log and install missing fonts.
(define (tlmgr-install-fonts missfont-log)
  (tlmgr-install
   (tlmgr-search
    (get-missing-fonts missfont-log))))

;; Extracts the list of missing fonts for a TeX project.
(define (get-missing-fonts missfont-log)
  (call-with-input-file missfont-log
    (compose remove-duplicates
             sequence->list
             (curry sequence-map only-font)
             in-bytes-lines)))

(define (only-font str)
  (match (regexp-match #px"\\S+ +(\\S+)" str)
    [(list _ missing) missing]
    [_                #f]))

;; The argument is the file where you have written your \documentclass
;; and \usepackage's, etc etc etc. The function will install the
;; packages whose names are listed as arguments of the *import*
;; keywords.
(define (check-imports preamble)
  (let ([packages (list-invoked-packages preamble)])
    (say (format "needed packages: ~a" (bytes-join packages #" ")))
    (tlmgr-install packages)))
