(require 'org-noter)
(require 'utils)
(require 'org-noter-sessions)

;; for testing purposes
;; (+open-pdf-from-session)


;; TODO: make tests files with sessions

(describe "loads session"
  (it "can load sessions"
    (expect (+org-noter-load-session)
            :not :to-be
            nil))
  )

(describe "check filtering functions"
  (it "can filter sessions"
    (+org-noter-load-session)
    (expect (+org-noter-extract-session "sss")
            :not :to-be
            nil))
  )
