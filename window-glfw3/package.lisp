(defpackage #:window
  (:use #:cl)
  (:nicknames #:E) ;;capital e is the egyptian glyph for "window" 
  (:export
   #:*keypress-hash*
   #:*mousepress-hash*
   #:*scroll-x*
   #:*scroll-y*)
  (:export
   #:key-p
   #:key-j-p
   #:key-r
   #:key-j-r
   #:mice-p
   #:mice-j-p
   #:mice-r
   #:mice-j-r)
  (:export
   #:get-proc-address
   #:init
   #:poll
   #:wrapper
   #:update-display
   #:set-vsync
   #:push-dimensions  
   #:set-caption)  
  (:export
   #:get-mouse-out
   #:get-mouse-position
   #:mice-locked-p
   #:mice-free-p
   #:toggle-mouse-capture)
  (:export
   #:*width*
   #:*height*
   #:*status*)
  (:export
   #:*resize-hook*))
