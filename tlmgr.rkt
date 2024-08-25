#lang racket

(provide tlmgr-list-package-names
         tlmgr-install
         contact-package-repo)

(require "run-shell.rkt"
         "parsers.rkt"
         "say.rkt")

;;
;; DESCRIPTION
;;
;; Functions that run `tlmgr` under the hood.
;;

;; ************************************************************************
;; Search for packages to install
;; ************************************************************************

;; Take a list of file names (namely, the ones that are missing) and return
;; the shell command to be issued to the host system.
(define (tlmgr-search-command names)
  (format "tlmgr search --global --file '/(~a)'" (string-join names "|")))

;; Get the list of the packages corresponding to a list of filenames.
(define (tlmgr-list-package-names names)
  (list-package-names (process-output (tlmgr-search-command names))))


;; ************************************************************************
;; Install packages
;; ************************************************************************

;; Install all the packages in a given list of package names.
(define (tlmgr-install packages)
  (system (format "tlmgr install ~a" (string-join packages " "))))


;; ************************************************************************
;; See if you can contact the package repository
;; ************************************************************************

;; Get the repository tlmgr interrogates for packages. If for some reason
;; this happens to fail, return #f.
(define (tlmgr-repo-url)
  (extract-repo-url (process-output "tlmgr option repository")))

;; A wrapper function for the shell command `wget -q --spider URL`.
(define (wget-spider url)
  (system (format "wget -q --spider '~a'" url)))

;; Attempt to contact the repo determined by the function above.
(define (contact-package-repo)
  (let ([url (tlmgr-repo-url)])
    (if (string? url)
        (wget-spider url)
        (begin
          ;; Just in case... who knows?
          (say-error "contact-package-repo: error during the parsing")
          #f))))

