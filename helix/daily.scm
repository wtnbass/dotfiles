;; daily note: opens <dir>/yyyy-mm-dd.md, creating the directory and file when missing

(require-builtin steel/time)
(require (prefix-in helix. "helix/commands.scm"))

(provide daily
         daily-set-dir!)

(define *daily-dir* "~/misc/daily")

(define (daily-set-dir! dir)
  (set! *daily-dir* dir))

(define (expand-home path)
  (cond
    [(equal? path "~") (env-var "HOME")]
    [(starts-with? path "~/") (string-append (env-var "HOME") (substring path 1 (string-length path)))]
    [else path]))

(define (trim-trailing-slash path)
  (if (and (> (string-length path) 1) (ends-with? path "/"))
      (trim-trailing-slash (substring path 0 (- (string-length path) 1)))
      path))

;; :daily opens today's note in the configured dir, :daily <dir> uses <dir> instead
(define (daily . args)
  (define dir (trim-trailing-slash (expand-home (if (null? args) *daily-dir* (car args)))))
  (define date (local-time/now! "%Y-%m-%d"))
  (define path (string-append dir "/" date ".md"))
  (unless (path-exists? path)
    (create-directory! dir)
    (let ([port (open-output-file path)])
      (write-string (string-append "# " date "\n") port)
      (close-output-port port)))
  (helix.open path))
