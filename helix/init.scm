;; The previous setup (forest, scopeline, helix-file-watcher, acp.hx, local
;; statusline/bufferline) is kept in init.scm.bk

(require "oil/oil.scm")
(require "smooth-scroll/smooth-scroll.scm")

;; daily note - :daily opens <dir>/yyyy-mm-dd.md, :daily <dir> overrides the dir
(require "daily.scm")
(daily-set-dir! "~/misc/daily")

;; histone - file tree, bars, breadcrumb, the agent pane and a terminal on one
;; layout; also reloads buffers changed on disk. The terminal needs libhistone
;; built with it: `make native TERMINAL=1` in the histone.hx checkout
(require "histone/histone.scm")
(histone-bufferline!)
(histone-breadcrumb!)
(histone-statusline!)
(histone-tree!)
(histone-agent! #:width 64)
(histone-terminal!)
