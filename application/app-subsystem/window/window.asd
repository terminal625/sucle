(defclass undefine-cffi-load-foreign-library-op (asdf:operation)
  ())
(defclass restore-cffi-load-foreign-library-op (asdf:operation)
  ())

(asdf:defsystem #:window
  :author "terminal625"
  :license "MIT"
  :description "Stub .asd file for selecting the backend"
  :depends-on ("glfw-blob"
	       "undefine-cffi-load-foreign-library")
  :in-order-to ((load-op
		 (undefine-cffi-load-foreign-library-op "undefine-cffi-load-foreign-library")
		 (load-op "cl-glfw3")
		 (restore-cffi-load-foreign-library-op "undefine-cffi-load-foreign-library")
		 (load-op "load-correct-glfw-library")
		 (load-op "opengl-glfw3")))
  :perform (load-op (s o)
		    (print (list s o)))
  :perform (undefine-cffi-load-foreign-library-op
	    (s o)
	    (print 24131231)
	    (uiop:symbol-call :undefine-cffi-load-foreign-library
			      'undefine-cffi-load-foreign-library))
  :perform (restore-cffi-load-foreign-library-op
	    (s o)
	    (uiop:symbol-call :undefine-cffi-load-foreign-library
			      'restore-cffi-load-foreign-library))
  
  :components ((:file "use-foreign-lib"))) 
