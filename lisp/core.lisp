;;;; core.lisp
;;;; Author: Break Yang <breakds@gmail.com>

;;; MBTA Key:
;;; 52-0DcawcEiYlX0P0hLmYw
;;; 10000 requests per day

(in-package #:breakds.bus-watcher)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter +query-prefix+ "http://realtime.mbta.com/developer/api/v2/"))

;; This key allows 10000 requests per day
(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter +mbta-key+ "52-0DcawcEiYlX0P0hLmYw")) 

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter *route-table* nil))

(defmacro construct-query (query-type &rest query-parameters)
  `(let ((*print-case* :downcase))
     (format nil "~a~a?~{~a=~a~^&~}" ,+query-prefix+ ,query-type 
	     '(,@query-parameters 
               :api_key ,+mbta-key+
               :format "json"))))

(defmacro do-query (query-type &rest query-parameters)
  (with-gensyms (response)
    `(let ((,response (drakma:http-request
                       (construct-query ,query-type
                                        ,@query-parameters))))
       (jsown:parse (binary-to-string ,response)))))

(defun binary-to-string (binary-vector)
  (coerce (loop for code across binary-vector
             collect (code-char code))
          'string))

(defun prediction-by-route (route)
  (do-query :predictionbyroute 
    :route route))

  


