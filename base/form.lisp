;; J-FORM  Time-stamp: <2018-10-05 16:10:00 USER> {incremental autotitle}

(oleo.core:oleo-core-header)

(oleo.core:define-package :oleo.base.form* (:oleo.base.form)
  (:use :cl)
  (:import/export :oleo.base.match*)
  (:export
   ; #:define #:-> #:== #:=> OBSOLETE

   ;; form-1-logic.lisp
   #:then
   #:imp #:eqv

   #:logical<= #:logical< #:logical>= #:logical>
   #:logical= #:logical/=

   
   #:define-is #:is #:isnt #:is-not #:are #:are-not #:arent #:arent-not
   #:is-their #:are-their


   ;; form-1-let.lisp
   #:let-if #:let-when #:let-unless #:let-case #:let-cond #:let-while #:let-until
   #:lambda-let #:defun-let
   #:let*-if #:let*-when #:let*-unless #:let*-while #:let*-until

   ;; form-1-bind.lisp
   #:let/bind
   #:lambda/bind #:defun/bind
   #:named-lambda/bind
   #:flet/bind #:labels/bind

   ;; form-1-method.lisp
   #:100priorities #:+100priorities+
   #:define-generic #:define-method #:&..
   #:defn

   ))

(in-package :oleo.base.form)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Comment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define-is foo () #>symbolp)
(funcall (is foo) 'a)

(UTEST (lambda (x) (apply-predicate x :and consp car cdr))
       (nil nil)
       (nil 0)
       ('(2 3) '(1 2 3))
       (nil '(nil 2 3)))
       
                          