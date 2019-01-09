(in-package :clap-user)
(common-header)


;; (a -> b
(defconstant +<ARROW>+ '->)
(defconstant +<LAMBDA>+ '|<lambda>|)

(defun <maybe-funcrep?> (typerep)
  (and (consp typerep)
       (member +<ARROW>+ typerep)))

(defun <valid-funcrep?> (typerep)
  (let ((n (length typerep)))
    (and (> n 2)
         (oddp n)
         ;(eql (count +<ARROW>+ typerep) (/ n 2))
         (not (eql +<ARROW>+ (first typerep)))
         (do ((xs (cdr typerep) (cddr xs)))
             ((null xs) t)
           (unless (and (eql +<ARROW>+ (first xs))
                        (not (eql +<ARROW>+ (second xs))))
             (return nil))))))


;; (<valid-funcrep?> typerep) == t が前提
(defun <reduce-funcrep> (typerep)
  (let ((tmp (list (first typerep))))
    (do ((xs (cdr typerep) (cddr xs)))
        ((null xs) (reduce (lambda (x y) `(,+<LAMBDA>+ ,x ,y))
                           (nreverse tmp)
                           :from-end t))
      (push (second xs) tmp))))
  

; (<reduce-funcrep> '(a -> b -> c -> (d -> e)))
; (<reduce-funcrep> '(a -> c))
; (<valid-funcrep?> '(a -> b -> c -> a))
; (<valid-funcrep?> '(a -> v))
       

;; 型表現の整合性のチェック
(defun <check-typerep-format> (typerep)
  (cond ((symbolp typerep) t)
        ((<maybe-funcrep?> typerep)
          (<valid-funcrep?> typerep))
        ((consp typerep)
          (when (and (>= (length typerep) 2)
                     (symbolp (first typerep)))
          (dolist (term (cdr typerep) t) (unless (<check-typerep-format> term)))))
        (t nil)))

;; ?で始まるシンボルは型変数
(defun <type-var?> (typerep)
  (and (symbolp typerep)
       (eql #\? (char (symbol-name typerep) 0))))

(defun <has-type-vars?> (typerep)
  (cond ((<type-var?> typerep) t)
        ((consp typerep)
          (dolist (term typerep)
            (when (<has-type-vars?> term)
              (return t))))))

(defvar *<type-vars-alist>*)
(defun <helper/collect-type-vars> (typerep)
  (flet ((collect (sym)
                  (unless (assoc sym *<type-vars-alist>*)
                    (let ((internal (gensym "?")))
                      (push (cons sym internal)
                            *<type-vars-alist>*)))))
    (cond ((<type-var?> typerep) (collect typerep))
          ((consp typerep)
            (dolist (term typerep t) (<helper/collect-type-vars> term))))))

(defun <collect-type-vars> (typerep)
  (let (*<type-vars-alist>*)
    (<helper/collect-type-vars> typerep)
    *<type-vars-alist>*))

(defun <transform-typerep> (typerep type-vars-alist)
  (cond ((<type-var?> typerep) (cdr (assoc typerep type-vars-alist)))
        ((symbolp typerep) typerep)
        ;((<maybe-funcrep?> typerep)
        ;  (<transform-typerep> (<reduce-funcrep> typerep) type-vars-alist))
        ((<maybe-funcrep?> typerep)
          (list* '->
                 (<transform-typerep> (remove +<ARROW>+ typerep) type-vars-alist)))
        ((consp typerep)
          (let (tmp)
            (dolist (term typerep (nreverse tmp))
              (push (<transform-typerep> term type-vars-alist)
                    tmp))))))
  

(defun transform-typerep (user-side-typerep)
  (<transform-typerep> user-side-typerep
                       (<collect-type-vars> user-side-typerep)))
  
(defun makerule (user-side-typerep)
  (pl-clear 'rule)
  (pl-assert `((rule ,@(transform-typerep user-side-typerep)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#Comment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro withtype (clauses &body body)
  (do-unify clauses (:EACH ((:-> :type symbol) (:-> :type symbol)))
            :on-failure (error "withtype: ~D" clauses))
  ''ok)
(withtype ((a b c)))

(fundecl f integer -> (list integer) -> (list integer))
(fundef f ...)
(f (:hint x integer) (:hint y number))
'(x|_inf_|u)



(pl-assert '((rule a b)))
(prolog (rule ?a ?b))
(makerule '(a -> ?b -> (list (pair a ?b))))
(prolog (rule -> ?a ?b (list (pair a cons))))

(with-types ((integer a b c)
             (number x))
  

(let ((a '(1 2 3)))
  (list (remove 1 a) a))
(coerce '(1 2 3) 'vector)
(consult foo (#(a b)))
(prolog (foo #(?x ?a)))

(transform-typerep '(a ?b (?c -> ?d -> (?c -> ?a) -> ?b)))
  
(let ((typerep '(a ?b (?c -> ?d -> (?c -> ?a) -> ?b))))
  (<transform-typerep> typerep (<collect-type-vars> typerep)))


(<collect-type-vars> '(?a ?a (?b ?c ?b)))
(<has-type-vars?> '(a b ?c))

(<type-var?> '?)

(<check-type-format> '(/. (/. a a) f))

