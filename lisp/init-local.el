;; Customizations to Purcell's configurations

;; Key bindings
(global-set-key (kbd "<f5>") 'visual-line-mode)
(global-set-key (kbd "<f6>") 'toggle-truncate-lines)
(global-set-key (kbd "<f7>") 'revert-buffer-with-coding-system)
(global-set-key (kbd "<f8>") 'set-buffer-file-coding-system)
(global-set-key (kbd "C-<right>") 'forward-word)
(global-set-key (kbd "C-<left>") 'backward-word)

;; Make it possible to delete entire selected region
(delete-selection-mode 1)

;; Default coding system
(prefer-coding-system 'utf-8)

;; Customized indentation
(setq my-tab-width 2)

(defun indent-block()
  (shift-region my-tab-width)
  (setq deactivate-mark nil))

(defun unindent-block()
  (shift-region (- my-tab-width))
  (setq deactivate-mark nil))

(defun shift-region(numcols)
  " my trick to expand the region to the beginning and end of the area selected
 much in the handy way I liked in the Dreamweaver editor."
  (if (< (point)(mark))
      (if (not(bolp))    (progn (beginning-of-line)(exchange-point-and-mark) (end-of-line)))
    (progn (end-of-line)(exchange-point-and-mark)(beginning-of-line)))
  (setq region-start (region-beginning))
  (setq region-finish (region-end))
  (save-excursion
    (if (< (point) (mark)) (exchange-point-and-mark))
    (let ((save-mark (mark)))
      (indent-rigidly region-start region-finish numcols))))

(defun indent-or-complete ()
  (interactive)
  (if  mark-active
      (indent-block)
    (if (looking-at "\\>")
        (hippie-expand nil)
      (insert "\t"))))

(defun my-unindent()
  (interactive)
  (if mark-active
      (unindent-block)
    (progn
      (unless(bolp)
        (if (looking-back "^[ \t]*")
            (progn
              ;;"a" holds how many spaces are there to the beginning of the line
              (let ((a (length(buffer-substring-no-properties (point-at-bol) (point)))))
                (progn
                  ;; delete backwards progressively in my-tab-width steps, but without going further of the beginning of line.
                  (if (> a my-tab-width)
                      (delete-backward-char my-tab-width)
                    (backward-delete-char a)))))
          ;; delete tab and spaces first, if at least 2 exist, before removing words
          (progn
            (if(looking-back "[ \t]\\{2,\\}")
                (delete-horizontal-space)
              (backward-kill-word 1))))))))

(add-hook 'find-file-hooks (function (lambda ()
                                       (unless (eq major-mode 'org-mode)
                                         (local-set-key (kbd "<tab>") 'indent-or-complete)))))

(if (not (eq  major-mode 'org-mode))
    (progn
      (define-key global-map "\t" 'indent-or-complete) ;; with this you have to force tab (C-q-tab) to insert a tab after a word
      (define-key global-map (kbd "<backtab>") 'my-unindent)
      (define-key global-map [C-S-tab] 'my-unindent)))

(provide 'init-local)
