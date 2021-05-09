;;; evil-markdown.el --- evil keybindings for markdown-mode

;; Maintainer: Somelauw
;; URL: https://github.com/Somelauw/evil-markdown.git
;; Git-Repository; git://github.com/Somelauw/evil-markdown.git
;; Created: 2016-03-21
;; Version: 0.0.2
;; Keywords: evil vim-emulation markdown-mode key-bindings presets

;; This file is not part of GNU Emacs

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.markdown/licenses/>.

;;; Commentary:
;;
;; Known Bugs:
;; See, https://github.com/Somelauw/evil-markdown-mode/issues
;;
;;; Code:
(require 'cl-lib)

(require 'evil)
(require 'markdown-mode)

(defgroup evil-markdown nil
  "Provides integration of markdown-mode and evil."
  :group 'markdown
  :prefix "evil-markdown-")

(defcustom evil-markdown-movement-bindings
  '((up . "k")
    (down . "j")
    (left . "h")
    (right . "l"))
  "AList of normal keys to use for arrows.

   This can be used by non-qwerty users who don't use hjkl."
  :group 'evil-markdown
  :type '(alist :key-type symbol :value-type string)
  :options '(up down left right))

(defcustom evil-markdown-use-additional-insert
  nil
  "Whether additional keybindings should also be available in insert mode."
  :group 'evil-markdown
  :type 'boolean)

(defvar evil-markdown-mode-map (make-sparse-keymap))

;;;###autoload
(define-minor-mode evil-markdown-mode
  "Buffer local minor mode for evil-markdown"
  :init-value nil
  :lighter " EvilMarkdown"
  :keymap evil-markdown-mode-map
  :group 'evil-markdown)

(add-hook 'markdown-mode-hook 'evil-markdown-mode) ;; only load with markdown-mode

;;; motion declarations
(evil-declare-motion 'markdown-forward-paragraph)
(evil-declare-motion 'markdown-backward-paragraph)

;; heading
(evil-declare-motion 'markdown-forward-same-level)
(evil-declare-motion 'markdown-backward-same-level)
(evil-declare-motion 'markdown-up-heading)
(evil-declare-motion 'markdown-next-heading)
(evil-declare-motion 'markdown-previous-heading)
(evil-declare-motion 'markdown-next-visible-heading)
(evil-declare-motion 'markdown-previous-visible-heading)

;; other
(evil-declare-motion 'markdown-beginning-of-text-block)
(evil-declare-motion 'markdown-beginning-of-defun)
(evil-declare-motion 'markdown-end-of-text-block)
(evil-declare-motion 'markdown-end-of-block-element)
(evil-declare-motion 'markdown-end-of-defun)
(evil-declare-motion 'markdown-next-visible-heading)
(evil-declare-motion 'markdown-next-link)
(evil-declare-motion 'markdown-previous-visible-heading)
(evil-declare-motion 'markdown-previous-link)

;;; non-repeatible
(evil-declare-change-repeat 'markdown-cycle)
(evil-declare-change-repeat 'markdown-shifttab)

;;; Operators
(evil-define-operator evil-markdown-shift-left (beg end count)
  "Promote or indent region."
  (interactive "<r><vc>")
  (if (or (thing-at-point-looking-at markdown-regex-header)
          (and (region-active-p)
               (save-excursion
                 (goto-char beg)
                 (thing-at-point-looking-at markdown-regex-header))))
      (apply-on-rectangle
       (progn
         (deactivate-mark)
         (lambda (_x _y)
           (when (thing-at-point-looking-at markdown-regex-header)
             (markdown-insert-header-dwim '(4))))) beg end)
    (evil-shift-left beg end count)))

(evil-define-operator evil-markdown-shift-right (beg end count)
  "Demote or unindent region."
  (interactive "<r><vc>")
  (if (or (thing-at-point-looking-at markdown-regex-header)
          (and (region-active-p)
               (save-excursion
                 (goto-char beg)
                 (thing-at-point-looking-at markdown-regex-header))))
      (progn
        (deactivate-mark)
        (apply-on-rectangle
         (lambda (_x _y)
           (when (thing-at-point-looking-at markdown-regex-header)
             (markdown-insert-header-dwim '(16)))) beg end))
    (evil-shift-right beg end count)))

(defun evil-markdown-shift-left-line ()
  "Promote or indent line."
  (interactive)
  (if (cl-some #'thing-at-point-looking-at (list markdown-regex-header
                                                 markdown-regex-hr))
      (outline-promote)
    (evil-shift-left-line 1)))

(defun evil-markdown-shift-right-line ()
  "Demote or unindent line."
  (interactive)
  (if (cl-some #'thing-at-point-looking-at (list markdown-regex-header
                                                 markdown-regex-hr))
      (markdown-demote)
    (evil-shift-right-line 1)))

;;; Text objects
(evil-define-text-object markdown-element-textobj (count &optional beg end type)
  "A markdown element."
  (list (save-excursion (markdown-beginning-of-text-block) (point))
        (save-excursion (markdown-end-of-text-block) (point))))


;;; Key themes
(defun evil-markdown--populate-base-bindings ()
  "Bindings that are always be available."
  (let-alist evil-markdown-movement-bindings
    (dolist (state '(normal visual operator motion))
      (evil-define-key state evil-markdown-mode-map
        (kbd "}") 'markdown-forward-paragraph
        (kbd "{") 'markdown-backward-paragraph))
    (dolist (state '(normal visual))
      (evil-define-key state evil-markdown-mode-map
        (kbd "<") 'evil-markdown-shift-left
        (kbd ">") 'evil-markdown-shift-right
        (kbd "<tab>") 'markdown-cycle
        (kbd "<S-tab>") 'markdown-shifttab))))

(defun evil-markdown--populate-insert-bindings ()
  "Define insert mode bindings."
  (evil-define-key 'insert evil-markdown-mode-map
    (kbd "C-t") 'evil-markdown-shift-right-line
    (kbd "C-d") 'evil-markdown-shift-left-line))

(defun evil-markdown--populate-navigation-bindings ()
  "Configures gj/gk/gh/gl for navigation."
  (let-alist evil-markdown-movement-bindings
    (evil-define-key 'motion evil-markdown-mode-map
       (kbd (concat "g" .left)) 'markdown-up-heading
       (kbd (concat "g" .right)) (lambda () (interactive) (markdown-next-heading))
       (kbd (concat "g" .up)) 'markdown-backward-same-level
       (kbd (concat "g" .down)) 'markdown-forward-same-level)))

(defun evil-markdown--populate-additional-bindings ()
  "Bindings with meta and control."
  (let-alist evil-markdown-movement-bindings
    (dolist (state (if evil-markdown-use-additional-insert
                       '('normal visual insert)
                     '(normal visual)))
      (evil-define-key state evil-markdown-mode-map
        (kbd (concat "M-" .left)) 'markdown-promote
        (kbd (concat "M-" .right)) 'markdown-demote
        (kbd (concat "M-" .up)) 'markdown-move-up
        (kbd (concat "M-" .down)) 'markdown-move-down
        (kbd (concat "M-" (capitalize .up))) 'markdown-move-subtree-up
        (kbd (concat "M-" (capitalize .down))) 'markdown-move-subtree-down))))

(defun evil-markdown--populate-textobjects-bindings ()
  (dolist (state '(visual operator))
    (evil-define-key state evil-markdown-mode-map "ae" 'markdown-element-textobj)))

;;;###autoload
(defun evil-markdown-set-key-theme (theme)
  "Select what key THEMEs to enable."
  (setq evil-markdown-mode-map (make-sparse-keymap))
  (evil-markdown--populate-base-bindings)
  (when (memq 'navigation theme) (evil-markdown--populate-navigation-bindings))
  (when (memq 'textobjects theme) (evil-markdown--populate-textobjects-bindings))
  (when (memq 'insert theme) (evil-markdown--populate-insert-bindings))
  (when (memq 'additional theme) (evil-markdown--populate-additional-bindings))
  (setcdr
   (assq 'evil-markdown-mode minor-mode-map-alist)
   evil-markdown-mode-map))

(defcustom evil-markdown-key-theme
  (if (bound-and-true-p evil-disable-insert-state-bindings)
      '(navigation textobjects additional)
    '(navigation textobjects insert additional))
  "List of key themes used to compose `evil-markdown-mode-map'."
  :group 'evil-markdown
  :type
  '(set (const navigation)
        (const textobjects)
        (const insert)
        (const additional))
  :set (lambda (sym val)
         (evil-markdown-set-key-theme val)
         (set-default sym val)))

(evil-markdown-set-key-theme evil-markdown-key-theme)

(provide 'evil-markdown)
;;; evil-markdown.el ends here
