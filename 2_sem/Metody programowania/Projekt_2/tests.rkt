#lang racket
(require "solution.rkt")
(require rackunit)

(define s (make-sim))

(define in1 (build-list 4 (lambda (n) (make-wire s))))

(define in2 (build-list 4 (lambda (n) (make-wire s))))

;4-bitowy ADD z x86 (chyba jakoś tak to ma działać,
;wcześniej tylko takie budowałem w Minecrafcie, nie jestem na logice cyfrowej)
(define xor1 (build-list 4 (lambda (n) (wire-xor (list-ref in1 n) (list-ref in2 n))))) ;to dałoby się jakoś ładniej napisać, by było dowolnie wiele bitów,
(define and1 (build-list 4 (lambda (n) (wire-and (list-ref in1 n) (list-ref in2 n))))) ;ktoś chętny? (ja będę robić ASK-a)

(define xor2 (build-list 3 (lambda (n) (wire-xor (list-ref xor1 (+ n 1)) (list-ref and1 n)))))
(define and2 (build-list 3 (lambda (n) (wire-and (list-ref xor1 (+ n 1)) (list-ref and1 n)))))

(define xor3 (build-list 2 (lambda (n) (wire-xor (list-ref xor2 (+ n 1)) (list-ref and2 n)))))
(define and3 (build-list 2 (lambda (n) (wire-and (list-ref xor2 (+ n 1)) (list-ref and2 n)))))

(define xor4 (wire-xor (cadr xor3) (car and3)))
(define and4 (wire-and (cadr xor3) (car and3)))

(define out (list (car xor1) (car xor2) (car xor3) xor4))

(define of (wire-xor xor4 (wire-not (wire-xor (list-ref in1 3) (list-ref in2 3)))))
(define sf (list-ref out 3))
(define cf (wire-or (wire-or (list-ref and1 3) (list-ref and2 2)) (wire-or (list-ref and3 1) and4)))
(define zf (wire-nor (wire-or (car xor1) (car xor2)) (wire-or (car xor3) xor4)))

(define (test n) ;testy losowe
  (define a (random 0 15))
  (define b (random 0 15))
  (if (= n 0)
      (void)
      (begin        
        (bus-set! in1 a)
        (bus-set! in2 b)
        (sim-wait! s 50)
        (check-equal? (bus-value out) (modulo (+ a b) 16))
        (check-equal? (wire-value zf) (= 0 (modulo (+ a b) 16)))
        (check-equal? (wire-value sf) (<= 8 (modulo (+ a b) 16)))
        (check-equal? (wire-value cf) (<= 16 (+ a b)))
        (check-equal? (wire-value of) (xor (<= 8 (modulo (+ a b) 16)) (not (xor (<= 8 a) (<= 8 b)))))
        (test (- n 1)))))

(bus-set! in1 5) ;jakieś 3 wybrane, które napisałem przed powyższym
(bus-set! in2 9)
(sim-wait! s 50)
(check-equal? (bus-value out) 14)
(check-equal? (wire-value of) #t)
(check-equal? (wire-value cf) #f)
(check-equal? (wire-value sf) #t)
(check-equal? (wire-value zf) #f)

(bus-set! in1 6)
(bus-set! in2 10)
(sim-wait! s 50)
(check-equal? (bus-value out) 0)
(check-equal? (wire-value of) #f)
(check-equal? (wire-value cf) #t)
(check-equal? (wire-value sf) #f)
(check-equal? (wire-value zf) #t)

(bus-set! in1 15)
(bus-set! in2 15)
(sim-wait! s 50)
(check-equal? (bus-value out) 14)
(check-equal? (wire-value of) #f)
(check-equal? (wire-value cf) #t)
(check-equal? (wire-value sf) #t)
(check-equal? (wire-value zf) #f)