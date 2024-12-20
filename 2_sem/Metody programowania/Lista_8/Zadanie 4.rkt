#lang plait

(define-type Op
  (op-add) (op-mul) (op-sub) (op-div))

(define-type Exp
  (exp-number [n : Number])
  (exp-op [op : Op] [e1 : Exp] [e2 : Exp]))

(define (parse-Op s)
  (let ([sym (s-exp->symbol s)])
  (cond
    [(equal? sym '+) (op-add)]
    [(equal? sym '-) (op-sub)]
    [(equal? sym '*) (op-mul)]
    [(equal? sym '/) (op-div)])))



; ==============================================

(define (eval-op op)
  (type-case Op op
    [(op-add) +]
    [(op-sub) -]
    [(op-mul) *]
    [(op-div) /]))

(define (parse-Exp s)
  (cond
    [(s-exp-number? s) (s-exp->number s)]
    [(s-exp-list? s)     (let ([xs (s-exp->list s)])
       ((eval-op (parse-Op  (first  xs)))
               (parse-Exp (second xs))
               (parse-Exp (third  xs))))]))

