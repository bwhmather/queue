(import (scheme base)
        (srfi 18)
        (chibi test)
        (queue))

(test-begin "queue")

(define queue (make-queue))
(test-assert (queue? queue))

;; Adding and removing in same thread
(queue-put! queue 1)
(queue-put! queue 2)
(test 1 (queue-get! queue))
(test 2 (queue-get! queue))

;; Adding and removing in different threads
(define write-thread
  (make-thread
    (lambda ()
      (queue-put! queue 1)
      (queue-put! queue 2))))

(thread-start! write-thread)
(test 1 (queue-get! queue))
(test 2 (queue-get! queue))
(thread-join! write-thread)

(test-end)
