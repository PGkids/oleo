
(asdf:defsystem :qi-test
  :depends-on (:qi)

  :serial t
  :components ((:file "package")
               (:file "00")

               )
  )