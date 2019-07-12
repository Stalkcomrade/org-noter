;;; utils.el --- Utils functions. -*- lexical-binding: t -*-

;; TODO: require cl-lib?

(defun +utils-print-to-file (filename data)
  (with-temp-file filename
    (prin1 data (current-buffer))))

(defun +utils-read-from-file (filename)
  (with-temp-buffer
    (insert-file-contents filename)
    (cl-assert (eq (point) (point-min)))
    (read (current-buffer))))

(provide 'utils)

;;; utils.el ends here
