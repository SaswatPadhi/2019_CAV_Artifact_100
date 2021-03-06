(set-logic NIA)

(synth-inv inv_fun ((x Int) (n Int)))

(declare-primed-var x Int)
(declare-primed-var n Int)

(define-fun pre_fun ((x Int) (n Int)) Bool
(= x n))

(define-fun trans_fun ((x Int) (n Int) (x! Int) (n! Int)) Bool
(and (and (> x 0) (= x! (- x 1))) (= n! n)))

(define-fun post_fun ((x Int) (n Int)) Bool
(not (and (<= x 0) (and (not (= x 0)) (>= n 0)))))

(inv-constraint inv_fun pre_fun trans_fun post_fun)

(check-synth)