#lang racket
(require data/heap)
(provide sim? wire?
         (contract-out
          [make-sim        (-> sim?)]
          [sim-wait!       (-> sim? positive? void?)]
          [sim-time        (-> sim? real?)]
          [sim-add-action! (-> sim? positive? (-> any/c) void?)]

          [make-wire       (-> sim? wire?)]
          [wire-on-change! (-> wire? (-> any/c) void?)]
          [wire-value      (-> wire? boolean?)]
          [wire-set!       (-> wire? boolean? void?)]

          [bus-value (-> (listof wire?) natural?)]
          [bus-set!  (-> (listof wire?) natural? void?)]

          [gate-not  (-> wire? wire? void?)]
          [gate-and  (-> wire? wire? wire? void?)]
          [gate-nand (-> wire? wire? wire? void?)]
          [gate-or   (-> wire? wire? wire? void?)]
          [gate-nor  (-> wire? wire? wire? void?)]
          [gate-xor  (-> wire? wire? wire? void?)]

          [wire-not  (-> wire? wire?)]
          [wire-and  (-> wire? wire? wire?)]
          [wire-nand (-> wire? wire? wire?)]
          [wire-or   (-> wire? wire? wire?)]
          [wire-nor  (-> wire? wire? wire?)]
          [wire-xor  (-> wire? wire? wire?)]

          [flip-flop (-> wire? wire? wire? void?)]))


(struct sim ([time #:mutable] [queue #:mutable]))
(struct wire ([sim #:mutable] [value #:mutable] [actions #:mutable]))


; ====Simulation======
(define (make-sim)
  (sim 0 (make-heap (lambda (x y) (< (car x) (car y))))))


(define (sim-wait! sim time)
  (define (exec-next)
    (let ([heap (sim-queue sim)])
      (when (> (heap-count heap) 0)
        (let* ([event (heap-min heap)])
          (when (<= (car event) (+ (sim-time sim) time))
            (begin (heap-remove-min! heap)
                   (set-sim-time! sim (car event))
                   ((cdr event))
                   (exec-next)))))))
  (begin (exec-next) (set-sim-time! sim
                     (+ (sim-time sim) time))))



(define (sim-add-action! s time fun)
  (heap-add! (sim-queue s) (cons (+ (sim-time s) time) fun)))


;======Wires=functions=======
(define (make-wire s) (wire s #f empty))

(define (wire-on-change! wire fun)
  (begin
    (set-wire-actions! wire (cons fun (wire-actions wire)))
    (fun)))  

(define (wire-set! wire new-signal)
  (when (not (eq? (wire-value wire) new-signal))
    (begin
     (set-wire-value! wire new-signal)
     (for-each (lambda (fun) (fun))
               (wire-actions wire)))))


 
;======Gates========
(define (create-gate out in1 in2 wait fun)
  (let* ([action (lambda ()
    (sim-add-action! (wire-sim out)
                     wait
                     (lambda ()
                     (wire-set! out (fun)))))])
  (begin
    (wire-on-change! in1 action)
    (wire-on-change! in2 action))))

(define (gate-not out in)
  (let* ([action   (lambda ()
        (sim-add-action! (wire-sim out) 1
        (lambda () 
        (wire-set! out (not (wire-value in))))))])
    (wire-on-change! in action)))

(define (gate-and out in1 in2)
  (create-gate out in1 in2 1 (lambda () (and (wire-value in1) (wire-value in2)))))

(define (gate-nand out in1 in2)
  (create-gate out in1 in2 1 (lambda () (not (and (wire-value in1) (wire-value in2))))))
    

(define (gate-or out in1 in2)
  (create-gate out in1 in2 1 (lambda () (or (wire-value in1) (wire-value in2)))))


(define (gate-nor out in1 in2)
  (create-gate out in1 in2 1 (lambda () (not (or (wire-value in1) (wire-value in2))))))


(define (gate-xor out in1 in2)
  (create-gate out in1 in2 2
               (lambda () (and (or (wire-value in1) (wire-value in2))
                    (not (and (wire-value in1) (wire-value in2)))))))

;====Wires=======
  (define (wire-not in)
    (define new-w (make-wire (wire-sim in)))
              (gate-not new-w in)
              new-w)

  (define (wire-and in1 in2)
    (define new-w (make-wire (wire-sim in1)))
           (gate-and new-w in1 in2)
           new-w)

  (define (wire-nand in1 in2)
    (define new-w (make-wire (wire-sim in1)))
           (gate-nand new-w in1 in2)
           new-w)
  
  (define (wire-or in1 in2)
    (define new-w (make-wire (wire-sim in1)))
           (gate-or new-w in1 in2)
           new-w)
  
  (define (wire-nor in1 in2)
    (define new-w (make-wire (wire-sim in1)))
           (gate-nor new-w in1 in2)
           new-w)
  
  (define (wire-xor in1 in2)
    (define new-w (make-wire (wire-sim in1)))
           (gate-xor new-w in1 in2)
           new-w)

(define (bus-set! wires value)
  (match wires
    ['() (void)]
    [(cons w wires)
     (begin
       (wire-set! w (= (modulo value 2) 1))
       (bus-set! wires (quotient value 2)))]))

(define (bus-value ws)
  (foldr (lambda (w value) (+ (if (wire-value w) 1 0) (* 2 value)))
         0
         ws))

(define (flip-flop out clk data)
  (define sim (wire-sim data))
  (define w1  (make-wire sim))
  (define w2  (make-wire sim))
  (define w3  (wire-nand (wire-and w1 clk) w2))
  (gate-nand w1 clk (wire-nand w2 w1))
  (gate-nand w2 w3 data)
  (gate-nand out w1 (wire-nand out w3)))
