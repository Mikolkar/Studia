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

(define (action<=? x y) (<= (car x) (car y)))
(define (make-sim) (sim 0 (make-heap action<=?)))

(define (sim-wait! s time)
  (when (> (heap-count (sim-queue s)) 0)
    (when (<= (car (heap-min (sim-queue s))) (+ (sim-time s) time))
      (begin
        (set-sim-time! s (car (heap-min (sim-queue s))))
        ((cdr (heap-min (sim-queue s))))
        (heap-remove-min! (sim-queue s))
        (sim-wait! s time))))
  (set-sim-time! s (+ (sim-time s) time)))

(define (sim-add-action! s time task)
  (heap-add! (sim-queue s) (cons (+ (sim-time s) time) task)))

(define (make-wire s) (wire s #f '()))

(define (wire-set! w bool)
  (when (not (equal? (wire-value w) bool))
    (begin
      (set-wire-value! w bool)
      (for-each (lambda (x) (x)) (wire-actions w)))))

(define (wire-on-change! w task)
  (begin 
    (set-wire-actions! w (cons task (wire-actions w)))
    (task)))

(define (gate-not output input)
  (define (action) (wire-set! output (not (wire-value input))))
  (wire-on-change! input (lambda ()
                           (sim-add-action! (wire-sim output)
                                            1
                                            action))))

(define (gate-and output input1 input2)
  (define (action) (wire-set! output (and (wire-value input1) (wire-value input2))))
  (begin
    (wire-on-change! input1 (lambda ()
                              (sim-add-action! (wire-sim output)
                                               1
                                               action)))
    (wire-on-change! input2 (lambda ()
                              (sim-add-action! (wire-sim output)
                                               1
                                               action)))))

(define (gate-nand output input1 input2)
  (define (action) (wire-set! output (not (and (wire-value input1) (wire-value input2)))))
  (begin
    (wire-on-change! input1 (lambda ()
                              (sim-add-action! (wire-sim output)
                                               1
                                               action)))
    (wire-on-change! input2 (lambda ()
                              (sim-add-action! (wire-sim output)
                                               1
                                               action)))))

(define (gate-or output input1 input2)
  (define (action) (wire-set! output (or (wire-value input1) (wire-value input2))))
  (begin
    (wire-on-change! input1 (lambda ()
                              (sim-add-action! (wire-sim output)
                                               1
                                               action)))
    (wire-on-change! input2 (lambda ()
                              (sim-add-action! (wire-sim output)
                                               1
                                               action)))))

(define (gate-nor output input1 input2)
  (define (action) (wire-set! output (not (or (wire-value input1) (wire-value input2)))))
  (begin
    (wire-on-change! input1 (lambda ()
                              (sim-add-action! (wire-sim output)
                                               1
                                               action)))
    (wire-on-change! input2 (lambda ()
                              (sim-add-action! (wire-sim output)
                                               1
                                               action)))))

(define (gate-xor output input1 input2)
  (define (action) (wire-set! output (if (or (and (wire-value input1) (not (wire-value input2)))
                                                                                             (and (wire-value input2) (not (wire-value input1))))
                                                                                         #t
                                                                                         #f)))
  (begin
    (wire-on-change! input1 (lambda ()
                              (sim-add-action! (wire-sim output) 2 action)))
    (wire-on-change! input2 (lambda ()
                              (sim-add-action! (wire-sim output) 2 action)))))

(define (wire-not input)
  (begin
    (define output (make-wire (wire-sim input)))
    (gate-not output input)
    output))

(define (wire-and input1 input2)
  (begin
    (define output (make-wire (wire-sim input1)))
    (gate-and output input1 input2)
    output))

(define (wire-nand input1 input2)
  (begin
    (define output (make-wire (wire-sim input1)))
    (gate-nand output input1 input2)
    output))

(define (wire-or input1 input2)
  (begin
    (define output (make-wire (wire-sim input1)))
    (gate-or output input1 input2)
    output))

(define (wire-nor input1 input2)
  (begin
    (define output (make-wire (wire-sim input1)))
    (gate-nor output input1 input2)
    output))

(define (wire-xor input1 input2)
  (begin
    (define output (make-wire (wire-sim input1)))
    (gate-xor output input1 input2)
    output))

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








