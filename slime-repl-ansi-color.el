(require 'ansi-color)

(define-slime-contrib slime-repl-ansi-color
  "Turn on ANSI colors in REPL output"
  (:authors "Max Mikhanosha")
  (:license "GPL")
  (:slime-dependencies slime-repl)
  (:on-load
   (add-hook 'slime-repl-mode-hook
             (lambda ()
               (slime-repl-ansi-on)))))

(defvar slime-repl-ansi-color nil
  "When Non-NIL will process ANSI colors in the lisp output")

(make-variable-buffer-local 'slime-repl-ansi-color)

(defun slime-repl-ansi-on ()
  "Set `ansi-color-for-comint-mode' to t."
  (interactive)
  (setq slime-repl-ansi-color t))

(defun slime-repl-ansi-off ()
  "Set `ansi-color-for-comint-mode' to t."
  (interactive)
  (setq slime-repl-ansi-color nil))

(defun slime-repl-ansi-color-clear ()
  (interactive)
  ;; ansi-color caches last position sometimes, so make sure it gets
  ;; reset when buffer is cleared
  (setf ansi-color-context-region nil))

(add-hook 'slime-repl-clear-buffer-hook 'slime-repl-ansi-color-clear)

(defun slime-repl-emit--ansi-colorize (original string)
  (with-current-buffer (slime-output-buffer)
    (let ((start slime-output-start))
      (prog1
          ;; cached marker gets moved when slime inserts text, so
          ;; put it back where it was
          (if (markerp (cadr ansi-color-context-region))
              (slime-save-marker (cadr ansi-color-context-region)
                 (funcall original string))
              (funcall original string))
        (when slime-repl-ansi-color
          (ansi-color-apply-on-region start slime-output-end
                                      ;; not sure if this should keep
                                      ;; the escape sequences or not?
                                      nil))))))

(advice-add 'slime-repl-emit :around #'slime-repl-emit--ansi-colorize)

(provide 'slime-repl-ansi-color)
