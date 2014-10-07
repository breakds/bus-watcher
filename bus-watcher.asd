;;;; bus-watcher.asd

(asdf:defsystem #:bus-watcher
    :serial t
    :depends-on (#:basicl
		 #:drakma
		 #:jsown
		 #:stefil)
    :components ((:file "lisp/package")
		 (:file "lisp/core")))

