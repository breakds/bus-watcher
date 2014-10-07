;;;; core.lisp
;;;; Author: Break Yang <breakds@gmail.com>

;;; MBTA Key:
;;; 52-0DcawcEiYlX0P0hLmYw
;;; 10000 requests per day

(in-package #:breakds.bus-watcher)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter +query-prefix+ "http://realtime.mbta.com/developer/api/v2/"))

(defmacro construct-query (query-type &rest query-parameters)
  `(let ((*print-case* :downcase))
     (format nil "~a~a?~{~a=~a~^&~}" ,+query-prefix+ ,query-type 
	     ',query-parameters)))

;; (defun request-route (route-id)
;;   (let ((query (format nil "~a


