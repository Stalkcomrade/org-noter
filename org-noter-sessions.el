(setq +org-noter-sessions nil)

(defun +add-pdf-to-session (pdf key)
  "Add pdf and bibkey to session list"
  (add-to-list '+org-noter-sessions `(,pdf . ,key)))

(defun +org-noter-skip-choosing-note ()
  "Wrapper for the main org-noter util"
  (org-noter nil t)
  )

;; TODO: save-excursion or/and kill
;; pdf buffer

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


(defun +utils-print-to-file (filename data)
  (with-temp-file filename
    (prin1 data (current-buffer))))

(defun +utils-read-from-file (filename)
  (with-temp-buffer
    (insert-file-contents filename)
    (cl-assert (eq (point) (point-min)))
    (read (current-buffer))))


;; defining structure

(cl-defstruct +noter-session name session)
(setq +noter-sessions-object nil)

(defun +org-noter-save-session ()
  "Saves session to a file"
  ;; (message "Session is %s" (read-string "Enter session name:"))
  (let ((test-input))
    (setq test-input (read-string "Enter session name:"))
    (add-to-list '+noter-sessions-object `,(make-+noter-session :name "test" :session `,+org-noter-sessions))
    (add-to-list '+noter-sessions-object `,(make-+noter-session :name "main" :session `,+org-noter-sessions))
    )
  (+utils-print-to-file "~/.emacs.d/org-noter-session.el" `,+org-noter-sessions)
  )

;; extracting from +noter-sessions-object

(setq xx '(1 2 2 "a"))             ;
;; remove items that's not a number

;; (-filter (lambda (num) (if (stringp num)
;;                       nil
;;                     (= num 1))
;;            ) xx)

;; (-filter (lambda (num) (+noter-session-name +))
;;            ) +noter-sessions-object)

;; (+noter-sessions-object)

;; defining structure



(defun +org-noter-load-session ()
  "Loads session from a file"
  (setq +org-noter-sessions (+utils-read-from-file "~/.emacs.d/org-noter-session.el"))
  )

;; for testing purposes
;; (+org-noter-load-session)
;; (+open-pdf-from-session)
