;; For debugging purposes
(defconst emacs-start-time (current-time))
(unless noninteractive
  (message "Loading %s..." load-file-name))

;;Add MELPA
(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
  (add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
  (package-initialize))

(setq message-log-max 16384)

;;Ensure that all packages are installed
(setq use-package-always-ensure t)

;;Enable use-package
(eval-and-compile
  (defvar use-package-verbose t)
  ;; (defvar use-package-expand-minimally t)
  (eval-after-load 'advice
    `(setq ad-redefinition-action 'accept))
  (require 'cl)
  (require 'use-package))

(use-package use-package-chords
  :config (key-chord-mode 1))

(require 'bind-key)
(require 'diminish nil t)

;;Disable Toolbars
(when window-system
  (tooltip-mode -1)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1))

;;No startup screen
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

;;Setting up shell path
(use-package exec-path-from-shell
  :config (exec-path-from-shell-initialize))

;;User-details
(setq user-full-name "Jethro Kuan"
      user-mail-address "jethrokuan95@gmail.com")

;;;; Theming
;;   Color Schemes
(use-package monokai-theme
  :config (load-theme 'monokai t)
  (setq org-fontify-whole-heading-line t))

(use-package material-theme
  :disabled t
  :config (load-theme 'material t)
  (setq org-fontify-whole-heading-line t))

(show-paren-mode 1)
(setq show-paren-delay 0)

;; Display line nums in prog-mode
(defun linum-mode-hook () 
  (linum-mode 1))

(add-hook 'prog-mode-hook 'linum-mode-hook) 

;; Rainbow-delimiters for pretty brackets
(use-package rainbow-delimiters
  :init (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

;; Rainbow-mode for displaying colors for RGB and hex values
(use-package rainbow-mode
  :init (add-hook 'css-mode-hook 'rainbow-mode))

;;Movement
(use-package avy
  :chords (("jj" . avy-goto-char)
	   ("kk" . avy-goto-char-2)))

(use-package ace-window
  :bind (("M-'" . ace-window)))

;;Helm
(use-package helm
  :diminish helm-mode
  :chords (("hf" . helm-find-files)
	   ("hb" . helm-buffers-list)
	   ("hs" . save-buffer))
  :bind* (("C-c h" . helm-mini)
	  ("C-x C-f" . helm-find-files)
	  ("C-o" . helm-find-files)
	  ("C-c f" . helm-recentf)
	  ("C-h a" . helm-apropos)
	  ("C-x C-b" . helm-buffers-list)
	  ("C-x b" . helm-buffers-list)
	  ("M-y" . helm-show-kill-ring)
	  ("M-a" . helm-M-x)
	  ("C-x c o" . helm-occur)
	  ("C-x c SPC" . helm-all-mark-rings))
  :config (progn
	    (require 'helm-config)
	    (setq helm-candidate-number-limit 100)
            (setq helm-idle-delay 0.0 ; update fast sources immediately (doesn't).
	          helm-input-idle-delay 0.01  ; this actually updates things
					; reeeelatively quickly.
	          helm-quick-update t
		  helm-M-x-requires-pattern nil
		  helm-ff-skip-boring-files t)
	    (helm-mode 1)
	    (use-package helm-swoop
	      :bind ("C-c s" . helm-swoop))
	    (use-package helm-ag
	      :bind ("C-c g" . helm-ag))
	    (use-package helm-descbinds
	      :bind ("C-c d" . helm-descbinds))))

;;;; Modules
;;   Which-key
(use-package which-key
  :diminish which-key-mode
  :init (add-hook 'after-init-hook 'which-key-mode))

;;   Aggressive-indent mode
(use-package aggressive-indent
  :diminish aggressive-indent-mode
  :init (add-hook 'prog-mode-hook 'aggressive-indent-mode))

;;   Magit
(use-package magit
  :init (add-hook 'magit-mode-hook 'hl-line-mode)
  :bind (("C-x g" . magit-status)
	 ("C-x M-g" . magit-dispatch-popup)))

;;   Yasnippet
(use-package yasnippet
  :commands (yas-global-mode yas-minor-mode)
  :init (add-hook 'after-init-hook 'yas-global-mode)
  :config (progn
	    (setq yas-snippet-dirs '("~/.emacs.d/snippets/"))))

;;   Company
(use-package company
  :diminish company-mode
  :defer 5
  :init (progn
	  (add-hook 'after-init-hook 'global-company-mode)
	  (setq company-idle-delay 0.5)
	  (setq company-transformers '(company-sort-by-occurrence)))
  :config (progn
	    (use-package company-quickhelp
	      :init (add-hook 'global-company-mode 'company-quickhelp-mode))))

;;   Projectile
(use-package projectile
  :init (add-hook 'after-init-hook 'projectile-global-mode))

;;   Flycheck
(use-package flycheck
  :defer 5
  :init (add-hook 'after-init-hook 'global-flycheck-mode)
  :config (use-package flycheck-pos-tip
	    :config (progn
		      (custom-set-variables '(flycheck-display-errors-function #'flycheck-pos-tip-error-messages)))))
;;   Org Mode
(use-package org-plus-contrib
  :bind* (("C-c c" . org-capture)
	  ("C-c a" . org-agenda)
	  ("C-c l" . org-store-link))
  :mode ("\\.org\\'" . org-mode)
  :init (progn
	  (setq org-modules '(org-drill))
	  (setq org-directory "~/.org")
	  (setq org-default-notes-directory (concat org-directory "/notes.org"))
	  (setq org-agenda-files (file-expand-wildcards "~/.org/*.org"))
	  (setq org-agenda-dim-blocked-tasks t) ;;clearer agenda
	  (setq org-refile-targets
		'((nil :maxlevel . 3)
		  (org-agenda-files :maxlevel . 3)))
	  (setq org-use-fast-todo-selection t)
	  (setq org-treat-S-cursor-todo-selection-as-state-change nil)
	  (setq org-capture-templates
		'(("t" "Todo" entry (file+headline "~/.org/someday.org" "Tasks")
		   "* TODO %? %i\n")
		  ("p" "Project" entry (file+headline "~/.org/someday.org" "Projects")
		   "* TODO %? %i\n")
		  ("b" "Book" entry (file "~/.org/books.org")
		   "* TO-READ %(org-set-tags) %? %i\n")
		  ("v" "Vocab" entry (file+headline "~/.org/vocab.org" "Vocabulary")
		   "* %^{The word} :drill:\n %\\1 \n** Answer \n%^{The definition}")
		  ("i" "Idea" entry (file+datatree "~/.org/ideas.org")
		   "* %? %i\n")))
	  ))

;;   Markdown mode
(use-package markdown-mode
  :mode "\\.md\\'")

;;   Clojure
;;   Clojure-mode
(use-package clojure-mode
  :mode (("\\.clj\\'" . clojure-mode)
	 ("\\.edn\\'" . clojure-mode))
  :init (add-hook 'clojure-mode-hook #'eldoc-mode))

;;   Cider
(use-package cider
  :defer t
  :init (progn
	  (add-hook 'clojure-mode-hook #'clj-refactor-mode)
	  (setq nrepl-popup-stacktraces nil)
	  (add-to-list 'same-window-buffer-names "<em>nrepl</em>")))

(use-package clj-refactor
  :defer t
  :diminish clj-refactor-mode
  :config (cljr-add-keybindings-with-prefix "C-c j"))

(use-package flycheck-clojure
  :defer 5
  :config (flycheck-clojure-setup))

(provide 'init.el)

;;; init.el ends here
