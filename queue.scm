(define-record-type queue
  %make-queue
  queue?
  max-size
  mutex
  put-condvar
  get-condvar
  (head)
  (tail)
  (size))

(define (make-queue . max-size)
  (let ((mutex (make-mutex))
        (put-condvar (make-condition-variable))
        (get-condvar (make-condition-variable))
        (head '())
        (tail '())
        (size 0))
    (%make-queue max-size mutex put-condvar get-condvar head tail size)))

(define (queue-full? queue)
  (if (null? (queue-max-size queue))
      #f
      (< (queue-max-size queue)
         (queue-size queue))))

(define (queue-empty? queue)
  (eq? queue-size 0))

(define (queue-put! queue task)
  (let ((mutex (queue-mutex queue))
        (put-condvar (queue-put-condvar queue))
        (get-condvar (queue-get-condvar queue)))
    (mutex-lock! mutex)
    (if (queue-full? queue)
        (begin (mutex-unlock! mutex put-condvar)
               (queue-put! task))

        (begin (if (null? (queue-head queue))
                   (begin (queue-head-set! queue (cons task '()))
                          (queue-tail-set! queue (queue-head queue)))
                   (begin (set-cdr! (queue-tail queue) (cons task '()))
                          (queue-tail-set! queue (cdr (queue-tail queue)))))
               (queue-size-set! queue (+ (queue-size queue) 1))
               (condition-variable-signal! get-condvar)
               (mutex-unlock! mutex)))))
  
(define (queue-get! queue . block)
   (let ((mutex (queue-mutex queue))
        (put-condvar (queue-put-condvar queue))
        (get-condvar (queue-get-condvar queue)))
     (mutex-lock! mutex)
     (if (queue-empty? queue)
         (begin (mutex-unlock! mutex get-condvar)
                (queue-get! queue))
         (let ((task (car (queue-head queue))))
           (queue-head-set! queue (cdr (queue-head queue)))
           (if (null? (queue-head queue))
               (queue-tail-set! queue '()))
           (queue-size-set! queue (- (queue-size queue) 1))
           (condition-variable-signal! put-condvar)
           (mutex-unlock! mutex)
           task))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-record-type lifo-queue
  %make-lifo-queue
  lifo-queue?
  mutex
  get-condvar
  (head))

(define (make-lifo-queue)
  (let ((mutex (make-mutex))
        (get-condvar (make-condition-variable))
        (head '()))
    (%make-lifo-queue mutex get-condvar head)))

(define (lifo-queue-put! queue task)
  (let ((mutex (lifo-queue-mutex queue))
        (get-condvar (lifo-queue-get-condvar queue)))
    (mutex-lock! mutex)
    (lifo-queue-head-set! queue (cons task (lifo-queue-head queue)))
    (condition-variable-signal! get-condvar)
    (mutex-unlock! mutex)))

(define (lifo-queue-get! queue . block)
   (let ((mutex (lifo-queue-mutex queue))
         (get-condvar (lifo-queue-get-condvar queue)))
     (mutex-lock! mutex)
     (if (null? (lifo-queue-head queue))
         (begin (mutex-unlock! mutex get-condvar)
                (lifo-queue-get! queue))
         (let ((task (car (lifo-queue-head queue))))
           (lifo-queue-head-set! queue (cdr (lifo-queue-head queue)))
           (mutex-unlock! mutex)
           task))))
