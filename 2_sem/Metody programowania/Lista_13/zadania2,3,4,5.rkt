#lang racket
;; processing data sequences with lists --------------------

(define (second-prime-in-interval a b)
  (car (cdr (filter prime?
                    (enumerate-interval a b)))))

; (second-prime-in-interval 10000 5000000)

(define (enumerate-interval a b)
  (if (> a b)
      '()
      (cons a (enumerate-interval (+ a 1) b))))

(define (square x)
  (* x x))

(define (smallest-divisor n)
  (find-divisor n 2))

(define (find-divisor n test-divisor)
  (cond ((> (square test-divisor) n) n)
        ((divides? test-divisor n) test-divisor)
        (else (find-divisor n (+ test-divisor 1)))))

(define (divides? a b)
  (= (remainder b a) 0))
(define (prime? n)
  (= n (smallest-divisor n)))
;; streams aka lazy lists ---------------------------------

;; delay and force

(define-syntax-rule
  (stream-cons v s)
  (cons v (delay s)))

(define stream-car car)

(define (stream-cdr s)
  (force (cdr s)))

(define stream-null null)
(define stream-null? null?)

;; operations on streams

(define (stream-ref s n)
  (if (= n 0)
      (stream-car s)
      (stream-ref (stream-cdr s) (- n 1))))

(define (stream-filter p s)
  (if (stream-null? s)
      stream-null
      (if (p (stream-car s))
          (stream-cons (stream-car s)
                       (stream-filter p (stream-cdr s)))
          (stream-filter p (stream-cdr s)))))

(define (stream-enumerate-interval a b)
  (if (> a b)
      stream-null
      (stream-cons a (stream-enumerate-interval (+ a 1) b))))

(define (stream-second-prime-in-interval a b)
  (stream-car
   (stream-cdr
    (stream-filter prime?
                   (stream-enumerate-interval a b)))))

;; infinite streams

(define ones (stream-cons 1 ones))

(define (integers-from n)
  (stream-cons n (integers-from (+ n 1))))

(define nats (integers-from 0))

(define (sieve s)
  (stream-cons
   (stream-car s)
   (sieve
    (stream-filter
     (λ (x) (not (divides? (stream-car s) x)))
     (stream-cdr s)))))

(define primes (sieve (integers-from 2)))

 ;; combining (infinite) streams 




; helper function
(define (stream-show-elements s ceil)
  (define (enumerate i n s)
    (if (= i n)
        null
        (cons (stream-car s) (enumerate (+ i 1) n (stream-cdr s)))))
  (enumerate 0 ceil s))
;Zadanie 2
(define (my-prime? a)
  (define (my-prime-loop a s)
    (let ([d (stream-car s)])
      (if (< a (square d)) #t
          (and (not (divides? d a)) (my-prime-loop a (stream-cdr s))))))
  (my-prime-loop a my-primes))

(define my-primes
  (stream-cons 2 (stream-filter my-prime? (integers-from 3))))

;Zadanie 3
(define nats3 (integers-from 1))
(define fact (stream-cons 1 (map2 * fact nats3)))

(define (map2 f xs ys)
  (stream-cons
   (f (stream-car xs)
      (stream-car ys))
   (map2 f (stream-cdr xs) (stream-cdr ys))))

(define nats2 (stream-cons 0 (map2 + nats2 ones)))
;Zadanie 4
(define (partial-sums s)
  (define (sum a b s)
    (if (> a b)
        0
        (+ (stream-car s) (sum (+ a 1) b (stream-cdr s)))))
  (define (rek s i)
    (let* ([el (sum 0 i s)])
      (stream-cons el (rek s (+ i 1)))))
  (rek s 0))
;zadanie 5
(define (merge xs xp)
    (let* ([v1 (stream-car xs)] [v2 (stream-car xp)])
      (cond [(< v1 v2) (stream-cons v1
             (merge (stream-cdr xs) xp))]
            [(= v1 v2) (stream-cons v1
             (merge (stream-cdr xs) (stream-cdr xp)))]
            [else (stream-cons v2 (merge xs (stream-cdr xp)))])))

(define (scale xs val)
  (stream-cons (* (stream-car xs) val)
          (scale (stream-cdr xs) val)))


  
  (define hamming 
  (letrec ([hamm-stream (stream-cons 30
          (merge (scale hamm-stream 2)
                 (merge (scale hamm-stream 3)
                        (scale hamm-stream 5))))])
    hamm-stream))
    
  
        