;;;; recorder.lisp
;;;; Author: Break Yang <breakds@gmail.com>

;;; MBTA Key:
;;; 52-0DcawcEiYlX0P0hLmYw
;;; 10000 requests per day

(in-package #:breakds.bus-watcher)

(defun log-vehicle-location (query-result stream &key (timestamp nil))
  "Log the vehicle locations in (trip-id timestamp latitude lontitude)
  format in STREAM."
  ;; If timestamp is not provided, it will be retrieved here. The
  ;; assumption is that there is little delay between the tiem when
  ;; the result is calculated on the server side and the time when
  ;; log-vehicle-location is called.
  (let ((timestamp (aif timestamp it (local-time:now))))
    (loop for direction in (access-json query-result "direction")
       do (loop for trip in (access-json direction "trip")
             do (write (list (access-json trip "trip_id")
                             (local-time:timestamp-to-unix timestamp)
                             (access-json trip "vehicle" "vehicle_lat")
                             (access-json trip "vehicle" "vehicle_lon"))
                       :stream stream)))))

(defun monitor-vehicle-by-route (route filename 
                                 &key (max-iter 1000) (interval 10))
  (with-open-file (output filename
                          :direction :output
                          :if-does-not-exist :create
                          :if-exists :append)
    (loop 
       for i below max-iter
       for timestamp = (local-time:now)
         ;; todo: unwind-protect
       do (let ((result (
         (progn (log-vehicle-location (vehicles-by-route route) output
                                       :timestamp timestamp)
                 (sleep interval)))))
                                       



