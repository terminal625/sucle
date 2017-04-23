(defpackage :pix
  (:use #:cl #:fuktard))

(in-package :pix)

(progn
  (deftype pix-world ()
    (quote hash-table))
  (defconstant +available-bits+ (logcount most-positive-fixnum))
  (defconstant +x-bits-start+ (floor +available-bits+ 2))
  (defconstant +x-chunk-bits+ 4)
  (defconstant +x-chunk-size+ (ash 1 +x-chunk-bits+))
  (defconstant +x-bitmask+ (1- +x-chunk-size+))
  (defconstant +y-chunk-bits+ 4)
  (defconstant +y-chunk-size+ (ash 1 +y-chunk-bits+))
  (defconstant +y-bitmask+ (1- +y-chunk-size+))
  (defconstant +xy-bitmask+ (1- (* +y-chunk-size+ +x-chunk-size+)))
  (defconstant +index-mask+ (logior (ash +x-bitmask+ +x-bits-start+)
				    +y-bitmask+))
  (defconstant +hash-mask+ (logxor +index-mask+ most-positive-fixnum))
  (defconstant +right-shift+ (- +y-chunk-bits+ +x-bits-start+))
  (defconstant +y-mask+ (1- (ash 1 +x-bits-start+)))

  (defun make-chunk ()
    (make-array (* +x-chunk-size+ +y-chunk-size+)
		:element-type t
		:initial-element nil))

  (defun make-world ()
    (make-hash-table :test (quote eq)))


  (defmacro with-chunk-or-null ((chunk &optional (hash-id (gensym))) (place hash) &body body)
    `(let* ((,hash-id (logand ,place +hash-mask+))
	    (,chunk (gethash ,hash-id ,hash)))
       (declare (type (or null simple-vector) ,chunk))
       ,@body))

  (declaim (ftype (function (fixnum) (values fixnum fixnum)) index-xy)
	   (ftype (function (fixnum fixnum) fixnum) xy-index)
	   (ftype (function (fixnum hash-table) t) get-obj)
	   (ftype (function (fixnum t hash-table) t) set-obj)
	   (ftype (function (fixnum) fixnum) chunk-ref)
	   (inline index-xy xy-index get-obj set-obj chunk-ref))

  (with-unsafe-speed 
    (defun chunk-ref (place)
      (let* ((num (logand place +index-mask+))
	     (num2 (ash num +right-shift+))
	     (num3 (logand +xy-bitmask+ (logior num num2))))
	num3))
    (defun set-obj (place value world)
      (with-chunk-or-null (chunk hash-id) (place world)
	(unless chunk
	  (let ((new-chunk (make-chunk)))
	    (setf (gethash hash-id world) new-chunk)
	    (setf chunk new-chunk)))
	(setf (aref chunk (chunk-ref place)) value)
	hash-id))
    (defun get-obj (place world)
      (with-chunk-or-null (chunk) (place world)
	(if chunk
	    (aref chunk (chunk-ref place)))))
    (defun xy-index (x y)
      (let ((fnum (ash x +x-bits-start+)))
	(declare (type fixnum fnum))
	(logior fnum (logand +y-mask+ y))))
    (defun index-xy (index)
      (values (ash index (- +x-bits-start+))
	      (logand index +y-mask+))))
  (progn
    (declaim (inline (setf get-obj)))
    (defun (setf get-obj) (value place hash-table)
      (set-obj place value hash-table))))

(export (quote (index-xy xy-index get-obj set-obj chunk-ref make-world make-chunk pix-world)))