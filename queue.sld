(define-library (queue)
  (export make-queue queue?
          queue-put! queue-get!
          make-lifo-queue lifo-queue?
          lifo-queue-put! lifo-queue-get!)
  (import (scheme base)
          (scheme write)
          (srfi 18)
          (srfi 99))
  (include "queue.scm"))
