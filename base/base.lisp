;; -*- coding: utf-8 -*-
;; This file is part of CLPGK.
;; Copyright (c) 2019 PGkids Laboratory

(clpgk.core:clpgk-core-header)

(clpgk.core:define-package :clpgk.base ()
  (:use :cl)
  (:import/export :clpgk.base.ffi*)
  (:export

   #:clpgk-base-header
   
   #:wired-p
   #:unwired-p
   #:define-wired #:define-unwired
   #:do-wire #:do-unwire
   #:set-standalone-application

   #:complete-and-register-wiring
   )

  (:unexport #:clpgk-core-header)
  )

(in-package :clpgk.base)

(defmacro clpgk-base-header (&rest args)
  `(clpgk.core:clpgk-core-header ,@args))

(defparameter *app-wired-p* t)

(defun wired-p   ()      *app-wired-p*)
(defun unwired-p () (not *app-wired-p*))


(defgeneric <wired>   (package))
(defgeneric <unwired> (package))


(defun <defw> (method-name body)
  (with-gensyms (x)
    `(eval-when (:load-toplevel :execute)
      (defmethod ,method-name ((,x (eql *package*)))
        (declare (ignore ,x))
        ,@body)
      nil)))

(defmacro define-wired (&body body)
  (<defw> '<wired> body))

(defmacro define-unwired (&body body)
  (<defw> '<unwired> body))


(defparameter *wiring* nil)
(defun complete-and-register-wiring (&optional (pkg *package*))
  (pushnew pkg *wiring*)
  (when (wired-p)
    (<wired> pkg)))

(defun do-wire ()
  (setq *app-wired-p* t)
  ;; FIFO順に実行
  (mapc #'<wired> (reverse *wiring*)))

(defun do-unwire ()
  (setq *app-wired-p* nil)
  ;; FILO順に実行
  (mapc #'<unwired> *wiring*))

(defun set-standalone-application (&optional (this-is-standalone-app t))
  (if this-is-standalone-app
    (pushnew :CL-UNWIRED-STANDALONE-APPLICATION *features*)
    (removef *features* :CL-UNWIRED-STANDALONE-APPLICATION)))

