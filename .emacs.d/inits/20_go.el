(require 'go-mode)
(require 'company-go)
(require 'flycheck)
(require 'flymake)
(require 'flymake-go)
(add-hook 'go-mode-hook 'company-mode)
(add-hook 'go-mode-hook 'flycheck-mode)
(add-hook 'go-mode-hook
          '(lambda()
             (add-hook 'before-save-hook' 'gofmt-before-save)
             (local-set-key (kbd "M-.") 'godef-jump)
             (set (make-local-variable 'company-backends)
                  '(company-go)) (setq company-go-insert-arguments nil)))
