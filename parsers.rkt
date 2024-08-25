#lang racket

(provide list-package-names
         list-not-founds
         extract-repo-url
         list-imports)

(require parsack)

;;
;; DESCRIPTION
;;
;; This module defines some parsers that are required by other modules.
;;

#|
;; Because Racket is not lazy as Haskell is, one cannot use `>>` as if they
;; were in a lazy semantics. Of course, that is not the unique difference,
;; but it is the one that affaects our work here. 
(define-syntax-rule (>> f1 f2)
  (>>= f1 (λ (_) f2)))
;; In the parsack module, `>>` is *defined*, not a syntactic element.
|#

;; ************************************************************************
;; Helper functions
;; ************************************************************************

;; While consuming the input string, try a given parser: if it succeeds,
;; collect the match into a list, otherwise move on by one character. The
;; second argument of the function is a binary function used to "chain" in
;; some manner the results of the applied parser. (Below, f will be either
;; `cons` or `append`...)
(define (fold-captures-parser p f)
  (<or>
   (try (>>= p
             (λ (a)
               (>>= (fold-captures-parser p f)
                    (λ (as)
                      (return (f a as)))))))
   (try (>>= $anyChar
             (λ (_)
               (fold-captures-parser p f))))
   (return '())))

;; Observe that the parser above never fails: thus you can always expect
;; the following function to not throw an exception.
(define (fold-captures p f input)
  (parse-result (fold-captures-parser p f) input))


;; ************************************************************************
;; Parse `tlmgr search --global --file` output
;; ************************************************************************

;; From "\nNAME:\n" extract "NAME".
(define package-name-parser
  (between $newline
           (>> (string ":") $newline)
           (>>= (many1 (noneOf ":\n"))
                (compose return list->string))))

;; From the output of `tlmgr search --global --file PATTERN` list the names
;; the names of the packages that occur.
(define (list-package-names input)
  (fold-captures package-name-parser cons input))


;; ************************************************************************
;; Parse TeX logs to get the names of the missing files
;; ************************************************************************

(define quote-marks "'\"`")

(define quoted-name-parser
  (between (oneOf quote-marks)
           (oneOf quote-marks)
           (>>= (many1 (noneOf quote-marks))
                (compose return list->string))))

;; The fragment between two quotation marks.
(define not-found-parser
  (>>= quoted-name-parser
       (λ (name)
         (>> (>> $spaces
                 (string "not found"))
             (return name)))))

;; Capture the names the missing files from the log of a TeX command. More
;; precisely, look for pieces of the form
;;
;;   "FILE" not found
;;
;; and isolate FILE.
(define (list-not-founds input)
  (parse-result (fold-captures-parser not-found-parser cons) input))


;; ************************************************************************
;; Parse `tlmgr option repository` output
;; ************************************************************************

(define repo-url-parser
  (>> (>> (string "Default package repository (repository):")
          $spaces)
      (>>= (many1 (noneOf "\n "))
           (compose return list->string))))

;; Try to parse the output of `tlmgr option repository`. If success, then
;; return the url, otherwise return #f.
(define (extract-repo-url input)
  (with-handlers ([exn:fail:parsack? (λ (_) #f)])
    (parse-result repo-url-parser input)))


;; ************************************************************************
;; Parse TeX preambles to get the list of packages required in a project.
;; ************************************************************************

(define import-keyword-parser
  (oneOfStrings "\\documentclass"
                "\\usepackage"
                "\\requirepackage"))

(define square-parser
  (between (string "[")
           (string "]")
           (many (noneOf "]"))))

(define single-word-parser
  (between $spaces
           $spaces
           (>>= (many1 $alphaNum)
                (compose return list->string))))

(define commas-parser
  (sepBy single-word-parser (string ",")))

(define import-parser
  (>> (>> import-keyword-parser $spaces)
      (>> (>> (optional square-parser) $spaces)
          (between (string "{")
                   (string "}")
                   commas-parser))))

(define (list-imports input)
  (parse-result (fold-captures-parser import-parser append) input))

