;;; org-noter-sessions.el --- Wrappers for persistent noter sesssions. -*- lexical-binding: t -*-

(require 'dash)

;; variable for alists
(setq +org-noter-sessions nil)

;; defining structure
(cl-defstruct +noter-session name session)
;; variable for +noter-session objects
(setq +noter-sessions-object nil)

;; I provide a wrapper for starting org-noter
;; so, every time session is opened
;; corresponding pdfs and bib keys
;; are saved in order to later organised
;; them into sessions

;; FIXME: those functions
;; which are not used interactively
;; and are not exposed to a user
;; should go with doble dash --

(defun +add-pdf-to-session (pdf key)
  "Add pdf and bibkey to session list
  Use-case: call when openning from a bib
  file"
  (add-to-list '+org-noter-sessions `(,pdf . ,key)))

(defun +org-noter--add-to-session ()
  "Add pdf FILE to a custom session
   Currently it only works if is called
   from the pdf buffer
   Use-case: call when session is already established"
  (let ((pdf-file (buffer-file-name)))
    (add-to-list '+org-noter-sessions `(,pdf-file . "nil"))
    )
  )


(defun +org-noter-skip-choosing-note ()
  "Wrapper for the main org-noter util"
  (org-noter nil t)
  )

(defun +get-pdf-at-point-and-promt-for-the-buffer ()
  (bibtex-beginning-of-entry)
  (let* ((bibtex-expand-strings t)
         (entry (bibtex-parse-entry t))
         (key (reftex-get-bib-field "=key=" entry))
         (pdf (funcall org-ref-get-pdf-filename-function key)))
    (if (file-exists-p pdf)
        (message (file-name-nondirectory pdf)
                 (+add-pdf-to-session pdf key)
                 )
      )
    )
  )

;; TODO: save-excursion or/and kill
;; pdf buffer

;;;###autoload
(defun +open-pdf-from-session ()
  "Opens all pdfs from sessions and calls
     org-noter on them"
  (mapcar (lambda (file)
            (with-temp-buffer
              (find-file (car file)) 
              (message (car file))
              (+org-noter-skip-choosing-note))
            )
          +org-noter-sessions)
  )

;;;###autoload
(defun +open-pdf-and-call-org-noter (arg)
  "opens pdf and org-noter"
  (interactive "P")
  (message "Function is called with %s" arg)

  (let ((pdfBuffer (+get-pdf-at-point-and-promt-for-the-buffer) ))
    
    (call-interactively #'org-ref-bibtex-pdf)
    (switch-to-buffer pdfBuffer)

    (with-current-buffer pdfBuffer
      ;; swap to the buffer
      (call-interactively #'org-noter)
      )
    )
  )

;;;;;;



;; utils functions
;; require from utils.el

(require 'utils)

(defun +org-noter-load-session ()
  "Loads session from a file"
  (setq +noter-sessions-object (+utils-read-from-file "./tests/org-noter-session.el"))
  )

;;;###autoload
(defun +org-noter-save-session ()
  "Saves session to a file"
  (interactive)
  (let ((session-name))
    (setq session-name (read-string "Enter session name:"))
    ;; making a cl-struct object
    (add-to-list '+noter-sessions-object (make-+noter-session :name `,session-name :session `,+org-noter-sessions))
    )
  (+utils-print-to-file "./tests/org-noter-session.el" `,+noter-sessions-object) ;; FIXME: print full session object
  ;; clean local session file
  (setq +org-noter-sessions nil)
  )


;; extracting from +noter-sessions-object
;; get session by name
(defun +org-noter-extract-session (session-name)
  "Extracts cl-session object"
  (+noter-session-session
   (nth 0
        (-filter (lambda (arg) (equal `,session-name (+noter-session-name arg))) ;; TODO: replace session name
                 +noter-sessions-object)
        )
   )
  )

;; TODO: provide some tests from
;; tests.el

(provide 'org-noter-sessions)

;;; org-noter-sessions.el ends here
