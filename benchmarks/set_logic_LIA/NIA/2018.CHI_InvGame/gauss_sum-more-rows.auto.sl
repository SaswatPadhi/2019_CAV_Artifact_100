; Benchmark adapted from "gauss_sum_true-unreach-call.c"

(set-logic LIA)

(synth-inv inv-f ((n Int) (sum Int) (i Int)))

(declare-primed-var n Int)
(declare-primed-var sum Int)
(declare-primed-var i Int)

(define-fun pre-f ((n Int) (sum Int) (i Int)) Bool
  (and (<= 1 n) (<= n 1000) (= sum 0) (= i 1)))

(define-fun trans-f ((n Int) (sum Int) (i Int)
                     (n! Int) (sum! Int) (i! Int)) Bool
  (and (<= i n) (= i! (+ i 1)) (= sum! (+ sum i)) (= n! n)))

(define-fun post-f ((n Int) (sum Int) (i Int)) Bool
  (or (<= i n) (= (* sum 2) (* n (+ n 1)))))

(inv-constraint inv-f pre-f trans-f post-f)

(check-synth)
