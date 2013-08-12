(import (scheme base)
        (srfi 18)
        (chibi test)
        (queue))

(test-begin "lifo-queue")

(define queue (make-lifo-queue))
(test-assert (lifo-queue? queue))

;; Adding and removing in same thread
(lifo-queue-put! queue 1)
(lifo-queue-put! queue 2)
(test 2 (lifo-queue-get! queue))
(test 1 (lifo-queue-get! queue))

;; Adding and removing in different threads
(define write-thread
  (make-thread
    (lambda ()
      (lifo-queue-put! queue 1)
      (lifo-queue-put! queue 2))))

(thread-start! write-thread)
(test 2 (lifo-queue-get! queue))
(test 1 (lifo-queue-get! queue))
(thread-join! write-thread)

(test-end)
