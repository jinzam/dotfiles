; Emacs version
(defvar oldemacs-p (<= emacs-major-version 22))
(defvar emacs23-p (<= emacs-major-version 23))
(defvar emacs24-p (>= emacs-major-version 24))

; OS
(defvar darwin-p (eq system-type 'darwin))
(defvar linux-p (eq system-type 'gnu/linux))
(defvar nt-p (eq system-type 'windows-nt))

; Setting $PATH and exec-path on Mac OS X
; See http://www.emacswiki.org/emacs/EmacsApp#toc2
(if (not (getenv "TERM_PROGRAM"))
    (let ((path (shell-command-to-string
                 "$SHELL -cl \"printf %s \\\"\\\$PATH\\\"\"")))
      (setenv "PATH" path)
      (setq exec-path (split-string (getenv "PATH") ":"))))

; load-path
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
              (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))
(add-to-load-path "elisp" "conf" "public_repos")

;(menu-bar-mode 0)
(tool-bar-mode 0)
(scroll-bar-mode 0)

; ModeLine
(display-time)
(line-number-mode 1)
(column-number-mode 1)

; Show the function in the HeaderLine insted of the ModeLine.
(which-function-mode)
(setq mode-line-misc-info
      (delete (assoc 'which-func-mode mode-line-misc-info)
              mode-line-misc-info)
      which-func-header-line-format '(which-func-mode
                                      ("" which-func-format)))
(defadvice which-func-ff-hook (after header-line activate)
  (when which-func-mode
    (setq mode-line-misc-info (delete (assoc 'which-func-mode
                                             mode-line-misc-info)
                                      mode-line-misc-info)
          header-line-format which-func-header-line-format)))

(global-linum-mode t)
(setq linum-format "%5d")
(global-hl-line-mode t)
(setq kill-while-line t)
(show-paren-mode t)

(setq visible-bell t)
(setq ring-bell-function 'ignore)
(defalias 'yes-or-no-p 'y-or-n-p)
(setq-default tab-width 8 indent-tabs-mode nil)

(add-hook 'text-mode-hook
          '(lambda ()
             (setq fill-column 72)
             (auto-fill-mode 1)
             ))

; Mac OS X specific
(when darwin-p

  (require 'ucs-normalize)
  (setq file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs)

  ; key behavior
  (setq mac-option-modifier 'alt)
  (setq mac-command-modifier 'meta)
)


;;;
;;; Global key binding
;;;
(global-set-key "\C-h" 'delete-backward-char)
(global-set-key (kbd "M-h") 'backward-kill-word)
(global-set-key (kbd "M-g") 'goto-line)
(global-set-key (kbd "C-m") 'newline-and-indent)
(global-unset-key "\C-z")

; Proxy
; (setq url-proxy-services '(("http" . "hostname:port")))

;;;
;;; Package manager
;;;
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)


;;;
;;; Face
;;;

; whitespace-mode
(require 'whitespace)
(setq whitespace-style '(face trailing tabs tab-mark))
(set-face-attribute 'whitespace-tab nil
                    :background nil
                    :underline t)

(when (display-graphic-p)

  ; Theme
  (load-theme 'solarized t)

  ; Font
  (create-fontset-from-ascii-font
   "Ricty-14:weight=normal:slant=normal" nil "ricty")
  (set-fontset-font "fontset-ricty"
                    'unicode
                    (font-spec :family "Ricty" :size 14)
                    nil
                    'append)
  (add-to-list 'default-frame-alist '(font . "fontset-ricty"))

  (global-whitespace-mode t)
)


;;;
;;; helm
;;;
(require 'helm-config)
(helm-mode 1)

(require 'helm-descbinds)
(helm-descbinds-mode)

(require 'helm-ag)
(setq helm-ag-base-command "ag --nogroup --ignore-case")
(setq helm-ag-thing-at-point 'symbol)

(require 'helm-gtags)
(add-hook 'c-mode-hook 'helm-gtags-mode)

; Key binding with helm
(define-key helm-map (kbd "C-h") 'delete-backward-char)
(define-key helm-find-files-map (kbd "C-h") 'delete-backward-char)
(global-set-key "\C-o" 'helm-occur)
(global-set-key "\C-x\C-r" 'helm-recentf)
(add-hook 'helm-gtags-mode-hook
          '(lambda ()
             (local-set-key (kbd "M-t") 'helm-gtags-find-tag)
             (local-set-key (kbd "M-r") 'helm-gtags-find-rtag)
             (local-set-key (kbd "M-s") 'helm-gtags-find-symbol)
             (local-set-key (kbd "C-t") 'helm-gtags-pop-stack)))

;;;
;;; diff
;;;
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;;;
;;; The Silver Searcher (ag)
;;;
(setq ag-highlight-search t)


;;;
;;; Org-mode
;;;
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)


;;;
;;; auto-complete
;;;
(require 'auto-complete)
(require 'auto-complete-config)
(global-auto-complete-mode t)


;;;
;;; C
;;;
(add-hook 'c-mode-hook
          '(lambda ()
             (c-set-style "linux")
             (setq indent-tabs-mode t)))

;;;
;;; js2-mode
;;;
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-hook 'js2-mode-hook
          '(lambda ()
             (setq js2-basic-offset 2
                   indent-tabs-mode nil)))

;;;
;;; migemo
;;;
(require 'migemo)
(setq migemo-command "cmigemo")
(setq migemo-dictionary "/usr/local/share/migemo/utf-8/migemo-dict")
(setq migemo-options '("-q" "--emacs" "-i" "\a"))
(setq migemo-coding-system 'utf-8-unix)
(setq migemo-user-dictionary nil)
(setq migemo-regex-dictionary nil)
(load-library "migemo")
(migemo-init)
;; (define-key isearch-mode-map (kbd "C-e") 'migemo-isearch-toggle-migemo)


;;;
;;; Dictionary
;;;
(when darwin-p
  (global-set-key
   "\C-cw"
   (lambda ()
     (interactive)
     (let ((url (concat
                 "dict://" (read-from-minibuffer "" (current-word)))))
       (browse-url url)))))
