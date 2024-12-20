#lang racket
(struct mqueue
  ([front #:mutable]
   [back  #:mutable]))

(define (mqueue-empty? q)
  (and (null? (mqueue-front q))
       (null? (mqueue-back  q))))
;(define (rev-queue q)
    ;(define p (mqueue-front q))
    ;(set-mqueue-front! q (mqueue-back q))
    ;(set-mqueue-back! q p))

;Zadanie 1
(define (cycle! q)
  (define p (mqueue-front q))
  (if (mqueue-empty? q)
      q
  ((set-mcdr! (mqueue-front q) (mqueue-back q))
  (set-mcdr! (mqueue-back q) p))))

;Zadanie 2
(define (mreverse! q)
  (define (rev-list a next)
    (if (null? a)
        next
        (let ([b (mcdr a)])
          (set-mcdr! a next)
          (rev-list b a)))) 
  (rev-list q null))

(define example-mlist (mcons 1 (mcons 2 (mcons 3 '()))))
(mreverse! example-mlist)
