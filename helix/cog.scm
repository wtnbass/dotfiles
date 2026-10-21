;; plugins required by init.scm - install with `forge build` in this directory
(define package-name 'helix-config)
(define version "0.1.0")
(define dependencies
  '((#:name oil #:git-url "https://github.com/Ra77a3l3-jar/oil.hx.git")
    (#:name smooth-scroll #:git-url "https://github.com/thomasschafer/smooth-scroll.hx.git")
    ;; replaced by histone; kept for init.scm.bk
    ;; (#:name helix-file-watcher #:git-url "https://github.com/mattwparas/helix-file-watcher.git")
    ;; (#:name forest #:git-url "https://github.com/Ra77a3l3-jar/forest.hx.git")
    ;; (#:name glyph #:git-url "https://github.com/Ra77a3l3-jar/glyph.hx.git")
    ;; (#:name scopeline #:git-url "https://github.com/Ra77a3l3-jar/scopeline.git")
    ;; (#:name acp #:git-url "https://github.com/wtnbass/acp.hx.git")
    (#:name histone #:git-url "https://github.com/wtnbass/histone.hx.git")))
