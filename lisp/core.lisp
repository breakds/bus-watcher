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

(defmacro construct-query (query-type &rest query-parameters)
  `(let ((*print-case* :downcase))
     (format nil "~a~a?~{~a=~a~^&~}" ,+query-prefix+ ,query-type 
	     (list ,@query-parameters 
                   :api_key ,+mbta-key+
                   :format "json"))))

(defmacro do-query (query-type &rest query-parameters)
  (with-gensyms (response)
    `(let ((,response (drakma:http-request
                       (construct-query ,query-type
                                        ,@query-parameters))))
       (jsown:parse (binary-to-string ,response)))))

(defun update-route-table ()
  (let ((result (do-query "routes"))
	(route-id-table (make-hash-table :test #'equal)))
    (loop for route-set in (jsown:val result "mode")
       do (loop for route in (jsown:val route-set "route")
	     do (let ((route-id (jsown:val route "route_id"))
		      (route-name (jsown:val route "route_name")))
		  (setf (gethash route-id route-id-table) route-name))))
    route-id-table))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defparameter *route-table* nil))

(defun init ()
  (setf *route-table* (update-route-table)))

(defun look-up-route-id (route-id)
  (gethash route-id *route-table*))

(defun look-up-route-name (route-name)
  (loop 
     for id being the hash-keys of *route-table*
     for name being the hash-values of *route-table*
     when (equal name route-name)
     return id))

(defun look-up-route (designate)
  "Returns the corresponding route-id. DESIGNATE can be either a route-id or a route-name"
  (if (look-up-route-id designate)
      designate
      (look-up-route-name designate)))

(defun binary-to-string (binary-vector)
  (coerce (loop for code across binary-vector
             collect (code-char code))
          'string))

(defmacro access-json (obj &rest specifiers)
  "This is the function that chains the accessors of a jsown json
  object. Integers will be interpreted as indices and strings as
  property names."
  `,(reduce (lambda (y x)
	      (cond 
		((integerp x) `(nth ,x ,y))
		((and (consp x)
		      (or (eq (car x) :ind)
			  (eq (car x) :index)))
		 `(nth ,(second x) ,y))
		((stringp x) `(jsown:val ,y ,x))
		(t (error "Use (:ind i) when specifying index as variable."))))
	    specifiers
	    :initial-value obj))

(defun predictions-by-route (route)
  (do-query :predictionsbyroute 
    :route (look-up-route route)))

(defun vehicles-by-route (route)
  (do-query :vehiclesbyroute
    :route (look-up-route route)))

(defun schedule-by-route (route)
  (do-query :schedulebyroute
    :route (look-up-route route)))

;; (defmacro safe-call (form)
;;   `(handler-case (progn ,@form)
;;      (format t "~a" 



